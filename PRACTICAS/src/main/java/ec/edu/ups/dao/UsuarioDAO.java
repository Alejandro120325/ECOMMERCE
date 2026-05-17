package ec.edu.ups.dao;

import ec.edu.ups.modelo.Usuario;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    public boolean registrarUsuario(Usuario u) {
        String sql = "INSERT INTO tb_usuario (nombre, apellido, cedula, fecha_nacimiento, estado_civil, genero, provincia, ciudad, direccion, telefono, correo, clave, foto_perfil) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        boolean registrado = false;

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getNombre());
            ps.setString(2, u.getApellido());
            ps.setString(3, u.getCedula());
            ps.setDate(4, Date.valueOf(u.getFechaNacimiento()));
            ps.setString(5, u.getEstadoCivil());
            ps.setString(6, u.getGenero());
            ps.setString(7, u.getProvincia());
            ps.setString(8, u.getCiudad());
            ps.setString(9, u.getDireccion());
            ps.setString(10, u.getTelefono());
            ps.setString(11, u.getCorreo());
            ps.setString(12, u.getClave());
            ps.setString(13, u.getFotoPerfil());

            registrado = ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error al registrar en la BD: " + e.getMessage());
        }

        return registrado;
    }

    // ------------------------------------------------------------------
    // Gestión administrativa (admin dashboard)
    // ------------------------------------------------------------------

    /**
     * Lista todas las cuentas registradas. Implementación defensiva:
     * intenta primero con la columna {@code activo} (esquema actual);
     * si la columna no existe en la base (instalaciones antiguas), cae
     * a una segunda consulta más simple para no perder el listado.
     */
    public List<Usuario> listarTodos() {
        final String sqlConActivo =
            "SELECT id, nombre, apellido, cedula, correo, rol, activo " +
            "FROM tb_usuario ORDER BY rol, nombre";
        final String sqlSinActivo =
            "SELECT id, nombre, apellido, cedula, correo, rol " +
            "FROM tb_usuario ORDER BY rol, nombre";

        try (Connection con = Conexion.getConnection()) {
            if (con == null) {
                System.err.println("[UsuarioDAO] sin conexión a PostgreSQL — devolviendo lista vacía.");
                return new ArrayList<>();
            }
            try {
                return ejecutarListado(con, sqlConActivo, true);
            } catch (SQLException ex1) {
                System.err.println("[UsuarioDAO] reintentando sin columna 'activo': " + ex1.getMessage());
                try {
                    return ejecutarListado(con, sqlSinActivo, false);
                } catch (SQLException ex2) {
                    System.err.println("[UsuarioDAO] listarTodos fallback falló: " + ex2.getMessage());
                    return new ArrayList<>();
                }
            }
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] listarTodos error de conexión: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    private List<Usuario> ejecutarListado(Connection con, String sql, boolean leerActivo)
            throws SQLException {
        List<Usuario> out = new ArrayList<>();
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Usuario u = new Usuario();
                u.setId(rs.getInt("id"));
                u.setNombre(rs.getString("nombre"));
                u.setApellido(rs.getString("apellido"));
                u.setCedula(rs.getString("cedula"));
                u.setCorreo(rs.getString("correo"));
                u.setRol(rs.getString("rol"));
                u.setActivo(leerActivo ? rs.getBoolean("activo") : true);
                out.add(u);
            }
        }
        return out;
    }

    /** Suspende ({@code activo=false}) o reactiva ({@code activo=true}) una cuenta. */
    public boolean cambiarEstado(int id, boolean activo) {
        String sql = "UPDATE tb_usuario SET activo = ? WHERE id = ?";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, activo);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] cambiarEstado: " + e.getMessage());
            return false;
        }
    }

    /** Elimina por completo una cuenta. Falla limpiamente si hay FK rota. */
    public boolean eliminar(int id) {
        String sql = "DELETE FROM tb_usuario WHERE id = ?";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] eliminar: " + e.getMessage());
            return false;
        }
    }

    // --- UPDATE PROFILE ---
    public boolean actualizarPerfil(Usuario u) {
        String sql = "UPDATE tb_usuario SET nombre=?, apellido=?, telefono=?, " +
                     "provincia=?, ciudad=?, direccion=? WHERE id=?";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getNombre());
            ps.setString(2, u.getApellido());
            ps.setString(3, u.getTelefono());
            ps.setString(4, u.getProvincia());
            ps.setString(5, u.getCiudad());
            ps.setString(6, u.getDireccion());
            ps.setInt   (7, u.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] actualizarPerfil: " + e.getMessage());
            return false;
        }
    }

    // --- UPDATE PROFILE PHOTO ---
    public boolean actualizarFotoPerfil(int id, String fotoPerfil) {
        String sql = "UPDATE tb_usuario SET foto_perfil=? WHERE id=?";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, fotoPerfil);
            ps.setInt   (2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] actualizarFotoPerfil: " + e.getMessage());
            return false;
        }
    }

    // --- UPDATE PASSWORD ---
    public boolean actualizarClave(int id, String nuevaClave) {
        String sql = "UPDATE tb_usuario SET clave=? WHERE id=?";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nuevaClave);
            ps.setInt   (2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] actualizarClave: " + e.getMessage());
            return false;
        }
    }

    public Usuario validarLogin(String correo, String clave) {
        Usuario usr = null;
        String sql = "SELECT * FROM tb_usuario WHERE correo = ? AND clave = ?";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, correo);
            ps.setString(2, clave);

            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    usr = new Usuario();
                    usr.setId(rs.getInt("id"));
                    usr.setNombre(rs.getString("nombre"));
                    usr.setApellido(rs.getString("apellido"));
                    usr.setCorreo(rs.getString("correo"));
                    usr.setRol(rs.getString("rol")); // <-- LEE EL ROL DESDE POSTGRES
                }
            }
        } catch (SQLException e) {
            System.err.println("Error en login: " + e.getMessage());
        }
        return usr;
    }
}