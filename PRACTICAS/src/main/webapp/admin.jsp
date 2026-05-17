<%-- admin.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List, java.text.SimpleDateFormat,
                 ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito, ec.edu.ups.modelo.Pedido,
                 ec.edu.ups.dao.UsuarioDAO, ec.edu.ups.dao.PedidoDAO,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    // ---- SEGURIDAD: sólo ADMIN ----
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
    if (usrActivo == null || !"ADMIN".equalsIgnoreCase(usrActivo.getRol())) {
        response.sendRedirect("index.jsp");
        return;
    }

    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = "open".equals(request.getParameter("carrito"));

    String sec = request.getParameter("sec");
    if (sec == null || sec.isBlank()) sec = "dashboard";
    String urlActual = "admin.jsp?sec=" + sec;
    String msg       = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=110">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%@ include file="WEB-INF/jspf/header.jspf" %>

<div class="dashboard-container">

    <aside class="sidebar">
        <h3><i class="fas fa-crown" style="color:var(--color-acento);"></i> Panel Central</h3>
        <ul class="admin-nav">
            <li><a href="admin.jsp?sec=dashboard" class="<%= "dashboard".equals(sec) ? "activo" : "" %>"><i class="fas fa-chart-line"></i> Dashboard General</a></li>
            <li><a href="admin.jsp?sec=usuarios"  class="<%= "usuarios".equals(sec)  ? "activo" : "" %>"><i class="fas fa-users"></i> Gestión de Usuarios</a></li>
            <li><a href="admin.jsp?sec=ventas"    class="<%= "ventas".equals(sec)    ? "activo" : "" %>"><i class="fas fa-file-invoice-dollar"></i> Ventas y Reportes</a></li>
            <li><a href="admin.jsp?sec=config"    class="<%= "config".equals(sec)    ? "activo" : "" %>"><i class="fas fa-cog"></i> Configuración</a></li>
        </ul>

        <%-- ADMIN HEREDA EMPLEADO — acceso directo desde la misma sidebar --%>
        <h3 style="margin-top:1.5rem;"><i class="fas fa-boxes" style="color:var(--color-acento);"></i> Módulo Empleado</h3>
        <ul class="admin-nav">
            <li><a href="empleado.jsp?sec=inventario"><i class="fas fa-list"></i> Catálogo Actual</a></li>
            <li><a href="empleado.jsp?sec=agregar"><i class="fas fa-plus-circle"></i> Nuevo Libro</a></li>
            <li><a href="empleado.jsp?sec=descuentos"><i class="fas fa-tags"></i> Ofertas y Descuentos</a></li>
        </ul>
    </aside>

    <main class="main-content">

        <%-- Mensaje contextual (después de una acción POST) --%>
        <% if (msg != null) {
            String texto; String clase = "exito";
            switch (msg) {
                case "suspendido": texto = "Usuario suspendido correctamente."; break;
                case "activado":   texto = "Usuario reactivado.";                break;
                case "eliminado":  texto = "Usuario eliminado de la base.";      break;
                case "no_self":    texto = "No puedes modificar tu propia cuenta desde aquí."; clase = "error"; break;
                case "error":      texto = "La operación no pudo completarse.";  clase = "error"; break;
                default:           texto = null;
            }
            if (texto != null) { %>
            <div class="mensaje <%= clase %>"><i class="fas fa-info-circle"></i> <%= texto %></div>
        <%  } } %>

        <% if ("dashboard".equals(sec)) {
            int totalUsuarios = new UsuarioDAO().listarTodos().size();
        %>
        <section class="admin-section">
            <div class="kpi-grid">
                <div class="kpi-card">
                    <span>Estado del sistema</span>
                    <h2 style="font-size:1.6rem;">🟢 Operativo</h2>
                </div>
                <div class="kpi-card">
                    <span>Usuarios Registrados</span>
                    <h2><%= totalUsuarios %></h2>
                </div>
                <div class="kpi-card">
                    <span>IVA configurado</span>
                    <h2>15 %</h2>
                </div>
            </div>

            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-shopping-bag"></i> Resumen Operativo</h3>
                    <span class="badge badge-cliente">Tiempo real</span>
                </div>
                <p style="color:var(--color-texto-suave); margin-bottom:1rem;">
                    Visita <strong><a href="admin.jsp?sec=ventas" style="color:var(--color-acento);">Ventas y Reportes</a></strong>
                    para ver las transacciones recientes, o <strong><a href="admin.jsp?sec=usuarios" style="color:var(--color-acento);">Gestión de Usuarios</a></strong>
                    para administrar cuentas.
                </p>
            </div>
        </section>

        <% } else if ("usuarios".equals(sec)) {
            // 1) Invocar al DAO y publicar la lista como atributo de petición.
            //    Este es el fragmento que el requerimiento pidió: scriptlet -> request -> JSTL.
            List<Usuario> usuariosLista = new UsuarioDAO().listarTodos();
            request.setAttribute("usuariosLista", usuariosLista);
            request.setAttribute("totalUsuarios", usuariosLista.size());
            request.setAttribute("adminId",       usrActivo.getId());
        %>
        <section class="admin-section">
            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-users-cog"></i> Directorio de Cuentas</h3>
                    <span class="badge badge-empleado">${totalUsuarios} cuenta${totalUsuarios eq 1 ? '' : 's'}</span>
                </div>

                <%-- 2) Render JSTL — sin scriptlets dentro de la tabla --%>
                <c:choose>
                    <c:when test="${empty usuariosLista}">
                        <p style="text-align:center; color:var(--color-texto-suave); padding:2rem;">
                            <i class="fas fa-info-circle" style="font-size:1.5rem; opacity:0.6; margin-right:0.4rem;"></i>
                            No se pudieron cargar usuarios. Verifica la conexión a PostgreSQL
                            y que la tabla <code>tb_usuario</code> exista
                            (ejecuta <code>src/main/webapp/db/folio_setup.sql</code>).
                        </p>
                    </c:when>
                    <c:otherwise>
                        <table>
                            <thead>
                            <tr>
                                <th>ID</th><th>Nombre Completo</th><th>Cédula</th>
                                <th>Correo</th><th>Rol</th><th>Estado</th><th>Acciones</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="u" items="${usuariosLista}">
                                <tr>
                                    <td><strong>#${u.id}</strong></td>
                                    <td>${u.nombre} ${u.apellido}</td>
                                    <td><c:out value="${empty u.cedula ? '—' : u.cedula}"/></td>
                                    <td>${u.correo}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.rol eq 'ADMIN' or u.rol eq 'EMPLEADO'}">
                                                <span class="badge badge-empleado">${u.rol}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-cliente">${u.rol}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.activo}">
                                                <span class="badge badge-cliente"><i class="fas fa-check-circle"></i> ACTIVO</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge" style="background:rgba(218,54,51,0.15);color:#ff8b88;border:1px solid rgba(218,54,51,0.35);">
                                                    <i class="fas fa-pause-circle"></i> SUSPENDIDO
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.id eq adminId}">
                                                <em style="color:var(--color-texto-suave); font-size:0.8rem;">(tú mismo)</em>
                                            </c:when>
                                            <c:otherwise>
                                                <div style="display:flex; gap:0.4rem; flex-wrap:wrap;">
                                                    <c:choose>
                                                        <c:when test="${u.activo}">
                                                            <form action="GestionUsuariosServlet" method="post" class="form-inline">
                                                                <input type="hidden" name="accion" value="SUSPENDER">
                                                                <input type="hidden" name="id"     value="${u.id}">
                                                                <button type="submit" class="btn-accion btn-warn"><i class="fas fa-user-slash"></i> Suspender</button>
                                                            </form>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form action="GestionUsuariosServlet" method="post" class="form-inline">
                                                                <input type="hidden" name="accion" value="ACTIVAR">
                                                                <input type="hidden" name="id"     value="${u.id}">
                                                                <button type="submit" class="btn-accion btn-success"><i class="fas fa-user-check"></i> Activar</button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <form action="GestionUsuariosServlet" method="post" class="form-inline">
                                                        <input type="hidden" name="accion" value="ELIMINAR">
                                                        <input type="hidden" name="id"     value="${u.id}">
                                                        <button type="submit" class="btn-accion btn-danger"><i class="fas fa-trash"></i> Eliminar</button>
                                                    </form>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <% } else if ("ventas".equals(sec)) {
            List<Pedido> todosLosPedidos = new PedidoDAO().listarPorUsuario(usrActivo.getId());
            // NOTA: para un dashboard real "global" se requeriría un método listarTodos() en PedidoDAO.
            // Como demo, mostramos los del admin actual + agregados.
            SimpleDateFormat fmtRep = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            double sumaSubt = 0, sumaIva = 0, sumaTot = 0;
            for (Pedido p : todosLosPedidos) {
                sumaSubt += p.getSubtotal();
                sumaIva  += p.getIva();
                sumaTot  += p.getTotal();
            }
        %>
        <section class="admin-section">
            <div class="kpi-grid">
                <div class="kpi-card"><span>Subtotal acumulado</span><h2>$ <%= String.format(java.util.Locale.US, "%.2f", sumaSubt) %></h2></div>
                <div class="kpi-card"><span>IVA recaudado (15%)</span><h2>$ <%= String.format(java.util.Locale.US, "%.2f", sumaIva)  %></h2></div>
                <div class="kpi-card"><span>Total facturado</span><h2>$ <%= String.format(java.util.Locale.US, "%.2f", sumaTot)  %></h2></div>
            </div>

            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-chart-bar"></i> Reporte Detallado de Ventas</h3>
                </div>
                <% if (todosLosPedidos.isEmpty()) { %>
                    <p style="text-align:center; color:var(--color-texto-suave); padding:3rem;">
                        <i class="fas fa-receipt" style="font-size:2.5rem; opacity:0.3; display:block; margin-bottom:0.8rem;"></i>
                        Aún no hay ventas que reportar.
                    </p>
                <% } else { %>
                <table>
                    <thead><tr><th>Pedido</th><th>Fecha</th><th>Cliente</th><th>Items</th><th>Subtotal</th><th>IVA</th><th>Total</th><th>Pago</th></tr></thead>
                    <tbody>
                    <% for (Pedido p : todosLosPedidos) { %>
                    <tr>
                        <td><strong>#<%= p.getId() %></strong></td>
                        <td><%= p.getFecha() != null ? fmtRep.format(p.getFecha()) : "—" %></td>
                        <td><%= p.getUsuarioId() != null ? "#" + p.getUsuarioId() : "Invitado" %></td>
                        <td><%= p.getItems() != null ? p.getItems().size() : 0 %></td>
                        <td>$ <%= String.format(java.util.Locale.US, "%.2f", p.getSubtotal()) %></td>
                        <td>$ <%= String.format(java.util.Locale.US, "%.2f", p.getIva())      %></td>
                        <td><strong style="color:var(--color-acento);">$ <%= String.format(java.util.Locale.US, "%.2f", p.getTotal()) %></strong></td>
                        <td><%= p.getMarcaTarjeta() != null ? p.getMarcaTarjeta() : "—" %></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </section>

        <% } else if ("config".equals(sec)) { %>
        <section class="admin-section">
            <div class="admin-panel">
                <div class="admin-panel-header"><h3><i class="fas fa-sliders-h"></i> Ajustes del Sistema</h3></div>
                <div class="kpi-grid" style="margin-top:1rem;">
                    <div class="kpi-card"><span>Tema activo</span><h2 style="font-size:1.6rem;text-transform:uppercase;">${empty sessionScope.tema ? 'dark' : sessionScope.tema}</h2></div>
                    <div class="kpi-card"><span>Encoding global</span><h2 style="font-size:1.6rem;">UTF-8</h2></div>
                    <div class="kpi-card"><span>IVA actual</span><h2>15 %</h2></div>
                </div>
            </div>
        </section>
        <% } %>

    </main>
</div>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
