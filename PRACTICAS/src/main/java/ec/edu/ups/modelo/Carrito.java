package ec.edu.ups.modelo;

import java.io.Serializable;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * FOLIO - Modelo de Carrito de compras (server-side).
 * <p>
 * Esta clase es el agregado raíz del carrito: contiene los {@link ItemCarrito}
 * indexados por id de libro y centraliza los cálculos monetarios (subtotal,
 * IVA del 15 % e importe total).
 * <p>
 * Una instancia se asocia a una {@code HttpSession} bajo el atributo
 * {@code "carrito"} y se manipula exclusivamente desde el
 * {@code CarritoServlet}, garantizando consistencia entre peticiones.
 * <p>
 * Se usa {@link LinkedHashMap} para preservar el orden de inserción
 * (el frontend respeta ese orden al pintar el drawer).
 */
public class Carrito implements Serializable {

    private static final long serialVersionUID = 1L;

    /** Porcentaje de IVA aplicado en Ecuador (15 %). */
    public static final double IVA_PORCENTAJE = 0.15;

    private final Map<String, ItemCarrito> items = new LinkedHashMap<>();

    // ------------------------------------------------------------------
    // Operaciones de mutación
    // ------------------------------------------------------------------

    /**
     * Agrega un libro al carrito. Si el libro ya estaba presente, incrementa
     * su cantidad en uno; si no, lo añade con cantidad inicial 1.
     */
    public void agregar(Libro libro) {
        if (libro == null) return;
        ItemCarrito existente = items.get(libro.getId());
        if (existente != null) {
            existente.setCantidad(existente.getCantidad() + 1);
        } else {
            items.put(libro.getId(), new ItemCarrito(libro, 1));
        }
    }

    /** Elimina por completo la línea correspondiente al id dado. */
    public void eliminar(String libroId) {
        if (libroId == null) return;
        items.remove(libroId);
    }

    /**
     * Disminuye en uno la cantidad del item. Si la cantidad resultante
     * fuese cero o negativa, elimina la línea por completo.
     */
    public void disminuir(String libroId) {
        if (libroId == null) return;
        ItemCarrito item = items.get(libroId);
        if (item == null) return;
        int nueva = item.getCantidad() - 1;
        if (nueva <= 0) items.remove(libroId);
        else item.setCantidad(nueva);
    }

    /**
     * Actualiza la cantidad de una línea. Si la nueva cantidad es menor o
     * igual a cero, la línea se elimina automáticamente (comportamiento
     * típico de los carritos comerciales).
     */
    public void actualizarCantidad(String libroId, int nuevaCantidad) {
        if (libroId == null) return;
        ItemCarrito item = items.get(libroId);
        if (item == null) return;
        if (nuevaCantidad <= 0) {
            items.remove(libroId);
        } else {
            item.setCantidad(nuevaCantidad);
        }
    }

    /** Vacía completamente el carrito (post-pago o acción del usuario). */
    public void vaciar() {
        items.clear();
    }

    // ------------------------------------------------------------------
    // Consultas
    // ------------------------------------------------------------------

    public Collection<ItemCarrito> getItems() {
        return Collections.unmodifiableCollection(items.values());
    }

    public boolean estaVacio() { return items.isEmpty(); }

    /** Cantidad total de unidades (suma de cantidades de todas las líneas). */
    public int getCantidadItems() {
        int total = 0;
        for (ItemCarrito it : items.values()) total += it.getCantidad();
        return total;
    }

    /** Suma de los subtotales de cada línea, sin IVA. */
    public double getSubtotal() {
        double total = 0.0;
        for (ItemCarrito it : items.values()) total += it.getSubtotal();
        return redondear(total);
    }

    /** IVA del 15 % calculado sobre el subtotal. */
    public double getIva() {
        return redondear(getSubtotal() * IVA_PORCENTAJE);
    }

    /** Importe total = subtotal + IVA. */
    public double getTotal() {
        return redondear(getSubtotal() + getIva());
    }

    private double redondear(double valor) {
        return Math.round(valor * 100.0) / 100.0;
    }
}
