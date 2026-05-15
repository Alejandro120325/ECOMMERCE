package ec.edu.ups.modelo;

import java.io.Serializable;

/**
 * FOLIO - Modelo de Libro.
 * <p>
 * Representa una unidad del catálogo. Inmutable a nivel de identidad
 * (el campo {@code id} actúa como clave de negocio) pero mutable a
 * efectos de mantenimiento (precio, stock, etc.).
 * <p>
 * Implementa {@link Serializable} porque las instancias se mantienen
 * dentro de {@link ItemCarrito}, que a su vez se persiste en la
 * {@code HttpSession} bajo el contenedor de servlets.
 */
public class Libro implements Serializable {

    private static final long serialVersionUID = 1L;

    private String id;
    private String titulo;
    private String autor;
    private double precio;
    private String imagen;
    private int paginas;
    private String categoria;

    public Libro() {}

    public Libro(String id, String titulo, String autor, double precio,
                 String imagen, int paginas, String categoria) {
        this.id = id;
        this.titulo = titulo;
        this.autor = autor;
        this.precio = precio;
        this.imagen = imagen;
        this.paginas = paginas;
        this.categoria = categoria;
    }

    public String getId() { return id; }
    public String getTitulo() { return titulo; }
    public String getAutor() { return autor; }
    public double getPrecio() { return precio; }
    public String getImagen() { return imagen; }
    public int getPaginas() { return paginas; }
    public String getCategoria() { return categoria; }

    public void setId(String id) { this.id = id; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public void setAutor(String autor) { this.autor = autor; }
    public void setPrecio(double precio) { this.precio = precio; }
    public void setImagen(String imagen) { this.imagen = imagen; }
    public void setPaginas(int paginas) { this.paginas = paginas; }
    public void setCategoria(String categoria) { this.categoria = categoria; }
}
