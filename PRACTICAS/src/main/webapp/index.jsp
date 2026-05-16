<%--
    index.jsp
    FOLIO - Home (CERO JavaScript)
    ------------------------------------------------------------------
    * Sin <script>, sin onclick, sin atributos onerror/onload.
    * El carrito, el drawer y los formularios son 100% server-side.
    * Las animaciones, dropdowns y libro 3D se resuelven con CSS3 puro.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Libro, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.dao.LibroDAO, ec.edu.ups.controlador.CarritoServlet,
                 ec.edu.ups.util.LibroRenderer" %>
<%
    // -- Datos para el header + drawer --
    Usuario usrActivo     = (Usuario) session.getAttribute("usuarioActivo");
    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = "open".equals(request.getParameter("carrito"));
    String  urlActual     = "index.jsp";

    // -- Catálogo destacado (4 libros representativos) --
    LibroDAO dao = new LibroDAO();
    Libro l1 = dao.buscarPorId("cien-anios-soledad");
    Libro l2 = dao.buscarPorId("1984");
    Libro l3 = dao.buscarPorId("don-quijote");
    Libro l4 = dao.buscarPorId("habitos-atomicos");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FOLIO | Biblioteca Digital</title>
    <link rel="stylesheet" href="css/estilos.css?v=60">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%-- ========== HEADER ========== --%>
<%@ include file="WEB-INF/jspf/header.jspf" %>

<%-- ========== HERO ========== --%>
<section class="hero" aria-label="Bienvenida">
    <div class="hero-content">
        <span class="hero-badge">📚 Catálogo curado &middot; Envíos a todo Ecuador</span>
        <h2>Tu Universo Literario, en un solo lugar</h2>
        <p>Explora miles de títulos en 3D. Pasa el cursor sobre cada libro y obsérvalo girar para apreciar su lomo, su contraportada y su espesor real.</p>
        <div class="hero-cta">
            <a href="FiltrarLibrosServlet?categoria=todas" class="btn-hero">EXPLORAR CATÁLOGO</a>
            <% if (usrActivo == null) { %>
                <a href="registro.jsp" class="btn-hero-outline">Crear cuenta gratis</a>
            <% } %>
        </div>
    </div>
</section>

<%-- ========== STATS ========== --%>
<section class="stats-bar">
    <div class="stat-card"><i class="fas fa-book"></i><span class="stat-num">5.000</span><span class="stat-label">Libros en catálogo</span></div>
    <div class="stat-card"><i class="fas fa-users"></i><span class="stat-num">2.500</span><span class="stat-label">Lectores activos</span></div>
    <div class="stat-card"><i class="fas fa-map-marker-alt"></i><span class="stat-num">24</span><span class="stat-label">Provincias atendidas</span></div>
    <div class="stat-card"><i class="fas fa-award"></i><span class="stat-num">15</span><span class="stat-label">Años de experiencia</span></div>
</section>

<%-- ========== DESTACADOS ========== --%>
<section class="home-section">
    <div class="section-header">
        <span class="eyebrow">DESTACADOS</span>
        <h2>Los más leídos del mes</h2>
        <p>Posa el cursor sobre cualquier libro: la portada gira y revela el lomo y la contraportada en 3D.</p>
    </div>
    <div class="catalogo">
        <%= LibroRenderer.render(l1, urlActual) %>
        <%= LibroRenderer.render(l2, urlActual) %>
        <%= LibroRenderer.render(l3, urlActual) %>
        <%= LibroRenderer.render(l4, urlActual) %>
    </div>
    <div class="centered-cta">
        <a href="FiltrarLibrosServlet?categoria=todas" class="btn-link">Ver catálogo completo <i class="fas fa-arrow-right"></i></a>
    </div>
</section>

<%-- ========== POR QUÉ FOLIO ========== --%>
<section class="home-section why-folio">
    <div class="section-header">
        <span class="eyebrow">POR QUÉ FOLIO</span>
        <h2>Más que una librería online</h2>
        <p>Pensamos cada detalle para quienes aman leer.</p>
    </div>
    <div class="benefits-grid">
        <div class="benefit-card"><div class="benefit-icon"><i class="fas fa-shipping-fast"></i></div><h3>Envío a todo Ecuador</h3><p>Recibe tu libro en 24–48 horas en ciudades principales y hasta 5 días en zonas rurales.</p></div>
        <div class="benefit-card"><div class="benefit-icon"><i class="fas fa-bookmark"></i></div><h3>Catálogo curado</h3><p>Cada título es seleccionado por nuestro comité editorial, no por un algoritmo.</p></div>
        <div class="benefit-card"><div class="benefit-icon"><i class="fas fa-graduation-cap"></i></div><h3>Precios estudiantiles</h3><p>Hasta 25% de descuento con tu credencial universitaria vigente.</p></div>
        <div class="benefit-card"><div class="benefit-icon"><i class="fas fa-undo-alt"></i></div><h3>Devoluciones gratis</h3><p>Tienes 30 días para devolver sin preguntas si el libro no te convence.</p></div>
        <div class="benefit-card"><div class="benefit-icon"><i class="fas fa-lock"></i></div><h3>Pago seguro</h3><p>Aceptamos Visa, Mastercard, Amex, Discover y Diners con cifrado bancario.</p></div>
        <div class="benefit-card"><div class="benefit-icon"><i class="fas fa-headset"></i></div><h3>Soporte humano</h3><p>Atención por WhatsApp y correo, lunes a sábado de 9:00 a 19:00.</p></div>
    </div>
</section>

<%-- ========== STEPS ========== --%>
<section class="home-section steps">
    <div class="section-header">
        <span class="eyebrow">CÓMO FUNCIONA</span>
        <h2>Comprar en FOLIO es simple</h2>
    </div>
    <div class="steps-grid">
        <div class="step"><div class="step-num">1</div><i class="fas fa-search step-icon"></i><h3>Explora el catálogo</h3><p>Navega por categorías o usa la búsqueda para encontrar tu próximo libro favorito.</p></div>
        <div class="step-arrow"><i class="fas fa-arrow-right"></i></div>
        <div class="step"><div class="step-num">2</div><i class="fas fa-cart-plus step-icon"></i><h3>Añade al carrito</h3><p>El carrito se mantiene en tu sesión segura del servidor mientras navegas.</p></div>
        <div class="step-arrow"><i class="fas fa-arrow-right"></i></div>
        <div class="step"><div class="step-num">3</div><i class="fas fa-book-open step-icon"></i><h3>Recibe y disfruta</h3><p>Pago seguro con tarjeta, envío rastreable y atención post-venta.</p></div>
    </div>
</section>

<%-- ========== NEWSLETTER (form tradicional sin servlet — solo UI) ========== --%>
<section class="home-section newsletter">
    <div class="newsletter-inner">
        <div>
            <h2>📬 Únete al Club FOLIO</h2>
            <p>Recibe recomendaciones semanales, acceso anticipado a novedades y un cupón de 10% para tu primera compra.</p>
        </div>
        <form class="newsletter-form" action="index.jsp" method="get">
            <input type="email" name="news" placeholder="tu@correo.com" required>
            <button type="submit"><i class="fas fa-paper-plane"></i> Suscribirme</button>
        </form>
        <% if (request.getParameter("news") != null && !request.getParameter("news").isBlank()) { %>
        <p class="newsletter-thanks"><i class="fas fa-check-circle"></i> ¡Gracias por suscribirte! Revisa tu correo.</p>
        <% } %>
    </div>
</section>

<%-- ========== CART DRAWER (server-side) ========== --%>
<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>

<%-- ========== FOOTER ========== --%>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
