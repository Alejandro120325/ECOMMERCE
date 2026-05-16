package ec.edu.ups.controlador;

import ec.edu.ups.dao.LibroDAO;
import ec.edu.ups.modelo.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * FOLIO - Aplicador de descuentos (módulo Empleado).
 * <p>
 * Recibe un formulario POST tradicional con:
 * <ul>
 *   <li>{@code modo} = {@code "categoria"} o {@code "libro"}</li>
 *   <li>{@code categoria}  — slug, requerido si modo=categoria</li>
 *   <li>{@code libroId}    — id slug, requerido si modo=libro</li>
 *   <li>{@code porcentaje} — número entre 1 y 90</li>
 * </ul>
 * Ejecuta el UPDATE sobre {@code tb_libro} y redirige a
 * {@code empleado.jsp?sec=descuentos&msg=<resultado>}.
 */
@WebServlet(name = "AplicarDescuentoServlet", urlPatterns = {"/AplicarDescuentoServlet"})
public class AplicarDescuentoServlet extends HttpServlet {

    private final LibroDAO libroDAO = new LibroDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // ---- Seguridad: sólo EMPLEADO / ADMIN ----
        HttpSession session = request.getSession(false);
        Usuario u = (session == null) ? null : (Usuario) session.getAttribute("usuarioActivo");
        if (u == null
            || !("EMPLEADO".equalsIgnoreCase(u.getRol())
              || "ADMIN".equalsIgnoreCase(u.getRol()))) {
            response.sendRedirect("login.jsp?error=acceso_denegado");
            return;
        }

        String modo       = request.getParameter("modo");
        String categoria  = request.getParameter("categoria");
        String libroId    = request.getParameter("libroId");
        double porcentaje = parseDouble(request.getParameter("porcentaje"), -1);

        if (porcentaje <= 0 || porcentaje >= 100) {
            response.sendRedirect("empleado.jsp?sec=descuentos&msg=pct_invalido");
            return;
        }

        int filas;
        if ("categoria".equalsIgnoreCase(modo)) {
            if (categoria == null || categoria.isBlank()) {
                response.sendRedirect("empleado.jsp?sec=descuentos&msg=falta_categoria");
                return;
            }
            filas = libroDAO.aplicarDescuentoCategoria(categoria, porcentaje);

        } else if ("libro".equalsIgnoreCase(modo)) {
            if (libroId == null || libroId.isBlank()) {
                response.sendRedirect("empleado.jsp?sec=descuentos&msg=falta_libro");
                return;
            }
            filas = libroDAO.aplicarDescuentoLibro(libroId.trim(), porcentaje);

        } else {
            response.sendRedirect("empleado.jsp?sec=descuentos&msg=modo_invalido");
            return;
        }

        String msg = (filas > 0) ? ("ok_" + filas) : "sin_cambios";
        response.sendRedirect("empleado.jsp?sec=descuentos&msg=" + msg);
    }

    private static double parseDouble(String s, double def) {
        if (s == null) return def;
        try { return Double.parseDouble(s.trim()); }
        catch (NumberFormatException ex) { return def; }
    }
}
