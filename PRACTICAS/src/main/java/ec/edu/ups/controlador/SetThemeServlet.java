package ec.edu.ups.controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * FOLIO - Conmutador de tema (light / dark) 100 % server-side.
 * <p>
 * Recibe un POST con el tema deseado, lo guarda en la
 * {@link HttpSession} bajo el atributo {@code "tema"} y redirige
 * de vuelta a la página recibida en el parámetro {@code redirect}
 * (Post-Redirect-Get clásico, sin AJAX).
 *
 * <p>El header lee {@code session.getAttribute("tema")} y aplica
 * la clase correspondiente en {@code <body>}.
 */
@WebServlet(name = "SetThemeServlet", urlPatterns = {"/SetThemeServlet"})
public class SetThemeServlet extends HttpServlet {

    /** Clave del atributo en la HttpSession. */
    public static final String ATTR_TEMA = "tema";

    /** Tema por defecto cuando la sesión no tiene preferencia. */
    public static final String TEMA_DEFAULT = "dark";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String tema = request.getParameter("tema");
        // Sólo aceptamos los dos valores conocidos: defensa contra parámetros maliciosos.
        if (!"light".equalsIgnoreCase(tema) && !"dark".equalsIgnoreCase(tema)) {
            tema = TEMA_DEFAULT;
        }
        tema = tema.toLowerCase();

        HttpSession session = request.getSession(true);
        session.setAttribute(ATTR_TEMA, tema);

        // Volvemos a la página de origen, conservando los parámetros que ya traía
        // (carrito=open, sec=..., categoria=..., etc.).
        String redirect = request.getParameter("redirect");
        if (redirect == null || redirect.isBlank() || redirect.contains("://")) {
            redirect = "index.jsp";
        }
        response.sendRedirect(redirect);
    }

    /**
     * Helper estático: devuelve el tema actual de la sesión, o el
     * default si no hay preferencia. Lo usan todas las JSPs para
     * inyectar la clase del body en una sola línea.
     */
    public static String obtenerTema(HttpServletRequest request) {
        HttpSession s = request.getSession(false);
        if (s == null) return TEMA_DEFAULT;
        Object v = s.getAttribute(ATTR_TEMA);
        return (v instanceof String) ? (String) v : TEMA_DEFAULT;
    }
}
