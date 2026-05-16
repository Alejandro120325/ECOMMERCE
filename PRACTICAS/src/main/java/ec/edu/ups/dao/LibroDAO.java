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

    private static final String SQL_INSERT =
            "INSERT INTO tb_libro (id, titulo, autor, isbn, precio, stock, imagen, paginas, categoria) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SQL_DELETE =
            "DELETE FROM tb_libro WHERE id = ?";

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
     * Inserta un libro nuevo. Recibe también el ISBN y stock que no
     * están en el modelo {@link Libro}; el servlet de admin los
     * pasa como parámetros explícitos.
     */
    public boolean insertar(Libro libro, String isbn, int stock) {
        if (libro == null) return false;
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(SQL_INSERT)) {
            ps.setString(1, libro.getId());
            ps.setString(2, libro.getTitulo());
            ps.setString(3, libro.getAutor());
            ps.setString(4, isbn);
            ps.setDouble(5, libro.getPrecio());
            ps.setInt   (6, stock);
            ps.setString(7, libro.getImagen());
            ps.setInt   (8, libro.getPaginas());
            ps.setString(9, libro.getCategoria());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[LibroDAO] insertar: " + e.getMessage());
            return false;
        }
    }

    // ------------------------------------------------------------------
    // Descuentos (mutación de precio sobre PostgreSQL)
    // ------------------------------------------------------------------

    /**
     * Aplica un descuento porcentual al precio de todos los libros de
     * una categoría. Devuelve el número de filas afectadas.
     *
     * @param categoria slug de la categoría (latinoamericana, manga, ...)
     * @param porcentaje valor entre 1 y 90 (representa el % de descuento)
     */
    public int aplicarDescuentoCategoria(String categoria, double porcentaje) {
        if (porcentaje <= 0 || porcentaje >= 100) return 0;
        double factor = 1.0 - (porcentaje / 100.0);
        String sql = "UPDATE tb_libro SET precio = ROUND(precio * ?::numeric, 2) " +
                     "WHERE LOWER(categoria) = LOWER(?)";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, factor);
            ps.setString(2, categoria);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[LibroDAO] aplicarDescuentoCategoria: " + e.getMessage());
            return 0;
        }
    }

    /**
     * Aplica un descuento porcentual a un libro específico (por id/slug).
     */
    public int aplicarDescuentoLibro(String libroId, double porcentaje) {
        if (porcentaje <= 0 || porcentaje >= 100) return 0;
        double factor = 1.0 - (porcentaje / 100.0);
        String sql = "UPDATE tb_libro SET precio = ROUND(precio * ?::numeric, 2) WHERE id = ?";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, factor);
            ps.setString(2, libroId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[LibroDAO] aplicarDescuentoLibro: " + e.getMessage());
            return 0;
        }
    }

    /** Elimina un libro por su id (slug). */
    public boolean eliminar(String id) {
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(SQL_DELETE)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[LibroDAO] eliminar: " + e.getMessage());
            return false;
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
