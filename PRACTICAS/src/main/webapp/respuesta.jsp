<%--
    respuesta.jsp
    FOLIO - Resumen del registro recibido del RegistroServlet (CERO JavaScript).
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    Usuario u             = (Usuario) request.getAttribute("usuario");
    Boolean exito         = (Boolean) request.getAttribute("exito");
    String  mensaje       = (String)  request.getAttribute("mensaje");

    Usuario usrActivo     = (Usuario) session.getAttribute("usuarioActivo");
    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = false;
    String  urlActual     = "respuesta.jsp";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro recibido &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=60">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%@ include file="WEB-INF/jspf/header.jspf" %>

<main class="form-wrapper">
    <div class="form-container" style="max-width:720px;">
        <% if (exito != null && exito) { %>
            <div class="mensaje exito">
                <i class="fas fa-check-circle"></i>
                <strong>¡Registro exitoso!</strong> Tus datos han sido guardados en la base de datos de FOLIO.
            </div>
        <% } else if (mensaje != null) { %>
            <div class="mensaje error">
                <i class="fas fa-exclamation-triangle"></i> <%= mensaje %>
            </div>
        <% } %>

        <h2><i class="fas fa-clipboard-check" style="color:var(--color-acento);"></i> Resumen de tu registro</h2>
        <p class="subtitulo">A continuación se muestran los datos capturados.</p>

        <% if (u != null) { %>
        <table class="tabla-respuesta">
            <tr><th>Nombres</th>             <td><%= u.getNombre() %></td></tr>
            <tr><th>Apellidos</th>           <td><%= u.getApellido() %></td></tr>
            <tr><th>Cédula</th>              <td><%= u.getCedula() %></td></tr>
            <tr><th>Fecha de nacimiento</th> <td><%= u.getFechaNacimiento() %></td></tr>
            <tr><th>Género</th>              <td><%= u.getGenero() %></td></tr>
            <tr><th>Estado civil</th>        <td><%= u.getEstadoCivil() %></td></tr>
            <tr><th>Provincia</th>           <td><%= u.getProvincia() %></td></tr>
            <tr><th>Ciudad</th>              <td><%= u.getCiudad() %></td></tr>
            <tr><th>Dirección</th>           <td><%= (u.getDireccion()==null?"-":u.getDireccion()) %></td></tr>
            <tr><th>Teléfono</th>            <td><%= u.getTelefono() %></td></tr>
            <tr><th>Correo</th>              <td><%= u.getCorreo() %></td></tr>
            <tr><th>Clave</th>               <td>**********</td></tr>
            <tr><th>Foto de perfil</th>
                <td>
                    <% if (u.getFotoPerfil() != null && !u.getFotoPerfil().isEmpty()) { %>
                        <img src="uploads/<%= u.getFotoPerfil() %>" alt="Foto"
                             style="max-width:120px;border-radius:8px;border:2px solid var(--color-acento);">
                    <% } else { %>
                        <em>No se cargó imagen</em>
                    <% } %>
                </td>
            </tr>
        </table>
        <% } else { %>
            <div class="mensaje error">No se recibieron datos del registro.</div>
        <% } %>

        <div style="display:flex;gap:0.8rem;margin-top:1.5rem;flex-wrap:wrap;">
            <a href="login.jsp" class="btn" style="text-decoration:none;text-align:center;flex:1;min-width:180px;">
                <i class="fas fa-sign-in-alt"></i> Iniciar sesión
            </a>
            <a href="index.jsp" class="btn btn-secundario" style="text-decoration:none;text-align:center;flex:1;min-width:180px;">
                <i class="fas fa-home"></i> Volver al inicio
            </a>
        </div>
    </div>
</main>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
