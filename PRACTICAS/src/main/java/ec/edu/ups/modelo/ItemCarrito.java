package ec.edu.ups.modelo;

import java.io.Serializable;

/**
 * FOLIO - Item del carrito de compras.
 * <p>
 * Compone un {@link Libro} con la cantidad solicitada por el cliente.
 * Encapsula el cálculo de subtotal de línea para evitar que esa lógica
 * se filtre a las capas superiores (servlet o JSP).
 */
public class ItemCarrito implements Serializable {

    private static final long serialVersionUID = 1L;

    private final Libro libro;
    private int cantidad;

    public ItemCarrito(Libro libro, int cantidad) {
        if (libro == null) {
            throw new IllegalArgumentException("El libro no puede ser nulo.");
        }
        if (cantidad < 1) {
            throw new IllegalArgumentException("La cantidad debe ser mayor a cero.");
        }
        this.libro = libro;
        this.cantidad = cantidad;
    }

    public Libro getLibro() { return libro; }

    public int getCantidad() { return cantidad; }

    /**
     * Cambia la cantidad de unidades del item. Se valida que sea positiva
     * — eliminar el item es responsabilidad de {@link Carrito}.
     */
    public void setCantidad(int cantidad) {
        if (cantidad < 1) {
            throw new IllegalArgumentException("La cantidad debe ser mayor a cero.");
        }
        this.cantidad = cantidad;
    }

    /** Subtotal de la línea: precio unitario * cantidad. */
    public double getSubtotal() {
        return libro.getPrecio() * cantidad;
    }
}
