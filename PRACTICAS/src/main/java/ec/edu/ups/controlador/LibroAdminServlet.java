package ec.edu.ups.controlador;

import ec.edu.ups.dao.LibroDAO;
import ec.edu.ups.modelo.Libro;
import ec.edu.ups.modelo.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.text.Normalizer;

/**
 * FOLIO - CRUD de libros para EMPLEADO / ADMIN.
 * <p>
 * Acciones POST:
 * <ul>
 *   <li>{@code CREAR_LIBRO}  — recibe titulo, autor, isbn, precio,
 *                              stock, paginas, categoria, portadaUrl.</li>
 *   <li>{@code ELIMINAR_LIBRO} — recibe libroId.</li>
 * </ul>
 * Redirige a {@code empleado.jsp?sec=inventario&msg=...}.
 */
@WebServlet(name = "LibroAdminServlet", urlPatterns = {"/LibroAdminServlet"})
public class LibroAdminServlet extends HttpServlet {

    private final LibroDAO libroDAO = new LibroDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // ---- Guardia: sólo EMPLEADO o ADMIN ----
        HttpSession session = request.getSession(false);
        Usuario actual = (session == null) ? null : (Usuario) session.getAttribute("usuarioActivo");
        if (actual == null
                || !("EMPLEADO".equalsIgnoreCase(actual.getRol())
                  || "ADMIN".equalsIgnoreCase(actual.getRol()))) {
            response.sendRedirect("login.jsp?error=acceso_denegado");
            return;
        }

        String accion = request.getParameter("accion");
        String msg;

        if ("CREAR_LIBRO".equals(accion)) {
            msg = crear(request) ? "creado" : "error_crear";
        } else if ("ELIMINAR_LIBRO".equals(accion)) {
            String libroId = request.getParameter("libroId");
            msg = libroDAO.eliminar(libroId) ? "eliminado" : "error_eliminar";
        } else {
            msg = "accion_invalida";
        }

        response.sendRedirect("empleado.jsp?sec=inventario&msg=" + msg);
    }

    private boolean crear(HttpServletRequest request) {
        try {
            String titulo    = trim(request.getParameter("titulo"));
            String autor     = trim(request.getParameter("autor"));
            String isbn      = trim(request.getParameter("isbn"));
            String categoria = trim(request.getParameter("categoria"));
            String portada   = trim(request.getParameter("portadaUrl"));
            double precio    = parseDouble(request.getParameter("precio"), 0.0);
            int    stock     = parseInt   (request.getParameter("stock"),  0);
            int    paginas   = parseInt   (request.getParameter("paginas"),200);

            if (titulo.isEmpty() || autor.isEmpty() || isbn.isEmpty() || categoria.isEmpty()) return false;

            // Slug auto-generado a partir del título (mismo formato que el catálogo semilla)
            String id = slugify(titulo);

            Libro l = new Libro(id, titulo, autor, precio, portada, paginas, categoria);
            return libroDAO.insertar(l, isbn, stock);

        } catch (RuntimeException ex) {
            System.err.println("[LibroAdminServlet] crear: " + ex.getMessage());
            return false;
        }
    }

    private static String slugify(String s) {
        String n = Normalizer.normalize(s, Normalizer.Form.NFD)
                             .replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                             .toLowerCase();
        n = n.replaceAll("[^a-z0-9\\s-]", " ")
             .trim()
             .replaceAll("\\s+", "-");
        if (n.length() > 50) n = n.substring(0, 50);
        return n;
    }

    private static String trim(String s)    { return s == null ? "" : s.trim(); }
    private static int    parseInt(String s, int d)    { try { return Integer.parseInt(s); }    catch (Exception e) { return d; } }
    private static double parseDouble(String s, double d) { try { return Double.parseDouble(s); } catch (Exception e) { return d; } }
}
