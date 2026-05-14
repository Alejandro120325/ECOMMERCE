package ec.edu.ups.controlador;

import ec.edu.ups.dao.UsuarioDAO;
import ec.edu.ups.modelo.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;

@WebServlet(name = "RegistroServlet", value = "/RegistroServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 5,       // 5MB
        maxRequestSize = 1024 * 1024 * 10    // 10MB
)
public class RegistroServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Asegurar que los caracteres especiales (tildes, ñ) se guarden bien
        request.setCharacterEncoding("UTF-8");

        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String cedula = request.getParameter("cedula");
        String fechaNacimiento = request.getParameter("fechaNacimiento");
        String estadoCivil = request.getParameter("estadoCivil");
        String genero = request.getParameter("genero");
        String provincia = request.getParameter("provincia");
        String ciudad = request.getParameter("ciudad");
        String direccion = request.getParameter("direccion");
        String telefono = request.getParameter("telefono");
        String correo = request.getParameter("correo");
        String clave = request.getParameter("clave");

        // Lógica de subida de imagen de perfil
        Part filePart = request.getPart("foto");
        String fileName = "";

        if (filePart != null && filePart.getSize() > 0) {
            fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            // Ruta real de la carpeta uploads en el servidor de Tomcat
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }
            filePart.write(uploadPath + File.separator + fileName);
        }

        // Crear el objeto y enviarlo al DAO
        Usuario u = new Usuario(nombre, apellido, cedula, fechaNacimiento, estadoCivil, genero, provincia, ciudad, direccion, telefono, correo, clave, fileName);
        UsuarioDAO dao = new UsuarioDAO();

        boolean exito = dao.registrarUsuario(u);

        // Preparar respuesta para el JSP
        if (exito) {
            request.setAttribute("exito", true);
        } else {
            request.setAttribute("exito", false);
            request.setAttribute("mensaje", "Ocurrió un error al guardar en la base de datos (revisa que la cédula o correo no existan ya).");
        }

        request.setAttribute("usuario", u);
        request.getRequestDispatcher("respuesta.jsp").forward(request, response);
    }
}