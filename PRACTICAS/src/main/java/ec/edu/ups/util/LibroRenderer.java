package ec.edu.ups.util;

import ec.edu.ups.modelo.Libro;

import java.util.Locale;

/**
 * FOLIO - Renderer reutilizable de tarjetas de libro 3D.
 * <p>
 * Centraliza la generación del HTML de un {@code .libro-card} para
 * que index.jsp y catalogo.jsp produzcan exactamente la misma
 * estructura sin duplicar scriptlets. Toda la rotación 3D vive en
 * CSS puro (ver {@code estilos.css}); este método solo emite la
 * estructura de seis caras + el formulario POST tradicional para
 * añadir al carrito.
 */
public final class LibroRenderer {

    private LibroRenderer() { /* clase utilitaria */ }

    /**
     * @param l         libro a renderizar
     * @param urlActual URL del recurso actual — se inyecta como hidden
     *                  field {@code redirect} para volver a la misma
     *                  página tras el sendRedirect del servlet.
     */
    public static String render(Libro l, String urlActual) {
        if (l == null) return "";

        // Grosor del lomo en función de las páginas (acotado entre 18 y 70 px).
        int grosor = Math.max(18, Math.min(70, l.getPaginas() / 15));
        String tituloLomo = l.getTitulo().length() > 28
                ? l.getTitulo().substring(0, 27) + "…"
                : l.getTitulo();

        StringBuilder sb = new StringBuilder(1500);
        sb.append("<article class=\"libro-card\">");

        // ---- Escenario 3D ----
        sb.append("<div class=\"portada-contenedor\">");
        sb.append("<div class=\"libro-3d\" style=\"--book-d:").append(grosor).append("px;\">");

        // 1. Portada (front)
        sb.append("<div class=\"face front\">")
          .append("<img src=\"").append(escape(l.getImagen()))
          .append("\" alt=\"").append(escape(l.getTitulo())).append("\">")
          .append("</div>");

        // 2. Contraportada (back)
        sb.append("<div class=\"face back\">")
          .append("<span class=\"logo-mini\">FO<span>L</span>IO</span>")
          .append("<p class=\"sinopsis\">&laquo;").append(escape(l.getAutor()))
          .append("&raquo; &mdash; edición FOLIO, papel ahuesado, encuadernación rústica.</p>")
          .append("<span class=\"iso\">ISBN &middot; ").append(l.getId().toUpperCase()).append("</span>")
          .append("</div>");

        // 3. Lomo (spine) — texto vertical
        sb.append("<div class=\"face spine\"><span class=\"spine-title\">")
          .append(escape(tituloLomo)).append("</span></div>");

        // 4. Cantos de páginas (fore-edge, top, bottom)
        sb.append("<div class=\"face fore-edge\"></div>");
        sb.append("<div class=\"face top\"></div>");
        sb.append("<div class=\"face bottom\"></div>");

        sb.append("</div>"); // /libro-3d
        sb.append("<span class=\"hint-hover\"><i class=\"fas fa-mouse-pointer\"></i> Pasa el cursor para girar</span>");
        sb.append("</div>"); // /portada-contenedor

        // ---- Info + formulario "Añadir al carrito" ----
        sb.append("<div class=\"libro-info\">");
        sb.append("<h4>").append(escape(l.getTitulo())).append("</h4>");
        sb.append("<p class=\"autor\">").append(escape(l.getAutor())).append("</p>");
        sb.append("<p class=\"precio\">$ ")
          .append(String.format(Locale.US, "%.2f", l.getPrecio())).append("</p>");

        sb.append("<form action=\"CarritoServlet\" method=\"POST\" class=\"form-anadir\">");
        sb.append("<input type=\"hidden\" name=\"accion\"   value=\"AGREGAR_LIBRO\">");
        sb.append("<input type=\"hidden\" name=\"libroId\"  value=\"").append(escape(l.getId())).append("\">");
        sb.append("<input type=\"hidden\" name=\"redirect\" value=\"").append(escape(urlActual)).append("\">");
        sb.append("<input type=\"hidden\" name=\"carrito\"  value=\"open\">");
        sb.append("<button type=\"submit\" class=\"btn-anadir\">");
        sb.append("<i class=\"fas fa-cart-plus\"></i> Añadir al carrito</button>");
        sb.append("</form>");

        sb.append("</div>"); // /libro-info
        sb.append("</article>");

        return sb.toString();
    }

    /** Escape mínimo para HTML/atributos. */
    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
