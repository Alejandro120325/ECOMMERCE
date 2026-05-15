package ec.edu.ups.controlador;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;

import java.io.IOException;

/**
 * FOLIO - Filtro global de codificación UTF-8.
 * <p>
 * Garantiza que <strong>todas</strong> las peticiones que pasan por el
 * contenedor de servlets se decodifiquen como UTF-8 antes de que los
 * servlets/JSP lean parámetros, y que toda respuesta se envíe con el
 * charset correcto.
 *
 * <p>Sin esto, los formularios POST que contienen tildes o eñes llegan
 * al servlet como bytes interpretados con la codificación por defecto
 * de la plataforma (Windows-1252 en Tomcat sobre Windows), corrompiendo
 * los datos antes de tocar PostgreSQL.
 *
 * <p>Se registra como primer filtro (orden 0) para todas las URL del
 * webapp ({@code /*}) usando la anotación {@link WebFilter}, evitando
 * la necesidad de tocar {@code web.xml}.
 */
@WebFilter(urlPatterns = {"/*"}, asyncSupported = true)
public class CharacterEncodingFilter implements Filter {

    private static final String UTF_8 = "UTF-8";

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        // 1) Decodificar la petición entrante como UTF-8 SOLO si el cliente
        //    no especificó otra cosa. Importante: debe hacerse ANTES de
        //    cualquier getParameter().
        if (request.getCharacterEncoding() == null) {
            request.setCharacterEncoding(UTF_8);
        }

        // 2) Forzar UTF-8 en la respuesta de salida.
        response.setCharacterEncoding(UTF_8);

        chain.doFilter(request, response);
    }
}
