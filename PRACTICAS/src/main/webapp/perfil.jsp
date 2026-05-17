<%-- FOLIO - Perfil del cliente --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List, java.text.SimpleDateFormat,
                 ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.modelo.Pedido, ec.edu.ups.modelo.ItemPedido,
                 ec.edu.ups.dao.PedidoDAO,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<%
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
    if (usrActivo == null) {
        response.sendRedirect("login.jsp?error=requiere_sesion");
        return;
    }

    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = "open".equals(request.getParameter("carrito"));

    String sec = request.getParameter("sec");
    if (sec == null || sec.isBlank()) sec = "historial";
    String urlActual = "perfil.jsp?sec=" + sec;
    String msg       = request.getParameter("msg");

    // --- DATOS PARA JSTL ---
    List<Pedido> pedidos = new PedidoDAO().listarPorUsuario(usrActivo.getId());
    request.setAttribute("pedidos", pedidos);
    request.setAttribute("usuario", usrActivo);
    request.setAttribute("fmt", new SimpleDateFormat("dd/MM/yyyy HH:mm"));

    double totalAcumulado = 0;
    for (Pedido p : pedidos) totalAcumulado += p.getTotal();
    request.setAttribute("totalAcumulado", totalAcumulado);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi perfil &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=110">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%@ include file="WEB-INF/jspf/header.jspf" %>

<main class="dashboard-container">

    <%-- --- SIDEBAR --- --%>
    <aside class="sidebar">
        <h3><i class="fas fa-user-circle" style="color:var(--color-acento);"></i> Mi cuenta</h3>
        <ul class="admin-nav">
            <li><a href="perfil.jsp?sec=historial" class="<%= "historial".equals(sec) ? "activo" : "" %>"><i class="fas fa-receipt"></i> Historial de pedidos</a></li>
            <li><a href="perfil.jsp?sec=editar"    class="<%= "editar".equals(sec)    ? "activo" : "" %>"><i class="fas fa-user-edit"></i> Editar perfil</a></li>
            <li><a href="perfil.jsp?sec=eliminar"  class="<%= "eliminar".equals(sec)  ? "activo" : "" %>" style="color:#ff8b88;"><i class="fas fa-user-times"></i> Eliminar cuenta</a></li>
        </ul>

        <h3 style="margin-top:1.5rem;"><i class="fas fa-store" style="color:var(--color-acento);"></i> Tienda</h3>
        <ul class="admin-nav">
            <li><a href="FiltrarLibrosServlet?categoria=todas"><i class="fas fa-book"></i> Catálogo</a></li>
            <li><a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Cerrar sesión</a></li>
        </ul>
    </aside>

    <%-- --- MAIN --- --%>
    <section class="main-content">

        <%-- --- KPIs --- --%>
        <div class="kpi-grid">
            <div class="kpi-card">
                <span>Bienvenido</span>
                <h2 style="font-size:1.6rem; line-height:1.2;">
                    ${usuario.nombre}<c:if test="${not empty usuario.apellido}"> ${usuario.apellido}</c:if>
                </h2>
                <small style="color:var(--color-texto-suave);">${usuario.correo}</small>
            </div>
            <div class="kpi-card">
                <span>Pedidos realizados</span>
                <h2>${pedidos.size()}</h2>
            </div>
            <div class="kpi-card">
                <span>Total gastado</span>
                <h2>$ <%= String.format(java.util.Locale.US, "%.2f", totalAcumulado) %></h2>
            </div>
        </div>

        <%-- --- MENSAJES CONTEXTUALES --- --%>
        <%
            String texto = null, clase = "exito";
            if (msg != null) switch (msg) {
                case "ok":                      texto = "Perfil actualizado correctamente."; break;
                case "datos_invalidos":         texto = "Nombre y apellido deben tener al menos 2 caracteres."; clase = "error"; break;
                case "telefono_invalido":       texto = "Teléfono inválido. Móvil 10 dígitos (09…) o fijo 9 dígitos (02…07)."; clase = "error"; break;
                case "clave_actual_incorrecta": texto = "La contraseña actual no es correcta."; clase = "error"; break;
                case "clave_invalida":          texto = "La clave nueva debe tener al menos 8 caracteres y coincidir con la confirmación."; clase = "error"; break;
                case "foto_formato":            texto = "Formato de foto no soportado. Sólo JPG, PNG, WEBP o GIF."; clase = "error"; break;
                case "confirma_texto":          texto = "Debes escribir ELIMINAR para confirmar la baja."; clase = "error"; break;
                case "clave_incorrecta":        texto = "Contraseña incorrecta. La cuenta NO fue eliminada."; clase = "error"; break;
                case "error":
                case "error_borrado":           texto = "No se pudo completar la operación."; clase = "error"; break;
            }
            if (texto != null) {
        %>
        <div class="mensaje <%= clase %>"><i class="fas fa-info-circle"></i> <%= texto %></div>
        <% } %>

        <%-- =============== HISTORIAL DE PEDIDOS =============== --%>
        <% if ("historial".equals(sec)) { %>
        <div class="admin-panel">
            <div class="admin-panel-header">
                <h3><i class="fas fa-receipt"></i> Historial de pedidos</h3>
                <a href="FiltrarLibrosServlet?categoria=todas" class="btn-accion btn-primario" style="text-decoration:none;">
                    <i class="fas fa-plus"></i> Nueva compra
                </a>
            </div>

            <c:choose>
                <c:when test="${empty pedidos}">
                    <div class="catalogo-vacio">
                        <i class="fas fa-receipt"></i>
                        <h3>Aún no has realizado pedidos</h3>
                        <p>Cuando compres tu primer libro, lo verás aquí con su detalle completo.</p>
                        <a href="FiltrarLibrosServlet?categoria=todas" class="btn-link">Explorar catálogo <i class="fas fa-arrow-right"></i></a>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                        <tr>
                            <th>#</th><th>Fecha</th><th>Items</th>
                            <th>Subtotal</th><th>IVA</th><th>Total</th>
                            <th>Pago</th><th>Estado</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="p" items="${pedidos}">
                            <tr>
                                <td><strong>#${p.id}</strong></td>
                                <td><fmt:formatDate value="${p.fecha}" pattern="dd/MM/yyyy HH:mm"/></td>
                                <td style="font-size:0.85rem;color:var(--color-texto-suave);">
                                    <c:forEach var="it" items="${p.items}" varStatus="s">
                                        <c:if test="${!s.first}">, </c:if>${not empty it.tituloLibro ? it.tituloLibro : it.libroId} &times;${it.cantidad}
                                    </c:forEach>
                                </td>
                                <td>$ <fmt:formatNumber value="${p.subtotal}" maxFractionDigits="2" minFractionDigits="2"/></td>
                                <td>$ <fmt:formatNumber value="${p.iva}" maxFractionDigits="2" minFractionDigits="2"/></td>
                                <td><strong style="color:var(--color-acento);">$ <fmt:formatNumber value="${p.total}" maxFractionDigits="2" minFractionDigits="2"/></strong></td>
                                <td>
                                    ${p.marcaTarjeta}
                                    <c:if test="${not empty p.ultimos4}"><small>&bull;&bull;&bull;&bull; ${p.ultimos4}</small></c:if>
                                </td>
                                <td><span class="badge badge-cliente">${p.estado}</span></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
        <% } %>

        <%-- =============== EDITAR PERFIL =============== --%>
        <% if ("editar".equals(sec)) { %>
        <div class="admin-panel" style="max-width:820px; margin:0 auto; width:100%;">
            <div class="admin-panel-header">
                <h3><i class="fas fa-user-edit"></i> Editar mi perfil</h3>
                <span class="badge badge-empleado">Datos personales</span>
            </div>

            <form action="ActualizarPerfilServlet" method="post" enctype="multipart/form-data" style="display:flex; flex-direction:column; gap:1.2rem;">

                <%-- --- FOTO DE PERFIL --- --%>
                <div class="foto-perfil-grupo">
                    <div class="foto-perfil-actual">
                        <c:choose>
                            <c:when test="${not empty usuario.fotoPerfil}">
                                <img src="uploads/${usuario.fotoPerfil}" alt="Foto perfil" class="foto-actual">
                            </c:when>
                            <c:otherwise>
                                <div class="foto-placeholder"><i class="fas fa-user"></i></div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="foto-perfil-input">
                        <label for="fotoPerfil"><i class="fas fa-camera"></i> Foto de perfil</label>
                        <input type="file" id="fotoPerfil" name="fotoPerfil"
                               accept="image/png, image/jpeg, image/jpg, image/webp">
                        <small>JPG, PNG o WEBP &middot; máximo 5MB. Déjalo vacío para conservar la actual.</small>
                    </div>
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:1.2rem;">
                    <div class="form-grupo" style="margin:0;">
                        <label for="ed-nombre">Nombre</label>
                        <input type="text" id="ed-nombre" name="nombre" value="${usuario.nombre}" required minlength="2" maxlength="80">
                    </div>
                    <div class="form-grupo" style="margin:0;">
                        <label for="ed-apellido">Apellido</label>
                        <input type="text" id="ed-apellido" name="apellido" value="${usuario.apellido}" required minlength="2" maxlength="80">
                    </div>
                </div>

                <div class="form-grupo" style="margin:0;">
                    <label for="ed-telefono">Teléfono (Ecuador)</label>
                    <input type="tel" id="ed-telefono" name="telefono" value="${usuario.telefono}"
                           pattern="(09[0-9]{8})|(0[2-7][0-9]{7})" maxlength="10" inputmode="numeric">
                    <small>Móvil 09xxxxxxxx · Fijo 0[2-7]xxxxxxx.</small>
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:1.2rem;">
                    <div class="form-grupo" style="margin:0;">
                        <label for="ed-provincia">Provincia</label>
                        <input type="text" id="ed-provincia" name="provincia" value="${usuario.provincia}" maxlength="60">
                    </div>
                    <div class="form-grupo" style="margin:0;">
                        <label for="ed-ciudad">Ciudad</label>
                        <input type="text" id="ed-ciudad" name="ciudad" value="${usuario.ciudad}" maxlength="60">
                    </div>
                </div>

                <div class="form-grupo" style="margin:0;">
                    <label for="ed-direccion">Dirección domiciliaria</label>
                    <textarea id="ed-direccion" name="direccion" rows="2" maxlength="200">${usuario.direccion}</textarea>
                </div>

                <h3 class="form-seccion-titulo"><i class="fas fa-key"></i> Cambiar contraseña <small style="color:var(--color-texto-suave);">(opcional)</small></h3>

                <div class="form-grupo" style="margin:0;">
                    <label for="cp-actual">Contraseña actual</label>
                    <div class="campo-clave">
                        <input type="checkbox" id="ver-cp-1" class="ojo-toggle" tabindex="-1" aria-hidden="true">
                        <input type="text" id="cp-actual" name="claveActual" class="input-password" autocomplete="current-password" spellcheck="false">
                        <label for="ver-cp-1" class="ojo"><i class="fas fa-eye icono-mostrar"></i><i class="fas fa-eye-slash icono-ocultar"></i></label>
                    </div>
                </div>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:1.2rem;">
                    <div class="form-grupo" style="margin:0;">
                        <label for="cp-nueva">Contraseña nueva</label>
                        <div class="campo-clave">
                            <input type="checkbox" id="ver-cp-2" class="ojo-toggle" tabindex="-1" aria-hidden="true">
                            <input type="text" id="cp-nueva" name="claveNueva" class="input-password" minlength="8" autocomplete="new-password" spellcheck="false">
                            <label for="ver-cp-2" class="ojo"><i class="fas fa-eye icono-mostrar"></i><i class="fas fa-eye-slash icono-ocultar"></i></label>
                        </div>
                    </div>
                    <div class="form-grupo" style="margin:0;">
                        <label for="cp-confirm">Confirmar nueva</label>
                        <div class="campo-clave">
                            <input type="checkbox" id="ver-cp-3" class="ojo-toggle" tabindex="-1" aria-hidden="true">
                            <input type="text" id="cp-confirm" name="claveConfirm" class="input-password" minlength="8" autocomplete="new-password" spellcheck="false">
                            <label for="ver-cp-3" class="ojo"><i class="fas fa-eye icono-mostrar"></i><i class="fas fa-eye-slash icono-ocultar"></i></label>
                        </div>
                    </div>
                </div>

                <button type="submit" class="btn"><i class="fas fa-save"></i> Guardar cambios</button>
                <a href="perfil.jsp?sec=historial" class="btn btn-secundario" style="text-align:center;text-decoration:none;">
                    <i class="fas fa-arrow-left"></i> Cancelar
                </a>
            </form>
        </div>
        <% } %>

        <%-- =============== ELIMINAR CUENTA =============== --%>
        <% if ("eliminar".equals(sec)) { %>
        <div class="admin-panel zona-peligro" style="max-width:680px; margin:0 auto; width:100%;">
            <div class="admin-panel-header">
                <h3 style="color:#ff8b88;"><i class="fas fa-triangle-exclamation"></i> Eliminar mi cuenta</h3>
                <span class="badge" style="background:rgba(218,54,51,0.15);color:#ff8b88;border:1px solid rgba(218,54,51,0.4);">Acción irreversible</span>
            </div>

            <div class="aviso-peligro">
                <p><strong>Esta acción eliminará permanentemente:</strong></p>
                <ul>
                    <li>Tu cuenta de FOLIO (${usuario.correo})</li>
                    <li>Tu información de perfil completa</li>
                    <li>La sesión actual se cerrará automáticamente</li>
                </ul>
                <p style="color:var(--color-texto-suave); font-size:0.9rem; margin:0;">
                    Tus pedidos pasados se conservarán para fines contables pero quedarán
                    desvinculados de tu identidad.
                </p>
            </div>

            <form action="EliminarCuentaServlet" method="post" style="display:flex; flex-direction:column; gap:1.2rem;">

                <div class="form-grupo" style="margin:0;">
                    <label for="del-clave">Confirma con tu contraseña</label>
                    <div class="campo-clave">
                        <input type="checkbox" id="ver-del-1" class="ojo-toggle" tabindex="-1" aria-hidden="true">
                        <input type="text" id="del-clave" name="claveActual" class="input-password" required spellcheck="false">
                        <label for="ver-del-1" class="ojo"><i class="fas fa-eye icono-mostrar"></i><i class="fas fa-eye-slash icono-ocultar"></i></label>
                    </div>
                </div>

                <div class="form-grupo" style="margin:0;">
                    <label for="del-conf">Escribe <code>ELIMINAR</code> para confirmar</label>
                    <input type="text" id="del-conf" name="confirmar" required pattern="ELIMINAR" placeholder="ELIMINAR">
                    <small style="color:var(--color-texto-suave);">El texto debe coincidir exactamente.</small>
                </div>

                <button type="submit" class="btn-accion btn-danger" style="justify-content:center; padding:0.95rem; font-size:1rem;">
                    <i class="fas fa-trash"></i> Eliminar mi cuenta para siempre
                </button>
                <a href="perfil.jsp?sec=historial" class="btn btn-secundario" style="text-align:center;text-decoration:none;">
                    <i class="fas fa-arrow-left"></i> Cancelar y volver
                </a>
            </form>
        </div>
        <% } %>

    </section>

</main>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
