package ec.edu.ups.dao;

import ec.edu.ups.modelo.CatalogoLibros;
import ec.edu.ups.modelo.Libro;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * FOLIO - DAO de libros.
 * <p>
 * Realiza la consulta directa contra la tabla {@code libros} en
 * PostgreSQL. Si la conexión no está disponible o la tabla no
 * tiene aún registros, el DAO cae limpiamente sobre el catálogo en
 * memoria ({@link CatalogoLibros}) de modo que la aplicación es
 * 100 % usable en desarrollo sin necesidad de levantar la base.
 *
 * <p>El script {@code db/folio_libros.sql} crea la tabla y la
 * semilla. Una vez ejecutado, este DAO sirve los datos reales
 * desde PostgreSQL sin tocar el código.
 */
public class LibroDAO {

    private static final String SQL_LISTAR_TODOS =
            "SELECT id, titulo, autor, precio, imagen, paginas, categoria " +
            "FROM tb_libro ORDER BY categoria, titulo";

    private static final String SQL_POR_CATEGORIA =
            "SELECT id, titulo, autor, precio, imagen, paginas, categoria " +
            "FROM tb_libro WHERE LOWER(categoria) = LOWER(?) ORDER BY titulo";

    private static final String SQL_POR_ID =
            "SELECT id, titulo, autor, precio, imagen, paginas, categoria " +
            "FROM tb_libro WHERE id = ?";

    // ------------------------------------------------------------------
    // API pública
    // ------------------------------------------------------------------

    /** Devuelve todos los libros del catálogo. */
    public List<Libro> listarTodos() {
        try (Connection con = Conexion.getConnection()) {
            if (con == null) return new ArrayList<>(CatalogoLibros.getInstancia().obtenerTodos().values());
            try (PreparedStatement ps = con.prepareStatement(SQL_LISTAR_TODOS);
                 ResultSet rs = ps.executeQuery()) {
                List<Libro> libros = new ArrayList<>();
                while (rs.next()) libros.add(mapear(rs));
                if (libros.isEmpty()) {
                    return new ArrayList<>(CatalogoLibros.getInstancia().obtenerTodos().values());
                }
                return libros;
            }
        } catch (SQLException ex) {
            System.err.println("[LibroDAO] listarTodos() -> fallback memoria: " + ex.getMessage());
            return new ArrayList<>(CatalogoLibros.getInstancia().obtenerTodos().values());
        }
    }

    /**
     * Filtra libros por categoría (slug — case-insensitive). Si la
     * categoría es vacía o {@code "todas"} devuelve todo el catálogo.
     */
    public List<Libro> listarPorCategoria(String categoria) {
        if (categoria == null || categoria.isBlank() || "todas".equalsIgnoreCase(categoria)) {
            return listarTodos();
        }
        try (Connection con = Conexion.getConnection()) {
            if (con == null) return filtrarMemoria(categoria);
            try (PreparedStatement ps = con.prepareStatement(SQL_POR_CATEGORIA)) {
                ps.setString(1, categoria.trim());
                try (ResultSet rs = ps.executeQuery()) {
                    List<Libro> libros = new ArrayList<>();
                    while (rs.next()) libros.add(mapear(rs));
                    if (libros.isEmpty()) return filtrarMemoria(categoria);
                    return libros;
                }
            }
        } catch (SQLException ex) {
            System.err.println("[LibroDAO] listarPorCategoria() -> fallback memoria: " + ex.getMessage());
            return filtrarMemoria(categoria);
        }
    }

    /** Devuelve un libro por su id de negocio, o {@code null} si no existe. */
    public Libro buscarPorId(String id) {
        if (id == null) return null;
        try (Connection con = Conexion.getConnection()) {
            if (con == null) return CatalogoLibros.getInstancia().buscarPorId(id);
            try (PreparedStatement ps = con.prepareStatement(SQL_POR_ID)) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return mapear(rs);
                    return CatalogoLibros.getInstancia().buscarPorId(id);
                }
            }
        } catch (SQLException ex) {
            System.err.println("[LibroDAO] buscarPorId() -> fallback memoria: " + ex.getMessage());
            return CatalogoLibros.getInstancia().buscarPorId(id);
        }
    }

    /**
     * Devuelve el catálogo agrupado por categoría (clave = slug).
     * Útil para renderizar la página principal con todas las
     * secciones de un solo recorrido.
     */
    public Map<String, List<Libro>> agruparPorCategoria() {
        Map<String, List<Libro>> mapa = new LinkedHashMap<>();
        for (Libro l : listarTodos()) {
            mapa.computeIfAbsent(l.getCategoria(), k -> new ArrayList<>()).add(l);
        }
        return mapa;
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    private Libro mapear(ResultSet rs) throws SQLException {
        return new Libro(
                rs.getString("id"),
                rs.getString("titulo"),
                rs.getString("autor"),
                rs.getDouble("precio"),
                rs.getString("imagen"),
                rs.getInt("paginas"),
                rs.getString("categoria")
        );
    }

    private List<Libro> filtrarMemoria(String categoria) {
        List<Libro> out = new ArrayList<>();
        for (Libro l : CatalogoLibros.getInstancia().obtenerTodos().values()) {
            if (categoria.equalsIgnoreCase(l.getCategoria())) out.add(l);
        }
        return out;
    }
}
