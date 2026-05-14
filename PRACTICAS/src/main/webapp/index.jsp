<%--
    index.jsp
    Página principal de FOLIO - Biblioteca Digital (Versión Estática / Flat Design)
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario" %>
<%
    // Recuperamos la sesión del usuario si existe
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FOLIO | Biblioteca Digital</title>
    <link rel="stylesheet" href="css/estilos.css?v=15">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <script defer src="js/carrito.js?v=10"></script>
</head>
<body>

<header>
    <div class="header-container">
        <div class="logo">
            <i class="fas fa-book-open fa-2x" style="color:var(--color-acento);"></i>
            <div>
                <h1>FO<span>L</span>IO</h1>
                <span class="logo-subtitle">Biblioteca Digital</span>
            </div>
        </div>
        <nav aria-label="Menú principal">
            <ul>
                <li><a href="javascript:void(0);" onclick="cambiarSeccion('sec-home')"><i class="fas fa-home"></i> Home</a></li>
                <li class="dropdown">
                    <a href="javascript:void(0);" id="btn-catalogo" onclick="cambiarSeccion('sec-catalogo')"><i class="fas fa-book"></i> Catálogo <i class="fas fa-chevron-down" style="font-size:0.8em;"></i></a>
                    <ul class="dropdown-menu" id="menu-catalogo">
                        <li><a href="javascript:void(0);" onclick="irACategoria('cat-latinoamericana')">Latinoamericana</a></li>
                        <li><a href="javascript:void(0);" onclick="irACategoria('cat-clasicos')">Clásicos Mundiales</a></li>
                        <li><a href="javascript:void(0);" onclick="irACategoria('cat-ciencia')">Ciencia Ficción</a></li>
                    </ul>
                </li>
                <li><a href="javascript:void(0);" onclick="cambiarSeccion('sec-contacto')"><i class="fas fa-envelope"></i> Contacto</a></li>

                <%-- LÓGICA DE MENÚ DINÁMICO CON DROPDOWN --%>
                <% if (usrActivo != null) { %>
                <li class="dropdown">
                    <a href="javascript:void(0);" id="btn-perfil" style="color:var(--color-acento); font-weight:600; padding: 0.6rem 1.1rem; display:inline-block;">
                        <i class="fas fa-user-circle"></i> <%= usrActivo.getNombre() %> <i class="fas fa-chevron-down" style="font-size:0.8em;"></i>
                    </a>
                    <ul class="dropdown-menu" id="menu-perfil">
                        <% if ("ADMIN".equalsIgnoreCase(usrActivo.getRol())) { %>
                        <li><a href="admin.jsp"><i class="fas fa-crown" style="color:#ffc107;"></i> Dashboard Admin</a></li>
                        <% } else if ("EMPLEADO".equalsIgnoreCase(usrActivo.getRol())) { %>
                        <li><a href="empleado.jsp"><i class="fas fa-boxes" style="color:#17a2b8;"></i> Inventario</a></li>
                        <% } %>
                        <li><a href="LogoutServlet"><i class="fas fa-sign-out-alt" style="color:#da3633;"></i> Cerrar sesión</a></li>
                    </ul>
                </li>
                <% } else { %>
                <li><a href="login.jsp" class="btn-nav"><i class="fas fa-user"></i> Ingresar</a></li>
                <li><a href="registro.jsp" class="btn-nav"><i class="fas fa-user-plus"></i> Registro</a></li>
                <% } %>

                <li>
                    <button id="btn-carrito" class="btn-carrito" aria-label="Abrir carrito">
                        <i class="fas fa-shopping-basket"></i>
                        <span class="carrito-badge">0</span>
                    </button>
                </li>
                <li>
                    <button id="btn-tema" aria-label="Cambiar tema" style="background:transparent; border:none; color:var(--color-acento); font-size:1.2rem; cursor:pointer; padding: 0.5rem; transition: transform 0.3s;">
                        <i class="fas fa-moon" id="icono-tema"></i>
                    </button>
                </li>
            </ul>
        </nav>
    </div>
</header>

<div id="sec-home" class="view-section active">
    <section class="hero" aria-label="Bienvenida">
        <div class="hero-content">
            <span class="hero-badge">📚 Nuevos títulos cada semana</span>
            <h2 class="gsap-hero">Tu Universo Literario, en un solo lugar</h2>
            <p class="gsap-hero">Explora miles de títulos clásicos y contemporáneos. Vive la experiencia de una librería de autor desde la comodidad de tu hogar.</p>
            <div class="hero-cta gsap-hero">
                <a href="javascript:void(0)" onclick="cambiarSeccion('sec-catalogo')" class="btn-hero">EXPLORAR CATÁLOGO</a>
                <% if (usrActivo == null) { %>
                <a href="registro.jsp" class="btn-hero-outline">Crear cuenta gratis</a>
                <% } %>
            </div>
        </div>
    </section>

    <section class="stats-bar">
        <div class="stat-card">
            <i class="fas fa-book"></i>
            <span class="stat-num" data-target="5000">0</span>
            <span class="stat-label">Libros en catálogo</span>
        </div>
        <div class="stat-card">
            <i class="fas fa-users"></i>
            <span class="stat-num" data-target="2500">0</span>
            <span class="stat-label">Lectores activos</span>
        </div>
        <div class="stat-card">
            <i class="fas fa-map-marker-alt"></i>
            <span class="stat-num" data-target="24">0</span>
            <span class="stat-label">Provincias atendidas</span>
        </div>
        <div class="stat-card">
            <i class="fas fa-award"></i>
            <span class="stat-num" data-target="15">0</span>
            <span class="stat-label">Años de experiencia</span>
        </div>
    </section>

    <section class="home-section">
        <div class="section-header">
            <span class="eyebrow">DESTACADOS</span>
            <h2>Los más leídos del mes</h2>
            <p>Una selección curada por nuestro equipo editorial.</p>
        </div>
        <div class="catalogo">
            <div class="libro-card">
                <div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9780307474728-L.jpg" alt="Cien años de soledad" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/0307474720-L.jpg'"></div>
                <div class="libro-info">
                    <h4>Cien años de soledad</h4><p class="autor">Gabriel García Márquez</p><p class="precio">$ 18.90</p>
                    <button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button>
                </div>
            </div>
            <div class="libro-card">
                <div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg" alt="1984" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/0451524934-L.jpg'"></div>
                <div class="libro-info">
                    <h4>1984</h4><p class="autor">George Orwell</p><p class="precio">$ 16.00</p>
                    <button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button>
                </div>
            </div>
            <div class="libro-card">
                <div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9780142437230-L.jpg" alt="Don Quijote" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9788424116545-L.jpg'"></div>
                <div class="libro-info">
                    <h4>Don Quijote</h4><p class="autor">Miguel de Cervantes</p><p class="precio">$ 25.00</p>
                    <button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button>
                </div>
            </div>
            <div class="libro-card">
                <div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9788499089515-L.jpg" alt="El Aleph" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9789500317320-L.jpg'"></div>
                <div class="libro-info">
                    <h4>El Aleph</h4><p class="autor">Jorge Luis Borges</p><p class="precio">$ 15.50</p>
                    <button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button>
                </div>
            </div>
        </div>
        <div class="centered-cta">
            <a href="javascript:void(0)" onclick="cambiarSeccion('sec-catalogo')" class="btn-link">Ver catálogo completo <i class="fas fa-arrow-right"></i></a>
        </div>
    </section>

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

    <section class="home-section steps">
        <div class="section-header">
            <span class="eyebrow">CÓMO FUNCIONA</span>
            <h2>Comprar en FOLIO es simple</h2>
        </div>
        <div class="steps-grid">
            <div class="step"><div class="step-num">1</div><i class="fas fa-search step-icon"></i><h3>Explora el catálogo</h3><p>Navega por categorías o usa la búsqueda para encontrar tu próximo libro favorito.</p></div>
            <div class="step-arrow"><i class="fas fa-arrow-right"></i></div>
            <div class="step"><div class="step-num">2</div><i class="fas fa-cart-plus step-icon"></i><h3>Añade al carrito</h3><p>Tu carrito se guarda incluso si te registras después. Compra cuando estés listo.</p></div>
            <div class="step-arrow"><i class="fas fa-arrow-right"></i></div>
            <div class="step"><div class="step-num">3</div><i class="fas fa-book-open step-icon"></i><h3>Recibe y disfruta</h3><p>Pago seguro con tarjeta, envío rastreable y atención post-venta.</p></div>
        </div>
    </section>

    <section class="home-section libro-mes">
        <div class="libro-mes-grid">
            <div class="catalogo" style="padding:0; margin:0;">
                <div class="libro-card" style="border:none; box-shadow:none; background:transparent;">
                    <img src="https://covers.openlibrary.org/b/isbn/9788437604572-L.jpg" alt="Rayuela" style="width:100%; max-width: 300px; border-radius:8px; box-shadow: 0 20px 40px rgba(0,0,0,0.5);" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9789500723985-L.jpg'">
                </div>
            </div>
            <div class="libro-mes-info">
                <span class="badge-dorado">⭐ LIBRO DEL MES</span>
                <h2>Rayuela</h2>
                <p class="autor-grande">Julio Cortázar · 1963</p>
                <p class="descripcion">
                    Una novela que rompe las reglas. Puedes leerla en orden o saltando capítulos
                    como sugiere el autor. La historia de Horacio Oliveira y La Maga en París,
                    seguida del regreso a Buenos Aires, sigue siendo una de las propuestas más
                    audaces de la literatura latinoamericana.
                </p>
                <div class="libro-mes-meta">
                    <span><i class="fas fa-star" style="color:#f5b500;"></i> 4.7/5</span>
                    <span><i class="fas fa-bookmark"></i> 736 páginas</span>
                    <span><i class="fas fa-language"></i> Español</span>
                </div>
                <div class="libro-mes-precio">
                    <span class="precio-antes">$ 26.00</span>
                    <span class="precio-ahora">$ 21.00</span>
                    <span class="descuento-badge">-19%</span>
                </div>
                <button class="btn-hero btn-anadir" style="margin-top:1.5rem; width: auto;"><i class="fas fa-cart-plus"></i> Comprar ahora</button>
            </div>
        </div>
    </section>

    <section class="home-section testimonials">
        <div class="section-header">
            <span class="eyebrow">TESTIMONIOS</span>
            <h2>Lo que dicen nuestros lectores</h2>
        </div>
        <div class="testimonios-grid">
            <article class="testimonio">
                <div class="estrellas">★★★★★</div>
                <p>"Encontré ediciones que no se conseguían en otras librerías de Quito. El envío llegó al día siguiente y el libro venía perfecto."</p>
                <footer>
                    <div class="avatar">ME</div>
                    <div><strong>María Elena R.</strong><small>Pichincha · Cliente desde 2023</small></div>
                </footer>
            </article>
            <article class="testimonio">
                <div class="estrellas">★★★★★</div>
                <p>"Como estudiante universitario, el descuento es lo mejor. Tengo toda mi bibliografía de Filosofía sin gastar una fortuna."</p>
                <footer>
                    <div class="avatar">JC</div>
                    <div><strong>Juan Carlos M.</strong><small>Azuay · UPS Cuenca</small></div>
                </footer>
            </article>
            <article class="testimonio">
                <div class="estrellas">★★★★★</div>
                <p>"Compré para regalo, llegó envuelto y con una tarjeta personalizada. Es un detalle que marca la diferencia."</p>
                <footer>
                    <div class="avatar">LV</div>
                    <div><strong>Lucía V.</strong><small>Guayas · Lectora recurrente</small></div>
                </footer>
            </article>
        </div>
    </section>

    <section class="home-section newsletter">
        <div class="newsletter-inner">
            <div>
                <h2>📬 Únete al Club FOLIO</h2>
                <p>Recibe recomendaciones semanales, acceso anticipado a novedades y un cupón de 10% para tu primera compra.</p>
            </div>
            <form id="form-newsletter" class="newsletter-form" novalidate>
                <input type="email" id="news-email" placeholder="tu@correo.com" required>
                <button type="submit"><i class="fas fa-paper-plane"></i> Suscribirme</button>
            </form>
        </div>
    </section>

    <section class="home-section mision-section">
        <div class="mision-box">
            <i class="fas fa-quote-left mision-quote"></i>
            <h3>Nuestra Misión</h3>
            <p>
                En <strong>FOLIO</strong> creemos que cada libro es una puerta. Nuestra misión es
                democratizar el acceso a la literatura ofreciendo un catálogo curado de libros
                físicos y digitales, con un servicio impecable y precios accesibles para
                estudiantes, profesionales y amantes de la lectura.
            </p>
        </div>
    </section>

</div>

<div id="sec-catalogo" class="view-section">
    <div class="content" style="flex-direction: column;">
        <section style="width: 100%;">
            <h2 style="text-align:center; margin-bottom: 2rem;"><i class="fas fa-book-open"></i> Nuestro Catálogo</h2>

            <article id="cat-latinoamericana">
                <h3>Literatura Latinoamericana</h3>
                <div class="catalogo">
                    <div class="libro-card"><div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9780307474728-L.jpg" alt="Cien años de soledad" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/0307474720-L.jpg'"></div><div class="libro-info"><h4>Cien años de soledad</h4><p class="autor">Gabriel García Márquez</p><p class="precio">$ 18.90</p><button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button></div></div>
                    <div class="libro-card"><div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9788499089515-L.jpg" alt="El Aleph" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9789500317320-L.jpg'"></div><div class="libro-info"><h4>El Aleph</h4><p class="autor">Jorge Luis Borges</p><p class="precio">$ 15.50</p><button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button></div></div>
                    <div class="libro-card"><div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9788437604572-L.jpg" alt="Rayuela" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9789500723985-L.jpg'"></div><div class="libro-info"><h4>Rayuela</h4><p class="autor">Julio Cortázar</p><p class="precio">$ 21.00</p><button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button></div></div>
                    <div class="libro-card"><div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9789681601638-L.jpg" alt="Pedro Páramo" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9788437604183-L.jpg'"></div><div class="libro-info"><h4>Pedro Páramo</h4><p class="autor">Juan Rulfo</p><p class="precio">$ 14.20</p><button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button></div></div>
                </div>
            </article>

            <article id="cat-clasicos">
                <h3 style="margin-top: 1rem;">Clásicos Mundiales</h3>
                <div class="catalogo">
                    <div class="libro-card"><div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9780142437230-L.jpg" alt="Don Quijote" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9788424116545-L.jpg'"></div><div class="libro-info"><h4>Don Quijote</h4><p class="autor">Miguel de Cervantes</p><p class="precio">$ 25.00</p><button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button></div></div>
                    <div class="libro-card"><div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg" alt="Orgullo y Prejuicio" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9780486284736-L.jpg'"></div><div class="libro-info"><h4>Orgullo y Prejuicio</h4><p class="autor">Jane Austen</p><p class="precio">$ 12.80</p><button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button></div></div>
                    <div class="libro-card"><div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9780143058144-L.jpg" alt="Crimen y Castigo" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9788437604107-L.jpg'"></div><div class="libro-info"><h4>Crimen y Castigo</h4><p class="autor">Fiódor Dostoyevski</p><p class="precio">$ 19.50</p><button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button></div></div>
                </div>
            </article>

            <article id="cat-ciencia" style="border-bottom: none;">
                <h3 style="margin-top: 1rem;">Ciencia Ficción y Distopía</h3>
                <div class="catalogo">
                    <div class="libro-card"><div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg" alt="1984" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/0451524934-L.jpg'"></div><div class="libro-info"><h4>1984</h4><p class="autor">George Orwell</p><p class="precio">$ 16.00</p><button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button></div></div>
                    <div class="libro-card"><div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9781451673319-L.jpg" alt="Fahrenheit 451" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9780345342966-L.jpg'"></div><div class="libro-info"><h4>Fahrenheit 451</h4><p class="autor">Ray Bradbury</p><p class="precio">$ 13.90</p><button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button></div></div>
                    <div class="libro-card"><div class="portada-contenedor"><img src="https://covers.openlibrary.org/b/isbn/9780547928210-L.jpg" alt="La Comunidad del Anillo" onerror="this.onerror=null;this.src='https://covers.openlibrary.org/b/isbn/9788445073735-L.jpg'"></div><div class="libro-info"><h4>La Comunidad del Anillo</h4><p class="autor">J.R.R. Tolkien</p><p class="precio">$ 28.50</p><button class="btn-anadir"><i class="fas fa-cart-plus"></i> Añadir al carrito</button></div></div>
                </div>
            </article>
        </section>
    </div>
</div>

<div id="sec-contacto" class="view-section">
    <div class="content">
        <section style="flex: 2;">
            <article style="border:none;">
                <h3>Ubicación y Contacto</h3>
                <p>Nos encontramos en la <strong>ciudad de Quito - Ecuador</strong>. Visítanos en nuestra sede principal.</p>

                <div style="margin-top: 1rem; border-radius: 8px; overflow: hidden; box-shadow: var(--sombra-suave);">
                    <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d127641.18957813589!2d-78.58330752520635!3d-0.18659379893962635!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x91d59a4002422c9f%3A0x44b991e158ef5572!2sQuito%2C%20Ecuador!5e0!3m2!1ses!2sus!4v1700000000000!5m2!1ses!2sus" width="100%" height="300" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
                </div>

                <h3 style="margin-top: 2rem;">Nuestras Redes Sociales</h3>
                <div class="redes-contacto">
                    <a href="#"><i class="fab fa-facebook-f"></i> FOLIO Oficial</a>
                    <a href="#"><i class="fab fa-instagram"></i> @folio.ec</a>
                    <a href="#"><i class="fab fa-twitter"></i> @FolioLibros</a>
                    <a href="mailto:contacto@folio.ec"><i class="fas fa-envelope"></i> contacto@folio.ec</a>
                </div>
            </article>
        </section>

        <aside>
            <h3><i class="fas fa-code"></i> Desarrollador</h3>
            <p style="font-size:0.9rem;margin-bottom:1rem;">
                Proyecto académico desarrollado por <strong style="color:var(--color-acento);">Jairo Alejandro Ojeda Herrera</strong>
                — Universidad Politécnica Salesiana, Quito.
            </p>
            <ul>
                <li><a href="https://github.com/" target="_blank"><i class="fab fa-github"></i> GitHub</a></li>
                <li><a href="https://linkedin.com/" target="_blank"><i class="fab fa-linkedin"></i> LinkedIn</a></li>
            </ul>
        </aside>
    </div>
</div>

<footer>
    <div class="footer-container">
        <div class="logo">
            <i class="fas fa-book-open" style="color:var(--color-acento);"></i>
            <strong style="color:var(--color-acento);font-family:'Playfair Display',serif;font-size:1.3rem;">FOLIO</strong>
        </div>
        <p class="footer-copyright">
            © <%= java.time.Year.now() %> FOLIO Biblioteca Digital · Todos los derechos reservados ·
            Desarrollado por Jairo Alejandro Ojeda Herrera
        </p>
    </div>
</footer>

<script>
    function cambiarSeccion(idSeccion) {
        document.querySelectorAll('.view-section').forEach(sec => sec.classList.remove('active'));
        const seccion = document.getElementById(idSeccion);
        if (!seccion) return;
        seccion.classList.add('active');
        window.scrollTo({ top: 0, behavior: 'smooth' });

        seccion.style.opacity = '0';
        seccion.style.transform = 'translateY(15px)';
        requestAnimationFrame(() => {
            seccion.style.transition = 'opacity 0.45s ease, transform 0.45s ease';
            seccion.style.opacity = '1';
            seccion.style.transform = 'translateY(0)';
        });
        setTimeout(() => {
            seccion.style.transition = '';
            seccion.style.transform = '';
        }, 500);
    }

    function irACategoria(idCat) {
        cambiarSeccion('sec-catalogo');
        setTimeout(() => {
            const elemento = document.getElementById(idCat);
            const offset = 80;
            const bodyRect = document.body.getBoundingClientRect().top;
            const elementRect = elemento.getBoundingClientRect().top;
            const offsetPosition = (elementRect - bodyRect) - offset;
            window.scrollTo({ top: offsetPosition, behavior: 'smooth' });
        }, 100);
    }

    const btnTema = document.getElementById('btn-tema');
    const iconoTema = document.getElementById('icono-tema');

    const temaActual = localStorage.getItem('folio-tema');
    if (temaActual === 'dark') {
        document.body.setAttribute('data-theme', 'dark');
        iconoTema.classList.replace('fa-moon', 'fa-sun');
    }

    btnTema.addEventListener('click', () => {
        btnTema.style.transform = "rotate(360deg)";
        setTimeout(() => btnTema.style.transform = "rotate(0deg)", 300);

        if (document.body.getAttribute('data-theme') === 'dark') {
            document.body.removeAttribute('data-theme');
            localStorage.setItem('folio-tema', 'light');
            iconoTema.classList.replace('fa-sun', 'fa-moon');
        } else {
            document.body.setAttribute('data-theme', 'dark');
            localStorage.setItem('folio-tema', 'dark');
            iconoTema.classList.replace('fa-moon', 'fa-sun');
        }
    });

    gsap.from(".gsap-hero", { duration: 1, y: 30, opacity: 0, stagger: 0.2, ease: "power3.out" });

    /* SCROLL REVEAL para artículos y libros */
    const revelables = document.querySelectorAll('section article, .redes-contacto, aside');
    revelables.forEach(el => el.classList.add('reveal'));
    document.querySelectorAll('.libro-card').forEach((el, i) => {
        el.style.opacity = '0';
        el.style.transition = 'opacity 0.6s ease ' + (i * 60) + 'ms';
    });
    const io = new IntersectionObserver((entries) => {
        entries.forEach(en => {
            if (en.isIntersecting) {
                if (en.target.classList.contains('libro-card')) {
                    en.target.style.opacity = '1';
                } else {
                    en.target.classList.add('visible');
                }
                io.unobserve(en.target);
            }
        });
    }, { threshold: 0.12 });
    revelables.forEach(el => io.observe(el));
    document.querySelectorAll('.libro-card').forEach(el => io.observe(el));

    /* CONTADORES ANIMADOS */
    const counterIO = new IntersectionObserver((entries) => {
        entries.forEach(en => {
            if (!en.isIntersecting) return;
            const el = en.target;
            const target = parseInt(el.dataset.target, 10) || 0;
            const duration = 1600;
            const start = performance.now();
            function tick(now) {
                const elapsed = now - start;
                const t = Math.min(elapsed / duration, 1);
                const eased = 1 - Math.pow(1 - t, 3);
                el.textContent = Math.floor(target * eased).toLocaleString('es-EC');
                if (t < 1) requestAnimationFrame(tick);
                else el.textContent = target.toLocaleString('es-EC');
            }
            requestAnimationFrame(tick);
            counterIO.unobserve(el);
        });
    }, { threshold: 0.4 });
    document.querySelectorAll('.stat-num').forEach(el => counterIO.observe(el));

    /* NEWSLETTER */
    const formNews = document.getElementById('form-newsletter');
    if (formNews) {
        formNews.addEventListener('submit', (e) => {
            e.preventDefault();
            const email = document.getElementById('news-email').value.trim();
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                alert('Por favor ingresa un correo válido.');
                return;
            }
            formNews.innerHTML = '<div style="text-align:center;padding:1rem;color:#2ea043;font-weight:600;"><i class="fas fa-check-circle"></i> ¡Listo! Revisa tu correo para confirmar.</div>';
        });
    }

    /* CONTROL DE MENÚS DESPLEGABLES */
    const btnCatalogo = document.getElementById('btn-catalogo');
    const menuCatalogo = document.getElementById('menu-catalogo');
    const btnPerfil = document.getElementById('btn-perfil');
    const menuPerfil = document.getElementById('menu-perfil');

    if (btnCatalogo && menuCatalogo) {
        btnCatalogo.addEventListener('click', function(e) {
            e.stopPropagation();
            menuCatalogo.classList.toggle('activo');
            if (menuPerfil) menuPerfil.classList.remove('activo');
        });
    }

    if (btnPerfil && menuPerfil) {
        btnPerfil.addEventListener('click', function(e) {
            e.stopPropagation();
            menuPerfil.classList.toggle('activo');
            if (menuCatalogo) menuCatalogo.classList.remove('activo');
        });
    }

    document.addEventListener('click', function(e) {
        if (menuCatalogo && !menuCatalogo.contains(e.target) && e.target !== btnCatalogo) {
            menuCatalogo.classList.remove('activo');
        }
        if (menuPerfil && !menuPerfil.contains(e.target) && e.target !== btnPerfil) {
            menuPerfil.classList.remove('activo');
        }
    });

</script>
</body>
</html>