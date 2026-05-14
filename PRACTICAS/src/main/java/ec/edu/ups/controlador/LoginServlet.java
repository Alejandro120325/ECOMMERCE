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

@WebServlet(name = "LoginServlet", value = "/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String correo = request.getParameter("correo");
        String clave = request.getParameter("clave");

        UsuarioDAO dao = new UsuarioDAO();
        Usuario usuarioLogueado = dao.validarLogin(correo, clave);

        if (usuarioLogueado != null) {
            // Credenciales correctas: Creamos la sesión
            HttpSession session = request.getSession();
            session.setAttribute("usuarioActivo", usuarioLogueado);
            // Redirigimos al inicio
            response.sendRedirect("index.jsp");
        } else {
            // Credenciales incorrectas: Volvemos al login con error
            response.sendRedirect("login.jsp?error=1");
        }
    }
}