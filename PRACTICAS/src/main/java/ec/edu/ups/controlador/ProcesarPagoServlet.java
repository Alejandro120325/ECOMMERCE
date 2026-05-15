package ec.edu.ups.controlador;

import ec.edu.ups.modelo.Carrito;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.YearMonth;
import java.util.regex.Pattern;

/**
 * FOLIO - Procesador de pagos (validación 100 % server-side).
 * <p>
 * Recibe los datos del formulario de pago (número de tarjeta, titular,
 * fecha de expiración y CVV), valida cada campo en el servidor —incluido
 * el <strong>algoritmo de Luhn</strong>— y:
 * <ul>
 *   <li>Si todo es válido, vacía el carrito de la sesión y redirige a
 *       {@code pago-exito.jsp} con los últimos cuatro dígitos y la
 *       marca detectada.</li>
 *   <li>Si algún dato es inválido, redirige de vuelta a {@code pago.jsp}
 *       con un parámetro {@code error} que el JSP usa para renderizar
 *       el mensaje en español.</li>
 * </ul>
 *
 * <p>Soporta las marcas: Visa, Mastercard, American Express, Discover y
 * Diners Club (basado en los rangos de BIN estándar).
 */
@WebServlet(name = "ProcesarPagoServlet", urlPatterns = {"/ProcesarPagoServlet"})
public class ProcesarPagoServlet extends HttpServlet {

    private static final Pattern SOLO_LETRAS_ESPACIOS =
            Pattern.compile("^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(true);
        Carrito carrito = (Carrito) session.getAttribute(CarritoServlet.ATTR_CARRITO);

        if (carrito == null || carrito.estaVacio()) {
            response.sendRedirect("index.jsp?carrito=open");
            return;
        }

        String numero  = strip(request.getParameter("numero"));   // sin espacios
        String titular = trim(request.getParameter("titular"));
        String exp     = trim(request.getParameter("expira"));    // MM/AA
        String cvv     = strip(request.getParameter("cvv"));

        // ---- 1. Detectar marca por BIN ----
        Marca marca = detectarMarca(numero);
        if (marca == null) {
            redirigirConError(response, "marca_no_reconocida");
            return;
        }

        // ---- 2. Longitud válida según marca ----
        if (!marca.longitudesValidas.contains(numero.length())) {
            redirigirConError(response, "longitud_invalida");
            return;
        }

        // ---- 3. Algoritmo de Luhn ----
        if (!luhn(numero)) {
            redirigirConError(response, "luhn");
            return;
        }

        // ---- 4. Titular (mínimo nombre + apellido, sólo letras) ----
        if (titular.length() < 5 || !titular.contains(" ") || !SOLO_LETRAS_ESPACIOS.matcher(titular).matches()) {
            redirigirConError(response, "titular");
            return;
        }

        // ---- 5. Fecha de expiración MM/AA, no vencida ----
        if (!fechaValida(exp)) {
            redirigirConError(response, "expira");
            return;
        }

        // ---- 6. CVV — 3 ó 4 dígitos según marca ----
        if (cvv.length() != marca.longitudCvv || !cvv.chars().allMatch(Character::isDigit)) {
            redirigirConError(response, "cvv");
            return;
        }

        // -------- TODO OK -- "procesamos" el pago --------
        double montoCobrado = carrito.getTotal();
        String ultimos4 = numero.substring(numero.length() - 4);
        carrito.vaciar();

        String url = "pago-exito.jsp"
                + "?monto=" + montoCobrado
                + "&marca=" + URLEncoder.encode(marca.nombre, StandardCharsets.UTF_8)
                + "&ultimos4=" + ultimos4;
        response.sendRedirect(url);
    }

    /** Si el usuario llega por GET, lo mandamos al formulario. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("pago.jsp");
    }

    // ------------------------------------------------------------------
    // Validaciones puras (sin acoplamiento al servlet API)
    // ------------------------------------------------------------------

    /**
     * Algoritmo de Luhn (módulo 10) — verifica la suma de control
     * estándar de los números de tarjeta de crédito/débito.
     */
    public static boolean luhn(String numero) {
        if (numero == null || numero.length() < 12) return false;
        int suma = 0;
        boolean duplicar = false;
        for (int i = numero.length() - 1; i >= 0; i--) {
            char c = numero.charAt(i);
            if (c < '0' || c > '9') return false;
            int d = c - '0';
            if (duplicar) {
                d *= 2;
                if (d > 9) d -= 9;
            }
            suma += d;
            duplicar = !duplicar;
        }
        return (suma % 10) == 0;
    }

    /** Valida fecha en formato MM/AA y que no esté vencida. */
    public static boolean fechaValida(String mmYY) {
        if (mmYY == null || !mmYY.matches("^\\d{2}/\\d{2}$")) return false;
        int mes = Integer.parseInt(mmYY.substring(0, 2));
        int yy  = Integer.parseInt(mmYY.substring(3, 5));
        if (mes < 1 || mes > 12) return false;
        YearMonth exp = YearMonth.of(2000 + yy, mes);
        return !exp.isBefore(YearMonth.now());
    }

    /**
     * Detecta la marca de tarjeta a partir del prefijo BIN.
     * Devuelve {@code null} si ningún rango conocido coincide.
     */
    public static Marca detectarMarca(String numero) {
        if (numero == null || numero.isEmpty()) return null;
        if (numero.matches("^3[47].*"))             return Marca.AMEX;
        if (numero.matches("^4.*"))                 return Marca.VISA;
        if (numero.matches("^(5[1-5]|2(2[2-9]|[3-6]\\d|7[01]|720)).*"))
                                                    return Marca.MASTERCARD;
        if (numero.matches("^(6011|65|64[4-9]).*")) return Marca.DISCOVER;
        if (numero.matches("^(30[0-5]|3095|3[689]).*"))
                                                    return Marca.DINERS;
        return null;
    }

    private void redirigirConError(HttpServletResponse response, String codigo) throws IOException {
        response.sendRedirect("pago.jsp?error=" + codigo);
    }

    private static String strip(String s)  { return s == null ? "" : s.replaceAll("\\D", ""); }
    private static String trim(String s)   { return s == null ? "" : s.trim().toUpperCase(); }

    // ------------------------------------------------------------------
    // Enumeración de marcas con sus reglas
    // ------------------------------------------------------------------
    public enum Marca {
        VISA      ("VISA",              java.util.Arrays.asList(13, 16, 19), 3),
        MASTERCARD("MASTERCARD",        java.util.Arrays.asList(16),         3),
        AMEX      ("AMERICAN EXPRESS",  java.util.Arrays.asList(15),         4),
        DISCOVER  ("DISCOVER",          java.util.Arrays.asList(16),         3),
        DINERS    ("DINERS CLUB",       java.util.Arrays.asList(14),         3);

        public final String nombre;
        public final java.util.List<Integer> longitudesValidas;
        public final int longitudCvv;

        Marca(String nombre, java.util.List<Integer> lens, int cvv) {
            this.nombre = nombre;
            this.longitudesValidas = lens;
            this.longitudCvv = cvv;
        }
    }
}
