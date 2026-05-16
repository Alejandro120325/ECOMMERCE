package ec.edu.ups.modelo;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * FOLIO - Modelo de un Pedido (cabecera).
 * <p>
 * Refleja la fila de {@code tb_pedido} más sus líneas asociadas
 * (lista de {@link ItemPedido}). Es Serializable porque puede
 * viajar por la sesión durante el flujo de pago.
 */
public class Pedido implements Serializable {

    private static final long serialVersionUID = 1L;

    private int       id;
    private Integer   usuarioId;          // puede ser null si se compró como invitado
    private Timestamp fecha;
    private double    subtotal;
    private double    iva;
    private double    total;
    private String    estado;             // PENDIENTE / PAGADO / ENVIADO / ENTREGADO / CANCELADO
    private String    marcaTarjeta;       // VISA, MASTERCARD, AMEX...
    private String    ultimos4;           // últimos 4 dígitos de la tarjeta
    private List<ItemPedido> items = new ArrayList<>();

    public Pedido() {}

    public int getId()                       { return id; }
    public Integer getUsuarioId()            { return usuarioId; }
    public Timestamp getFecha()              { return fecha; }
    public double getSubtotal()              { return subtotal; }
    public double getIva()                   { return iva; }
    public double getTotal()                 { return total; }
    public String getEstado()                { return estado; }
    public String getMarcaTarjeta()          { return marcaTarjeta; }
    public String getUltimos4()              { return ultimos4; }
    public List<ItemPedido> getItems()       { return items; }

    public void setId(int id)                          { this.id = id; }
    public void setUsuarioId(Integer usuarioId)        { this.usuarioId = usuarioId; }
    public void setFecha(Timestamp fecha)              { this.fecha = fecha; }
    public void setSubtotal(double subtotal)           { this.subtotal = subtotal; }
    public void setIva(double iva)                     { this.iva = iva; }
    public void setTotal(double total)                 { this.total = total; }
    public void setEstado(String estado)               { this.estado = estado; }
    public void setMarcaTarjeta(String marcaTarjeta)   { this.marcaTarjeta = marcaTarjeta; }
    public void setUltimos4(String ultimos4)           { this.ultimos4 = ultimos4; }
    public void setItems(List<ItemPedido> items)       { this.items = items; }
}
