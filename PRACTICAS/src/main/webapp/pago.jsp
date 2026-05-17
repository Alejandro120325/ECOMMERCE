<%-- pago.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    Usuario usrActivo     = (Usuario) session.getAttribute("usuarioActivo");
    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = false;
    String  urlActual     = "pago.jsp";

    if (carrito == null || carrito.estaVacio()) {
        response.sendRedirect("index.jsp?carrito=open");
        return;
    }

    // ---- Mensaje de error ----
    String codigoError  = request.getParameter("error");
    String mensajeError = null;
    if (codigoError != null) {
        switch (codigoError) {
            case "marca_no_reconocida":   mensajeError = "Marca de tarjeta no reconocida. Acepta Visa, Mastercard, Amex, Discover o Diners."; break;
            case "longitud_invalida":     mensajeError = "El número de tarjeta no tiene la longitud correcta para esa marca."; break;
            case "luhn":                  mensajeError = "El número de tarjeta no es válido (no pasa la verificación Luhn)."; break;
            case "titular":               mensajeError = "Ingresa el nombre completo del titular (nombre y apellido, solo letras)."; break;
            case "expira":                mensajeError = "Fecha de expiración inválida o vencida."; break;
            case "cvv":                   mensajeError = "CVV inválido. Deben ser 3 dígitos (4 para American Express)."; break;
            case "banco_invalido":        mensajeError = "Selecciona un banco ecuatoriano válido de la lista."; break;
            case "comprobante_invalido":  mensajeError = "El número de comprobante de transferencia debe tener entre 6 y 20 dígitos."; break;
            case "paypal_email_invalido": mensajeError = "El correo PayPal no es válido. Verifica el formato (usuario@dominio.com)."; break;
            default:                      mensajeError = "Datos de pago inválidos. Revisa el formulario.";
        }
    }

    // ---- Cuenta de depósito ficticia, "generada" por sesión ----
    // Determinista respecto a la sesión para que el usuario vea la misma cuenta si recarga.
    String idSesion = session.getId();
    long cuentaSemilla = Math.abs((long) idSesion.hashCode());
    String numeroCuentaFicticia = String.format("22%010d", cuentaSemilla % 10000000000L);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pago seguro &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=110">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%@ include file="WEB-INF/jspf/header.jspf" %>

<main class="form-wrapper">
    <div class="form-container" style="max-width:640px;">
        <h2><i class="fas fa-credit-card" style="color:var(--color-acento);"></i> Pago seguro</h2>
        <p class="subtitulo">Elige tu método de pago favorito. Toda la validación se realiza en el servidor (Java).</p>

        <%-- ----- Resumen del carrito ----- --%>
        <div class="pago-resumen-detalle">
            <div class="linea"><span>Subtotal</span><span>$ <%= String.format(java.util.Locale.US, "%.2f", carrito.getSubtotal()) %></span></div>
            <div class="linea"><span>IVA (15%)</span><span>$ <%= String.format(java.util.Locale.US, "%.2f", carrito.getIva()) %></span></div>
            <div class="linea total"><span>Total a pagar</span><span class="total-val">$ <%= String.format(java.util.Locale.US, "%.2f", carrito.getTotal()) %></span></div>
        </div>

        <%-- ----- Mensaje de error contextual ----- --%>
        <% if (mensajeError != null) { %>
        <div class="mensaje error"><i class="fas fa-exclamation-triangle"></i> <%= mensajeError %></div>
        <% } %>

        <details class="metodo-pago" open>
            <summary>
                <span class="metodo-icon"><i class="fas fa-credit-card"></i></span>
                <span class="metodo-info">
                    <strong>Tarjeta de crédito o débito</strong>
                    <small>Visa &middot; Mastercard &middot; Amex &middot; Diners</small>
                </span>
                <span class="metodo-chevron"><i class="fas fa-chevron-down"></i></span>
            </summary>
            <form action="ProcesarPagoServlet" method="post" autocomplete="on" class="metodo-form">
                <input type="hidden" name="metodo" value="tarjeta">

                <div class="form-grupo">
                    <label for="numero"><i class="fas fa-credit-card"></i> Número de tarjeta</label>
                    <input type="text" id="numero" name="numero"
                           placeholder="0000 0000 0000 0000"
                           required minlength="13" maxlength="23"
                           pattern="[0-9 ]{13,23}" autocomplete="cc-number">
                    <small>Visa, Mastercard, American Express, Discover y Diners.</small>
                </div>

                <div class="form-grupo">
                    <label for="titular"><i class="fas fa-user"></i> Nombre del titular</label>
                    <input type="text" id="titular" name="titular"
                           placeholder="Como aparece en la tarjeta"
                           required minlength="5" maxlength="40"
                           pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ ]+" autocomplete="cc-name">
                </div>

                <div class="fila-2">
                    <div class="form-grupo">
                        <label for="expira"><i class="fas fa-calendar"></i> Vencimiento</label>
                        <input type="text" id="expira" name="expira"
                               placeholder="MM/AA" required maxlength="5"
                               pattern="(0[1-9]|1[0-2])/[0-9]{2}" autocomplete="cc-exp">
                    </div>
                    <div class="form-grupo">
                        <label for="cvv"><i class="fas fa-lock"></i> CVV</label>
                        <input type="password" id="cvv" name="cvv"
                               placeholder="123" required minlength="3" maxlength="4"
                               pattern="[0-9]{3,4}" autocomplete="cc-csc">
                    </div>
                </div>

                <button type="submit" class="btn"><i class="fas fa-shield-alt"></i>
                    Pagar $ <%= String.format(java.util.Locale.US, "%.2f", carrito.getTotal()) %></button>
            </form>
        </details>

        <details class="metodo-pago">
            <summary>
                <span class="metodo-icon"><i class="fas fa-university"></i></span>
                <span class="metodo-info">
                    <strong>Transferencia bancaria</strong>
                    <small>Pichincha &middot; Guayaquil &middot; Produbanco &middot; Pacífico</small>
                </span>
                <span class="metodo-chevron"><i class="fas fa-chevron-down"></i></span>
            </summary>

            <div class="info-deposito">
                <p><strong>📥 Datos para tu depósito o transferencia:</strong></p>
                <table class="cuenta-deposito">
                    <tr><th>Beneficiario</th><td>FOLIO Biblioteca Digital S.A.</td></tr>
                    <tr><th>RUC</th>          <td>1791234567001</td></tr>
                    <tr><th>Tipo de cuenta</th><td>Corriente</td></tr>
                    <tr><th>Número de cuenta</th><td><code><%= numeroCuentaFicticia %></code></td></tr>
                    <tr><th>Monto exacto</th><td><strong style="color:var(--color-acento);">$ <%= String.format(java.util.Locale.US, "%.2f", carrito.getTotal()) %></strong></td></tr>
                </table>
                <small>El número de cuenta se genera por sesión para esta simulación académica.</small>
            </div>

            <form action="ProcesarPagoServlet" method="post" class="metodo-form">
                <input type="hidden" name="metodo" value="transferencia">

                <div class="form-grupo">
                    <label for="banco"><i class="fas fa-landmark"></i> Banco emisor</label>
                    <select id="banco" name="banco" required>
                        <option value="">— Selecciona tu banco —</option>
                        <option value="PICHINCHA">Banco Pichincha</option>
                        <option value="GUAYAQUIL">Banco Guayaquil</option>
                        <option value="PRODUBANCO">Produbanco</option>
                        <option value="PACIFICO">Banco del Pacífico</option>
                        <option value="BOLIVARIANO">Banco Bolivariano</option>
                        <option value="INTERNACIONAL">Banco Internacional</option>
                        <option value="AUSTRO">Banco del Austro</option>
                    </select>
                </div>

                <div class="form-grupo">
                    <label for="titularTransfer"><i class="fas fa-user"></i> Titular de la cuenta emisora</label>
                    <input type="text" id="titularTransfer" name="titularTransfer"
                           placeholder="Nombre completo del titular" required minlength="5"
                           pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ ]+">
                </div>

                <div class="form-grupo">
                    <label for="numComprobante"><i class="fas fa-receipt"></i> Número de comprobante</label>
                    <input type="text" id="numComprobante" name="numComprobante"
                           placeholder="Ej. 0123456789" required minlength="6" maxlength="20"
                           pattern="[0-9]{6,20}" inputmode="numeric">
                    <small>Encuéntralo en el recibo de tu transferencia.</small>
                </div>

                <button type="submit" class="btn"><i class="fas fa-check"></i>
                    Confirmar transferencia de $ <%= String.format(java.util.Locale.US, "%.2f", carrito.getTotal()) %></button>
            </form>
        </details>

        <details class="metodo-pago">
            <summary>
                <span class="metodo-icon" style="background:linear-gradient(135deg,#003087,#0070ba);color:#fff;"><i class="fab fa-paypal"></i></span>
                <span class="metodo-info">
                    <strong>PayPal</strong>
                    <small>Paga con tu cuenta PayPal (simulación)</small>
                </span>
                <span class="metodo-chevron"><i class="fas fa-chevron-down"></i></span>
            </summary>
            <form action="ProcesarPagoServlet" method="post" class="metodo-form">
                <input type="hidden" name="metodo" value="paypal">

                <div class="form-grupo">
                    <label for="emailPaypal"><i class="fas fa-envelope"></i> Correo de tu cuenta PayPal</label>
                    <input type="email" id="emailPaypal" name="emailPaypal"
                           placeholder="tu@correo.com" required>
                    <small>Serás redirigido a PayPal para confirmar la transacción.</small>
                </div>

                <button type="submit" class="btn" style="background:#0070ba;color:#fff;">
                    <i class="fab fa-paypal"></i>
                    Pagar $ <%= String.format(java.util.Locale.US, "%.2f", carrito.getTotal()) %> con PayPal
                </button>
            </form>
        </details>

        <a href="index.jsp?carrito=open" class="btn btn-secundario" style="text-align:center;text-decoration:none;display:block;margin-top:1rem;">
            <i class="fas fa-arrow-left"></i> Volver al carrito
        </a>

        <p class="pago-seguro-nota">
            <i class="fas fa-shield-alt"></i> Conexión cifrada &middot; Validación 100% server-side &middot; No almacenamos tu información financiera.
        </p>
    </div>
</main>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
