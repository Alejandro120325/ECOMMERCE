package ec.edu.ups.controlador;

import ec.edu.ups.dao.LibroDAO;
import ec.edu.ups.modelo.Libro;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * FOLIO - Filtro de libros por categoría.
 * <p>
 * Recibe el parámetro {@code categoria} (slug) por query string,
 * consulta los libros correspondientes en {@link LibroDAO} (que a su
 * vez golpea PostgreSQL) y reenvía mediante {@code RequestDispatcher}
 * a {@code catalogo.jsp}.
 *
 * <p>Si {@code categoria} es nula, vacía o {@code "todas"}, devuelve
 * el catálogo completo. El nombre legible de la categoría se calcula
 * aquí y se publica como atributo de petición para que el JSP
 * renderice un título humano.
 */
@WebServlet(name = "FiltrarLibrosServlet", urlPatterns = {"/FiltrarLibrosServlet"})
public class FiltrarLibrosServlet extends HttpServlet {

    private final LibroDAO libroDAO = new LibroDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String categoria = request.getParameter("categoria");

        List<Libro> libros = libroDAO.listarPorCategoria(categoria);

        request.setAttribute("libros",          libros);
        request.setAttribute("categoriaSlug",   categoria == null ? "todas" : categoria);
        request.setAttribute("categoriaNombre", nombreLegible(categoria));

        RequestDispatcher rd = request.getRequestDispatcher("catalogo.jsp");
        rd.forward(request, response);
    }

    /** Traduce el slug de categoría a un título legible para el usuario. */
    private String nombreLegible(String slug) {
        if (slug == null || slug.isBlank() || "todas".equalsIgnoreCase(slug)) {
            return "Catálogo completo";
        }
        switch (slug.toLowerCase()) {
            case "latinoamericana": return "Literatura Latinoamericana";
            case "clasicos":        return "Clásicos Mundiales";
            case "ciencia":         return "Ciencia Ficción y Distopía";
            case "tecnologia":      return "Tecnología e Ingeniería";
            case "historia":        return "Historia y Filosofía";
            case "fantasia":        return "Fantasía y Épica";
            case "biografias":      return "Biografías";
            case "desarrollo":      return "Desarrollo Personal";
            case "manga":           return "Manga";
            default:                return slug;
        }
    }
}
