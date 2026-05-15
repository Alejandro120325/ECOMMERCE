package ec.edu.ups.controlador;

import ec.edu.ups.dao.LibroDAO;
import ec.edu.ups.modelo.Carrito;
import ec.edu.ups.modelo.Libro;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * FOLIO - Controlador del carrito (POST + sendRedirect, sin AJAX).
 * <p>
 * Sigue el patrón clásico Post-Redirect-Get: cada acción del cliente
 * es un formulario tradicional ({@code <form method="POST">}) o un
 * enlace con query string. El servlet:
 * <ol>
 *   <li>Obtiene/crea el {@link Carrito} de la {@link HttpSession}.</li>
 *   <li>Ejecuta la acción contra el modelo.</li>
 *   <li>Redirige al cliente a la URL recibida en el parámetro
 *       {@code redirect} (o a {@code index.jsp} por defecto),
 *       conservando el parámetro {@code carrito=open} para que
 *       el drawer permanezca visible después del refresco.</li>
 * </ol>
 *
 * <h3>Acciones soportadas</h3>
 * <ul>
 *   <li>{@code AGREGAR_LIBRO}      + libroId</li>
 *   <li>{@code DISMINUIR_CANTIDAD} + libroId</li>
 *   <li>{@code AUMENTAR_CANTIDAD}  + libroId</li>
 *   <li>{@code ELIMINAR_LIBRO}     + libroId</li>
 *   <li>{@code VACIAR}</li>
 * </ul>
 */
@WebServlet(name = "CarritoServlet", urlPatterns = {"/CarritoServlet"})
public class CarritoServlet extends HttpServlet {

    /** Clave bajo la cual el carrito vive en la sesión HTTP. */
    public static final String ATTR_CARRITO = "carrito";

    private final LibroDAO libroDAO = new LibroDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        Carrito carrito = obtenerCarrito(request);
        String accion  = request.getParameter("accion");
        String libroId = request.getParameter("libroId");

        if ("AGREGAR_LIBRO".equals(accion)) {
            Libro libro = libroDAO.buscarPorId(libroId);
            if (libro != null) carrito.agregar(libro);

        } else if ("DISMINUIR_CANTIDAD".equals(accion)) {
            carrito.disminuir(libroId);

        } else if ("AUMENTAR_CANTIDAD".equals(accion)) {
            Libro libro = libroDAO.buscarPorId(libroId);
            if (libro != null) carrito.agregar(libro);

        } else if ("ELIMINAR_LIBRO".equals(accion)) {
            carrito.eliminar(libroId);

        } else if ("VACIAR".equals(accion)) {
            carrito.vaciar();
        }

        // Post-Redirect-Get hacia la página que originó la petición.
        // Mantenemos el drawer abierto añadiendo carrito=open.
        String destino = construirDestino(request);
        response.sendRedirect(destino);
    }

    /** Permite cerrar el drawer u abrir el carrito vía GET (enlace simple). */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Asegura que la sesión y el carrito existen antes de redirigir.
        obtenerCarrito(request);
        String destino = construirDestino(request);
        response.sendRedirect(destino);
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    /** Recupera o crea (lazy) el {@link Carrito} de la sesión. */
    public static Carrito obtenerCarrito(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        synchronized (session) {
            Carrito carrito = (Carrito) session.getAttribute(ATTR_CARRITO);
            if (carrito == null) {
                carrito = new Carrito();
                session.setAttribute(ATTR_CARRITO, carrito);
            }
            return carrito;
        }
    }

    /**
     * Construye la URL de retorno preservando el drawer del carrito abierto.
     * Acepta los parámetros {@code redirect} (URL relativa segura) y
     * {@code carrito} (open/close).
     */
    private String construirDestino(HttpServletRequest request) {
        String redirect = request.getParameter("redirect");
        if (redirect == null || redirect.isBlank() || redirect.contains("://")) {
            redirect = "index.jsp";
        }
        // La acción "VACIAR" o "ELIMINAR" cuando el carrito queda vacío
        // sigue manteniendo el drawer abierto para que el usuario lo vea.
        String estadoDrawer = request.getParameter("carrito");
        if (estadoDrawer == null) estadoDrawer = "open";

        char sep = redirect.contains("?") ? '&' : '?';
        return redirect + sep + "carrito=" + estadoDrawer;
    }
}
