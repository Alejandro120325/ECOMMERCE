<%--
    pago.jsp
    FOLIO - Formulario de pago (POST tradicional al ProcesarPagoServlet).
    ------------------------------------------------------------------
    Todas las validaciones (Luhn, longitud por marca, fecha, CVV,
    titular) las realiza el servlet en Java. Si la validación
    falla, el servlet redirige con ?error=<codigo>, que aquí
    convertimos en un mensaje legible.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    Usuario usrActivo     = (Usuario) session.getAttribute("usuarioActivo");
    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = false;  // En la pantalla de pago no abrimos el drawer
    String  urlActual     = "pago.jsp";

    // Si el carrito está vacío, no hay nada que pagar.
    if (carrito == null || carrito.estaVacio()) {
        response.sendRedirect("index.jsp?carrito=open");
        return;
    }

    // Mensaje de error que viene del servlet (códigos)
    String codigoError = request.getParameter("error");
    String mensajeError = null;
    if (codigoError != null) {
        switch (codigoError) {
            case "marca_no_reconocida": mensajeError = "Marca de tarjeta no reconocida. Acepta Visa, Mastercard, Amex, Discover o Diners."; break;
            case "longitud_invalida":   mensajeError = "El número de tarjeta no tiene la longitud correcta para esa marca.";                break;
            case "luhn":                mensajeError = "El número de tarjeta no es válido (no pasa la verificación Luhn).";                break;
            case "titular":             mensajeError = "Ingresa el nombre completo del titular (nombre y apellido, solo letras).";          break;
            case "expira":              mensajeError = "Fecha de expiración inválida o vencida.";                                            break;
            case "cvv":                 mensajeError = "CVV inválido. Deben ser 3 dígitos (4 para American Express).";                       break;
            default:                    mensajeError = "Datos de pago inválidos. Revisa el formulario.";                                     break;
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pago seguro &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=40">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>

<%@ include file="WEB-INF/jspf/header.jspf" %>

<main class="form-wrapper">
    <div class="form-container" style="max-width:520px;">
        <h2><i class="fas fa-credit-card" style="color:var(--color-acento);"></i> Pago seguro</h2>
        <p class="subtitulo">Completa los datos de tu tarjeta. Toda la validación se realiza en nuestros servidores.</p>

        <%-- ---- Resumen del carrito ---- --%>
        <div class="pago-resumen-detalle">
            <div class="linea"><span>Subtotal</span><span>$ <%= String.format(java.util.Locale.US, "%.2f", carrito.getSubtotal()) %></span></div>
            <div class="linea"><span>IVA (15%)</span><span>$ <%= String.format(java.util.Locale.US, "%.2f", carrito.getIva()) %></span></div>
            <div class="linea total"><span>Total a pagar</span><span class="total-val">$ <%= String.format(java.util.Locale.US, "%.2f", carrito.getTotal()) %></span></div>
        </div>

        <%-- ---- Mensaje de error (si lo hay) ---- --%>
        <% if (mensajeError != null) { %>
        <div class="mensaje error">
            <i class="fas fa-exclamation-triangle"></i> <%= mensajeError %>
        </div>
        <% } %>

        <%-- ---- Formulario POST ---- --%>
        <form action="ProcesarPagoServlet" method="post" autocomplete="on">
            <div class="form-grupo">
                <label for="numero"><i class="fas fa-credit-card"></i> Número de tarjeta</label>
                <input type="text" id="numero" name="numero"
                       placeholder="0000 0000 0000 0000"
                       required minlength="13" maxlength="23"
                       pattern="[0-9 ]{13,23}"
                       autocomplete="cc-number">
                <small>Acepta Visa, Mastercard, American Express, Discover y Diners.</small>
            </div>

            <div class="form-grupo">
                <label for="titular"><i class="fas fa-user"></i> Nombre del titular</label>
                <input type="text" id="titular" name="titular"
                       placeholder="Como aparece en la tarjeta"
                       required minlength="5" maxlength="40"
                       pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ ]+"
                       autocomplete="cc-name">
                <small>Sólo letras y un espacio entre nombre y apellido.</small>
            </div>

            <div class="fila-2">
                <div class="form-grupo">
                    <label for="expira"><i class="fas fa-calendar"></i> Vencimiento</label>
                    <input type="text" id="expira" name="expira"
                           placeholder="MM/AA"
                           required maxlength="5"
                           pattern="(0[1-9]|1[0-2])/[0-9]{2}"
                           autocomplete="cc-exp">
                </div>
                <div class="form-grupo">
                    <label for="cvv"><i class="fas fa-lock"></i> CVV</label>
                    <input type="password" id="cvv" name="cvv"
                           placeholder="123"
                           required minlength="3" maxlength="4"
                           pattern="[0-9]{3,4}"
                           autocomplete="cc-csc">
                </div>
            </div>

            <button type="submit" class="btn"><i class="fas fa-shield-alt"></i> Pagar
                $ <%= String.format(java.util.Locale.US, "%.2f", carrito.getTotal()) %></button>

            <a href="index.jsp?carrito=open" class="btn btn-secundario" style="text-align:center;text-decoration:none;display:block;margin-top:0.6rem;">
                <i class="fas fa-arrow-left"></i> Volver al carrito
            </a>

            <p class="pago-seguro-nota">
                <i class="fas fa-shield-alt"></i> Conexión cifrada &middot; Validación 100% server-side &middot; No almacenamos tu tarjeta.
            </p>
        </form>
    </div>
</main>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
