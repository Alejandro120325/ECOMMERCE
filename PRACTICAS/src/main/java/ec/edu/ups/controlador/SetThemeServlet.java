package ec.edu.ups.controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

// --- SET THEME (DARK / LIGHT) ---
@WebServlet(name = "SetThemeServlet", urlPatterns = {"/SetThemeServlet"})
public class SetThemeServlet extends HttpServlet {

    public static final String ATTR_TEMA    = "tema";
    public static final String TEMA_DEFAULT = "dark";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // --- VALIDATE PAYLOAD ---
        String tema = request.getParameter("tema");
        if (!"light".equalsIgnoreCase(tema) && !"dark".equalsIgnoreCase(tema)) {
            tema = TEMA_DEFAULT;
        }
        tema = tema.toLowerCase();

        // --- PERSIST IN SESSION ---
        HttpSession session = request.getSession(true);
        session.setAttribute(ATTR_TEMA, tema);

        // --- REDIRECT BACK (Referer first, hidden field as fallback) ---
        response.sendRedirect(destino(request));
    }

    private String destino(HttpServletRequest request) {
        String referer = request.getHeader("Referer");
        if (esUrlInternaValida(referer, request)) return referer;

        String redirect = request.getParameter("redirect");
        if (redirect != null && !redirect.isBlank() && !redirect.contains("://")) {
            return redirect;
        }
        return "index.jsp";
    }

    private boolean esUrlInternaValida(String url, HttpServletRequest req) {
        if (url == null || url.isBlank()) return false;
        String host = req.getServerName();
        return url.contains("://" + host) || url.startsWith("/");
    }

    public static String obtenerTema(HttpServletRequest request) {
        HttpSession s = request.getSession(false);
        if (s == null) return TEMA_DEFAULT;
        Object v = s.getAttribute(ATTR_TEMA);
        return (v instanceof String) ? (String) v : TEMA_DEFAULT;
    }
}
