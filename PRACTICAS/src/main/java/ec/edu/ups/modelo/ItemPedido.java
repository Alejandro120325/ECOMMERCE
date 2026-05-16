package ec.edu.ups.modelo;

import java.io.Serializable;

/**
 * FOLIO - Línea de detalle de un Pedido.
 * <p>
 * Refleja la fila de {@code tb_pedido_item}. Guarda el id de libro
 * (clave foránea) y un snapshot del precio unitario al momento de
 * la compra (importante: si el libro sube de precio luego, el
 * histórico del pedido se conserva).
 */
public class ItemPedido implements Serializable {

    private static final long serialVersionUID = 1L;

    private int    id;
    private int    pedidoId;
    private String libroId;
    private String tituloLibro;     // snapshot opcional para reportes
    private int    cantidad;
    private double precioUnitario;

    public ItemPedido() {}

    public ItemPedido(String libroId, int cantidad, double precioUnitario) {
        this.libroId        = libroId;
        this.cantidad       = cantidad;
        this.precioUnitario = precioUnitario;
    }

    public int    getId()             { return id; }
    public int    getPedidoId()       { return pedidoId; }
    public String getLibroId()        { return libroId; }
    public String getTituloLibro()    { return tituloLibro; }
    public int    getCantidad()       { return cantidad; }
    public double getPrecioUnitario() { return precioUnitario; }

    public double getSubtotal()       { return cantidad * precioUnitario; }

    public void setId(int id)                                 { this.id = id; }
    public void setPedidoId(int pedidoId)                     { this.pedidoId = pedidoId; }
    public void setLibroId(String libroId)                    { this.libroId = libroId; }
    public void setTituloLibro(String tituloLibro)            { this.tituloLibro = tituloLibro; }
    public void setCantidad(int cantidad)                     { this.cantidad = cantidad; }
    public void setPrecioUnitario(double precioUnitario)      { this.precioUnitario = precioUnitario; }
}
