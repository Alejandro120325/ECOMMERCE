package ec.edu.ups.controlador;

import ec.edu.ups.dao.UsuarioDAO;
import ec.edu.ups.modelo.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Set;

// --- ACTUALIZAR PERFIL (CLIENTE) ---
@WebServlet(name = "ActualizarPerfilServlet", urlPatterns = {"/ActualizarPerfilServlet"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,        // 1 MB en RAM
        maxFileSize       = 5L * 1024 * 1024,   // 5 MB por archivo
        maxRequestSize    = 10L * 1024 * 1024   // 10 MB total
)
public class ActualizarPerfilServlet extends HttpServlet {

    private static final Set<String> EXT_VALIDAS = Set.of(".jpg", ".jpeg", ".png", ".webp", ".gif");
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

        // --- READ FORM ---
        String nombre    = trim(request.getParameter("nombre"));
        String apellido  = trim(request.getParameter("apellido"));
        String telefono  = trim(request.getParameter("telefono"));
        String provincia = trim(request.getParameter("provincia"));
        String ciudad    = trim(request.getParameter("ciudad"));
        String direccion = trim(request.getParameter("direccion"));

        // --- VALIDATIONS ---
        if (nombre.length() < 2 || apellido.length() < 2) {
            response.sendRedirect("perfil.jsp?sec=editar&msg=datos_invalidos");
            return;
        }
        if (telefono.length() > 0 && !telefono.matches("(09[0-9]{8})|(0[2-7][0-9]{7})")) {
            response.sendRedirect("perfil.jsp?sec=editar&msg=telefono_invalido");
            return;
        }

        // --- UPDATE MODEL ---
        actual.setNombre(nombre);
        actual.setApellido(apellido);
        actual.setTelefono(telefono);
        actual.setProvincia(provincia);
        actual.setCiudad(ciudad);
        actual.setDireccion(direccion);

        boolean ok = dao.actualizarPerfil(actual);

        // --- PROFILE PHOTO UPLOAD (opcional) ---
        try {
            Part filePart = request.getPart("fotoPerfil");
            if (filePart != null && filePart.getSize() > 0) {
                String submitted = filePart.getSubmittedFileName();
                String fname     = (submitted == null) ? "" : Paths.get(submitted).getFileName().toString();
                int dot          = fname.lastIndexOf('.');
                String ext       = (dot >= 0) ? fname.substring(dot).toLowerCase() : "";
                if (!EXT_VALIDAS.contains(ext)) {
                    response.sendRedirect("perfil.jsp?sec=editar&msg=foto_formato");
                    return;
                }
                String nuevoNombre = "user_" + actual.getId() + "_" + System.currentTimeMillis() + ext;
                String realPath    = getServletContext().getRealPath("/uploads");
                Path destDir       = Paths.get(realPath);
                Files.createDirectories(destDir);
                try (InputStream in = filePart.getInputStream()) {
                    Files.copy(in, destDir.resolve(nuevoNombre), StandardCopyOption.REPLACE_EXISTING);
                }
                actual.setFotoPerfil(nuevoNombre);
                dao.actualizarFotoPerfil(actual.getId(), nuevoNombre);
            }
        } catch (Exception ex) {
            System.err.println("[ActualizarPerfilServlet] foto: " + ex.getMessage());
        }

        // --- OPTIONAL PASSWORD CHANGE ---
        String claveActual  = request.getParameter("claveActual");
        String claveNueva   = request.getParameter("claveNueva");
        String claveConfirm = request.getParameter("claveConfirm");
        if (claveNueva != null && !claveNueva.isBlank()) {
            if (claveActual == null || !claveActual.equals(actual.getClave())) {
                response.sendRedirect("perfil.jsp?sec=editar&msg=clave_actual_incorrecta");
                return;
            }
            if (claveNueva.length() < 8 || !claveNueva.equals(claveConfirm)) {
                response.sendRedirect("perfil.jsp?sec=editar&msg=clave_invalida");
                return;
            }
            if (dao.actualizarClave(actual.getId(), claveNueva)) {
                actual.setClave(claveNueva);
            }
        }

        // --- REFRESH SESSION ---
        session.setAttribute("usuarioActivo", actual);
        response.sendRedirect("perfil.jsp?sec=editar&msg=" + (ok ? "ok" : "error"));
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
}
