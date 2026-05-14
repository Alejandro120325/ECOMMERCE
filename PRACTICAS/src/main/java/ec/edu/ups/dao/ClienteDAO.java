package ec.edu.ups.dao;
import ec.edu.ups.modelo.Cliente;
import java.sql.PreparedStatement;

public class ClienteDAO {
    public boolean insertarCliente(Cliente c) {
        String sql = "INSERT INTO clientes (nombre, cedula, estado_civil, correo, password) VALUES (?,?,?,?,?)";
        try (var conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getNombre());
            ps.setString(2, c.getCedula());
            ps.setString(3, c.getEstadoCivil());
            ps.setString(4, c.getCorreo());
            ps.setString(5, c.getPassword());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}