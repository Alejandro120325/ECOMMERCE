<%-- login.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    Usuario usrActivo     = (Usuario) session.getAttribute("usuarioActivo");
    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = false;
    String  urlActual     = "login.jsp";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar sesión &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=110">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%@ include file="WEB-INF/jspf/header.jspf" %>

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

        <form action="LoginServlet" method="post" autocomplete="on">
            <div class="form-grupo">
                <label for="correo"><i class="fas fa-envelope"></i> Correo electrónico</label>
                <input type="email" id="correo" name="correo" placeholder="ejemplo@correo.com"
                       required maxlength="80" autocomplete="email">
                <small>Ingresa un correo válido.</small>
            </div>

            <div class="form-grupo">
                <label for="clave"><i class="fas fa-lock"></i> Clave</label>
                <%-- Campo de contraseña con ojo CSS-only (Checkbox Hack) --%>
                <div class="campo-clave">
                    <input type="checkbox" id="ver-clave-login" class="ojo-toggle" tabindex="-1" aria-hidden="true">
                    <input type="text" id="clave" name="clave" class="input-password"
                           placeholder="Tu contraseña" required minlength="6"
                           autocomplete="current-password" spellcheck="false">
                    <label for="ver-clave-login" class="ojo" aria-label="Mostrar u ocultar contraseña" title="Mostrar / ocultar contraseña">
                        <i class="fas fa-eye       icono-mostrar"></i>
                        <i class="fas fa-eye-slash icono-ocultar"></i>
                    </label>
                </div>
                <small>Mínimo 6 caracteres. Haz clic en el ojo para revelar / ocultar.</small>
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

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
