<%-- pago-exito.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    Usuario usrActivo     = (Usuario) session.getAttribute("usuarioActivo");
    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = false;
    String  urlActual     = "pago-exito.jsp";

    String monto    = request.getParameter("monto");
    String marca    = request.getParameter("marca");
    String ultimos4 = request.getParameter("ultimos4");
    if (monto == null) monto = "0.00";
    if (marca == null) marca = "FOLIO";
    if (ultimos4 == null) ultimos4 = "0000";

    double montoNum;
    try { montoNum = Double.parseDouble(monto); } catch (Exception e) { montoNum = 0.0; }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pago aprobado &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=110">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%@ include file="WEB-INF/jspf/header.jspf" %>

<main class="form-wrapper">
    <div class="form-container pago-exito-card">
        <div class="pago-exito-check"><i class="fas fa-check"></i></div>
        <h2 style="text-align:center; color:#2ea043; margin-bottom: 0.6rem;">¡Pago aprobado!</h2>
        <p style="text-align:center;">Tu compra de <strong>$ <%= String.format(java.util.Locale.US, "%.2f", montoNum) %></strong> ha sido procesada con éxito.</p>
        <p style="text-align:center; color:var(--color-texto-suave); font-size:0.9rem;">
            <%= marca %> terminada en &bull;&bull;&bull;&bull; <%= ultimos4 %>
            <% if (usrActivo != null) { %>
                <br>Recibo enviado a <strong><%= usrActivo.getCorreo() %></strong>
            <% } %>
        </p>

        <a href="FiltrarLibrosServlet?categoria=todas" class="btn" style="text-align:center;text-decoration:none;display:block;margin-top:2rem;">
            <i class="fas fa-book"></i> Seguir explorando libros
        </a>
        <a href="index.jsp" class="btn btn-secundario" style="text-align:center;text-decoration:none;display:block;margin-top:0.6rem;">
            <i class="fas fa-home"></i> Volver al inicio
        </a>
    </div>
</main>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
