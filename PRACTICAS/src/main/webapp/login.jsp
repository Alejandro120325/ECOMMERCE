<%--
    login.jsp
    Formulario de inicio de sesión - FOLIO
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario" %>
<%
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar sesión | FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=15">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
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
        <nav>
            <ul>
                <li><a href="index.jsp"><i class="fas fa-home"></i> Home</a></li>

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
                <li><a href="registro.jsp" class="btn-nav"><i class="fas fa-user-plus"></i> Crear cuenta</a></li>
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

<main class="form-wrapper">

    <div class="form-container">
        <h2><i class="fas fa-sign-in-alt" style="color:var(--color-acento);"></i> Iniciar sesión</h2>
        <p class="subtitulo">Bienvenido de vuelta. Ingresa tus credenciales para continuar.</p>

        <% String error = request.getParameter("error");
            if (error != null) { %>
        <div class="mensaje error">
            <i class="fas fa-exclamation-triangle"></i> Credenciales incorrectas. Verifica tu correo y clave.
        </div>
        <% } %>

        <form action="LoginServlet" method="post" autocomplete="on" novalidate>
            <div class="form-grupo">
                <label for="correo"><i class="fas fa-envelope"></i> Correo electrónico</label>
                <input type="email" id="correo" name="correo" placeholder="ejemplo@correo.com" required maxlength="80" autocomplete="email">
                <small>Ingresa un correo válido (ej. usuario@dominio.com)</small>
            </div>

            <div class="form-grupo">
                <label for="clave"><i class="fas fa-lock"></i> Clave</label>
                <div style="position: relative; display: block; width: 100%;">
                    <input type="password" id="clave" name="clave" placeholder="Tu contraseña" required minlength="6" autocomplete="current-password" style="width: 100%; padding-right: 2.5rem;">
                    <button type="button" onclick="toggleVisibilidad('clave', this)" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: transparent; border: none; cursor: pointer; font-size: 1.1rem; color: var(--color-texto-suave); padding: 0; display: flex; align-items: center; justify-content: center; height: 100%;">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
                <small>Mínimo 6 caracteres.</small>
            </div>

            <div class="form-grupo">
                <label style="font-weight:400;cursor:pointer;">
                    <input type="checkbox" name="recordar" value="si"> Recordarme en este dispositivo
                </label>
            </div>

            <button type="submit" class="btn"><i class="fas fa-arrow-right-to-bracket"></i> Ingresar</button>
            <a href="index.jsp" class="btn btn-secundario" style="text-align:center;text-decoration:none;display:block;margin-top:0.6rem;">
                <i class="fas fa-arrow-left"></i> Volver
            </a>

            <div class="form-footer">
                ¿Aún no tienes cuenta? <a href="registro.jsp">Regístrate aquí</a>
            </div>
        </form>
    </div>
</main>

<footer>
    <div class="footer-container">
        <p class="footer-copyright">© <%= java.time.Year.now() %> FOLIO Biblioteca Digital · Desarrollado por Jairo Alejandro Ojeda Herrera</p>
    </div>
</footer>

<script>
    const btnTema = document.getElementById('btn-tema');
    const iconoTema = document.getElementById('icono-tema');
    const temaActual = localStorage.getItem('folio-tema');
    if (temaActual === 'dark') {
        document.body.setAttribute('data-theme', 'dark');
        iconoTema.classList.replace('fa-moon', 'fa-sun');
    }

    // Si veníamos de un intento fallido (?error), olvidar al usuario
    const params = new URLSearchParams(window.location.search);
    if (params.has('error') && window.FolioCarrito) {
        window.FolioCarrito.logout();
    }

    // Al enviar login, identificar al usuario en el carrito
    const formLogin = document.querySelector('form[action="LoginServlet"]');
    if (formLogin) {
        formLogin.addEventListener('submit', () => {
            const correo = document.getElementById('correo').value.trim().toLowerCase();
            if (correo && window.FolioCarrito) {
                window.FolioCarrito.setUser(correo);
            }
        });
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

    // SCRIPT PARA EL OJITO
    function toggleVisibilidad(inputId, boton) {
        const input = document.getElementById(inputId);
        const icono = boton.querySelector('i');

        if (input.type === 'password') {
            input.type = 'text';
            icono.classList.remove('fa-eye');
            icono.classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            icono.classList.remove('fa-eye-slash');
            icono.classList.add('fa-eye');
        }
    }

    /* CONTROL DE MENÚS DESPLEGABLES */
    const btnPerfil = document.getElementById('btn-perfil');
    const menuPerfil = document.getElementById('menu-perfil');

    if (btnPerfil && menuPerfil) {
        btnPerfil.addEventListener('click', function(e) {
            e.stopPropagation();
            menuPerfil.classList.toggle('activo');
        });
    }

    document.addEventListener('click', function(e) {
        if (menuPerfil && !menuPerfil.contains(e.target) && e.target !== btnPerfil) {
            menuPerfil.classList.remove('activo');
        }
    });
</script>
</body>
</html>