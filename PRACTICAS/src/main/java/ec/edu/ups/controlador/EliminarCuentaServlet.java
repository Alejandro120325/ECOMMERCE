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

// --- ELIMINAR CUENTA (CLIENTE) ---
@WebServlet(name = "EliminarCuentaServlet", urlPatterns = {"/EliminarCuentaServlet"})
public class EliminarCuentaServlet extends HttpServlet {

    private final UsuarioDAO dao = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Usuario actual = (session == null) ? null : (Usuario) session.getAttribute("usuarioActivo");
        if (actual == null) {
            response.sendRedirect("login.jsp?error=requiere_sesion");
            return;
        }

        // --- DOUBLE CONFIRMATION ---
        String confirmacion = request.getParameter("confirmar");
        String claveActual  = request.getParameter("claveActual");
        if (!"ELIMINAR".equals(confirmacion)) {
            response.sendRedirect("perfil.jsp?sec=eliminar&msg=confirma_texto");
            return;
        }
        if (claveActual == null || !claveActual.equals(actual.getClave())) {
            response.sendRedirect("perfil.jsp?sec=eliminar&msg=clave_incorrecta");
            return;
        }

        // --- DELETE FROM DB ---
        boolean borrado = dao.eliminar(actual.getId());
        if (!borrado) {
            response.sendRedirect("perfil.jsp?sec=eliminar&msg=error_borrado");
            return;
        }

        // --- KILL SESSION + GOODBYE ---
        session.invalidate();
        response.sendRedirect("index.jsp?cuenta=eliminada");
    }
}
