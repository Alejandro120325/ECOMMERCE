package ec.edu.ups.controlador;

import ec.edu.ups.dao.UsuarioDAO;
import ec.edu.ups.modelo.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * FOLIO - Gestión administrativa de cuentas.
 * <p>
 * Sólo accesible para usuarios con rol {@code ADMIN}. Recibe POST con
 * los siguientes valores de {@code accion}:
 * <ul>
 *   <li>{@code SUSPENDER}  — marca {@code activo=false}</li>
 *   <li>{@code ACTIVAR}    — marca {@code activo=true}</li>
 *   <li>{@code ELIMINAR}   — borra la fila</li>
 * </ul>
 * Tras la operación redirige a {@code admin.jsp?sec=usuarios} con un
 * mensaje informativo opcional (?msg=...).
 */
@WebServlet(name = "GestionUsuariosServlet", urlPatterns = {"/GestionUsuariosServlet"})
public class GestionUsuariosServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // ----- Guardia de seguridad: SOLO ADMIN -----
        HttpSession session = request.getSession(false);
        Usuario actual = (session == null) ? null : (Usuario) session.getAttribute("usuarioActivo");
        if (actual == null || !"ADMIN".equalsIgnoreCase(actual.getRol())) {
            response.sendRedirect("login.jsp?error=acceso_denegado");
            return;
        }

        String accion = request.getParameter("accion");
        int id        = parseInt(request.getParameter("id"));
        String msg;

        // Impedimos que el admin se modifique a sí mismo accidentalmente.
        if (id == actual.getId()) {
            response.sendRedirect("admin.jsp?sec=usuarios&msg=no_self");
            return;
        }

        switch (String.valueOf(accion)) {
            case "SUSPENDER":
                msg = usuarioDAO.cambiarEstado(id, false) ? "suspendido" : "error";
                break;
            case "ACTIVAR":
                msg = usuarioDAO.cambiarEstado(id, true) ? "activado" : "error";
                break;
            case "ELIMINAR":
                msg = usuarioDAO.eliminar(id) ? "eliminado" : "error";
                break;
            default:
                msg = "accion_invalida";
        }

        response.sendRedirect("admin.jsp?sec=usuarios&msg=" + msg);
    }

    private int parseInt(String s) {
        if (s == null) return -1;
        try { return Integer.parseInt(s); }
        catch (NumberFormatException ex) { return -1; }
    }
}
