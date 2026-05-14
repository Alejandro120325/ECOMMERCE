package ec.edu.ups.dao;

import ec.edu.ups.modelo.Usuario;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;

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