package ec.edu.ups.controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.jsp.jstl.core.Config;

import java.io.IOException;
import java.util.Locale;

// --- I18N LANGUAGE SWITCH ---
@WebServlet(name = "CambiarIdiomaServlet", urlPatterns = {"/CambiarIdiomaServlet"})
public class CambiarIdiomaServlet extends HttpServlet {

    public static final String ATTR_IDIOMA = "idioma";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        cambiar(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        cambiar(request, response);
    }

    private void cambiar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // --- VALIDATE ---
        String idioma = request.getParameter("idioma");
        if (idioma == null || idioma.isBlank()) idioma = request.getParameter("lang");
        if (!"es".equalsIgnoreCase(idioma) && !"en".equalsIgnoreCase(idioma)) idioma = "es";
        idioma = idioma.toLowerCase();

        // --- PERSIST IN SESSION (idioma + JSTL fmt locale) ---
        HttpSession session = request.getSession(true);
        session.setAttribute(ATTR_IDIOMA, idioma);
        Config.set(session, Config.FMT_LOCALE, Locale.forLanguageTag(idioma));

        // --- REDIRECT BACK VIA REFERER ---
        response.sendRedirect(destino(request));
    }

    private String destino(HttpServletRequest request) {
        String referer = request.getHeader("Referer");
        String host = request.getServerName();
        if (referer != null && !referer.isBlank()
                && (referer.contains("://" + host) || referer.startsWith("/"))) {
            return referer;
        }
        return "index.jsp";
    }
}
