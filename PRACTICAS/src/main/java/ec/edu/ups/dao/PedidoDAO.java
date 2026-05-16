package ec.edu.ups.dao;

import ec.edu.ups.modelo.Carrito;
import ec.edu.ups.modelo.ItemCarrito;
import ec.edu.ups.modelo.ItemPedido;
import ec.edu.ups.modelo.Pedido;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * FOLIO - DAO de Pedidos.
 * <p>
 * Persiste un {@link Pedido} con sus líneas dentro de una única
 * transacción JDBC: si algo falla, rollback completo.
 * <p>
 * Lectura: lista los pedidos de un usuario para que pueda ver
 * su historial en su perfil. La carga de las líneas se realiza
 * en una segunda consulta para evitar joins complejos a esta
 * escala.
 */
public class PedidoDAO {

    private static final String SQL_INSERT_PEDIDO =
            "INSERT INTO tb_pedido (usuario_id, subtotal, iva, total, estado, marca_tarjeta, ultimos4) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String SQL_INSERT_ITEM =
            "INSERT INTO tb_pedido_item (pedido_id, libro_id, cantidad, precio_unitario) " +
            "VALUES (?, ?, ?, ?)";

    private static final String SQL_LISTAR_USUARIO =
            "SELECT id, usuario_id, fecha, subtotal, iva, total, estado, marca_tarjeta, ultimos4 " +
            "FROM tb_pedido WHERE usuario_id = ? ORDER BY fecha DESC";

    private static final String SQL_LISTAR_ITEMS =
            "SELECT i.id, i.pedido_id, i.libro_id, i.cantidad, i.precio_unitario, l.titulo " +
            "FROM tb_pedido_item i LEFT JOIN tb_libro l ON l.id = i.libro_id " +
            "WHERE i.pedido_id = ?";

    /**
     * Crea un pedido a partir del carrito + datos de pago. Devuelve
     * el id generado o {@code -1} si la operación falla.
     */
    public int crearDesdeCarrito(Carrito carrito, Integer usuarioId,
                                 String marcaTarjeta, String ultimos4) {
        if (carrito == null || carrito.estaVacio()) return -1;

        try (Connection con = Conexion.getConnection()) {
            if (con == null) return -1;
            con.setAutoCommit(false);
            try {
                int pedidoId = insertarCabecera(con, carrito, usuarioId, marcaTarjeta, ultimos4);
                if (pedidoId < 0) { con.rollback(); return -1; }

                insertarItems(con, pedidoId, carrito);
                con.commit();
                return pedidoId;
            } catch (SQLException ex) {
                con.rollback();
                System.err.println("[PedidoDAO] rollback: " + ex.getMessage());
                return -1;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (SQLException ex) {
            System.err.println("[PedidoDAO] crearDesdeCarrito: " + ex.getMessage());
            return -1;
        }
    }

    /** Lista pedidos de un usuario incluyendo sus líneas. */
    public List<Pedido> listarPorUsuario(int usuarioId) {
        List<Pedido> pedidos = new ArrayList<>();
        try (Connection con = Conexion.getConnection()) {
            if (con == null) return pedidos;
            try (PreparedStatement ps = con.prepareStatement(SQL_LISTAR_USUARIO)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) pedidos.add(mapear(rs));
                }
            }
            // Cargar items de cada pedido
            for (Pedido p : pedidos) {
                try (PreparedStatement psi = con.prepareStatement(SQL_LISTAR_ITEMS)) {
                    psi.setInt(1, p.getId());
                    try (ResultSet rs = psi.executeQuery()) {
                        List<ItemPedido> items = new ArrayList<>();
                        while (rs.next()) {
                            ItemPedido it = new ItemPedido();
                            it.setId(rs.getInt("id"));
                            it.setPedidoId(rs.getInt("pedido_id"));
                            it.setLibroId(rs.getString("libro_id"));
                            it.setTituloLibro(rs.getString("titulo"));
                            it.setCantidad(rs.getInt("cantidad"));
                            it.setPrecioUnitario(rs.getDouble("precio_unitario"));
                            items.add(it);
                        }
                        p.setItems(items);
                    }
                }
            }
        } catch (SQLException ex) {
            System.err.println("[PedidoDAO] listarPorUsuario: " + ex.getMessage());
        }
        return pedidos;
    }

    // ------------------------------------------------------------------
    // Helpers privados
    // ------------------------------------------------------------------

    private int insertarCabecera(Connection con, Carrito carrito, Integer usuarioId,
                                 String marca, String ultimos4) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                SQL_INSERT_PEDIDO, Statement.RETURN_GENERATED_KEYS)) {
            if (usuarioId == null) ps.setNull(1, java.sql.Types.INTEGER);
            else                    ps.setInt(1, usuarioId);
            ps.setDouble(2, carrito.getSubtotal());
            ps.setDouble(3, carrito.getIva());
            ps.setDouble(4, carrito.getTotal());
            ps.setString(5, "PAGADO");
            ps.setString(6, marca);
            ps.setString(7, ultimos4);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
                return -1;
            }
        }
    }

    private void insertarItems(Connection con, int pedidoId, Carrito carrito) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(SQL_INSERT_ITEM)) {
            for (ItemCarrito ic : carrito.getItems()) {
                ps.setInt   (1, pedidoId);
                ps.setString(2, ic.getLibro().getId());
                ps.setInt   (3, ic.getCantidad());
                ps.setDouble(4, ic.getLibro().getPrecio());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private Pedido mapear(ResultSet rs) throws SQLException {
        Pedido p = new Pedido();
        p.setId(rs.getInt("id"));
        int u = rs.getInt("usuario_id");
        p.setUsuarioId(rs.wasNull() ? null : u);
        p.setFecha(rs.getTimestamp("fecha"));
        p.setSubtotal(rs.getDouble("subtotal"));
        p.setIva(rs.getDouble("iva"));
        p.setTotal(rs.getDouble("total"));
        p.setEstado(rs.getString("estado"));
        p.setMarcaTarjeta(rs.getString("marca_tarjeta"));
        p.setUltimos4(rs.getString("ultimos4"));
        return p;
    }
}
