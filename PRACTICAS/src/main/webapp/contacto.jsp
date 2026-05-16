<%--
    contacto.jsp
    FOLIO - Página de contacto (sin JavaScript).
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    Usuario usrActivo     = (Usuario) session.getAttribute("usuarioActivo");
    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = "open".equals(request.getParameter("carrito"));
    String  urlActual     = "contacto.jsp";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contacto &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=60">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%@ include file="WEB-INF/jspf/header.jspf" %>

<div class="content">
    <section style="flex: 2;">
        <article style="border:none;">
            <h3>Ubicación y Contacto</h3>
            <p>Nos encontramos en la <strong>ciudad de Quito - Ecuador</strong>. Visítanos en nuestra sede principal.</p>

            <div style="margin-top:1rem; border-radius:8px; overflow:hidden; box-shadow: var(--sombra-suave);">
                <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d127641.18957813589!2d-78.58330752520635!3d-0.18659379893962635!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x91d59a4002422c9f%3A0x44b991e158ef5572!2sQuito%2C%20Ecuador!5e0!3m2!1ses!2sus!4v1700000000000!5m2!1ses!2sus"
                        width="100%" height="300" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
            </div>

            <h3 style="margin-top:2.5rem;">Nuestras Redes Sociales</h3>
            <p style="color:var(--color-texto-suave); margin-bottom:1.2rem;">
                Sigue nuestras novedades, recomendaciones del editor y promociones semanales.
            </p>

            <div class="redes-premium" role="list">
                <a href="https://facebook.com" target="_blank" rel="noopener" class="red-card red-fb" role="listitem">
                    <span class="red-icon"><i class="fab fa-facebook-f"></i></span>
                    <span class="red-info"><strong>Facebook</strong><small>FOLIO Oficial</small></span>
                </a>
                <a href="https://instagram.com" target="_blank" rel="noopener" class="red-card red-ig" role="listitem">
                    <span class="red-icon"><i class="fab fa-instagram"></i></span>
                    <span class="red-info"><strong>Instagram</strong><small>@folio.ec</small></span>
                </a>
                <a href="https://x.com" target="_blank" rel="noopener" class="red-card red-x" role="listitem">
                    <span class="red-icon"><i class="fa-brands fa-x-twitter"></i></span>
                    <span class="red-info"><strong>X (Twitter)</strong><small>@FolioLibros</small></span>
                </a>
                <a href="https://wa.me/593990000000" target="_blank" rel="noopener" class="red-card red-wa" role="listitem">
                    <span class="red-icon"><i class="fab fa-whatsapp"></i></span>
                    <span class="red-info"><strong>WhatsApp</strong><small>+593 99 000 0000</small></span>
                </a>
                <a href="https://tiktok.com" target="_blank" rel="noopener" class="red-card red-tk" role="listitem">
                    <span class="red-icon"><i class="fab fa-tiktok"></i></span>
                    <span class="red-info"><strong>TikTok</strong><small>@folio.libros</small></span>
                </a>
                <a href="mailto:contacto@folio.ec" class="red-card red-mail" role="listitem">
                    <span class="red-icon"><i class="fas fa-envelope"></i></span>
                    <span class="red-info"><strong>Email</strong><small>contacto@folio.ec</small></span>
                </a>
            </div>
        </article>
    </section>

    <aside>
        <h3><i class="fas fa-code"></i> Desarrollador</h3>
        <p style="font-size:0.9rem;margin-bottom:1rem;">
            Proyecto académico desarrollado por <strong style="color:var(--color-acento);">Jairo Alejandro Ojeda Herrera</strong>
            &mdash; Universidad Politécnica Salesiana, Quito.
        </p>
        <ul>
            <li><a href="https://github.com/" target="_blank"><i class="fab fa-github"></i> GitHub</a></li>
            <li><a href="https://linkedin.com/" target="_blank"><i class="fab fa-linkedin"></i> LinkedIn</a></li>
        </ul>
    </aside>
</div>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
