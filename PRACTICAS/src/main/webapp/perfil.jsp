<%--
    perfil.jsp
    FOLIO - Perfil del cliente con historial de pedidos.
    --------------------------------------------------------------------
    Lee los pedidos de la tabla tb_pedido + tb_pedido_item a través del
    PedidoDAO. Renderizado 100% server-side, sin JavaScript.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List, java.text.SimpleDateFormat,
                 ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.modelo.Pedido, ec.edu.ups.modelo.ItemPedido,
                 ec.edu.ups.dao.PedidoDAO,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
    if (usrActivo == null) {
        response.sendRedirect("login.jsp?error=requiere_sesion");
        return;
    }

    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = "open".equals(request.getParameter("carrito"));
    String  urlActual     = "perfil.jsp";

    List<Pedido> pedidos = new PedidoDAO().listarPorUsuario(usrActivo.getId());
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi perfil &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=60">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%@ include file="WEB-INF/jspf/header.jspf" %>

<main class="dashboard-container" style="grid-template-columns: 280px minmax(0, 1fr);">

    <aside class="sidebar">
        <h3><i class="fas fa-user-circle" style="color:var(--color-acento);"></i> Mi cuenta</h3>
        <ul class="admin-nav">
            <li><a href="perfil.jsp" class="activo"><i class="fas fa-receipt"></i> Historial de pedidos</a></li>
            <li><a href="FiltrarLibrosServlet?categoria=todas"><i class="fas fa-book"></i> Volver al catálogo</a></li>
            <li><a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Cerrar sesión</a></li>
        </ul>
    </aside>

    <section class="main-content">

        <%-- Cabecera de identidad --%>
        <div class="kpi-grid" style="margin-bottom:1.5rem;">
            <div class="kpi-card">
                <span>Bienvenido</span>
                <h2 style="font-size:1.6rem; line-height:1.2;">
                    <%= usrActivo.getNombre() %> <%= usrActivo.getApellido() != null ? usrActivo.getApellido() : "" %>
                </h2>
                <small style="color:var(--color-texto-suave);"><%= usrActivo.getCorreo() %></small>
            </div>
            <div class="kpi-card">
                <span>Pedidos realizados</span>
                <h2><%= pedidos.size() %></h2>
            </div>
            <div class="kpi-card">
                <span>Total gastado</span>
                <%
                    double totalAcumulado = 0;
                    for (Pedido p : pedidos) totalAcumulado += p.getTotal();
                %>
                <h2>$ <%= String.format(java.util.Locale.US, "%.2f", totalAcumulado) %></h2>
            </div>
        </div>

        <%-- Tabla de pedidos --%>
        <div class="admin-panel">
            <div class="admin-panel-header">
                <h3><i class="fas fa-receipt"></i> Historial de pedidos</h3>
                <a href="FiltrarLibrosServlet?categoria=todas" class="btn-accion btn-primario" style="text-decoration:none;">
                    <i class="fas fa-plus"></i> Nueva compra
                </a>
            </div>

            <% if (pedidos.isEmpty()) { %>
                <div class="catalogo-vacio">
                    <i class="fas fa-receipt"></i>
                    <h3>Aún no has realizado pedidos</h3>
                    <p>Cuando compres tu primer libro, lo verás aquí con su detalle completo.</p>
                    <a href="FiltrarLibrosServlet?categoria=todas" class="btn-link">Explorar catálogo <i class="fas fa-arrow-right"></i></a>
                </div>
            <% } else { %>
                <table>
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Fecha</th>
                        <th>Items</th>
                        <th>Subtotal</th>
                        <th>IVA</th>
                        <th>Total</th>
                        <th>Pago</th>
                        <th>Estado</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Pedido p : pedidos) {
                        int itemsCount = 0;
                        StringBuilder titulos = new StringBuilder();
                        for (ItemPedido it : p.getItems()) {
                            itemsCount += it.getCantidad();
                            if (titulos.length() > 0) titulos.append(", ");
                            titulos.append(it.getTituloLibro() != null ? it.getTituloLibro() : it.getLibroId())
                                   .append(" ×").append(it.getCantidad());
                        }
                    %>
                    <tr>
                        <td><strong>#<%= p.getId() %></strong></td>
                        <td><%= p.getFecha() != null ? fmt.format(p.getFecha()) : "—" %></td>
                        <td style="font-size:0.85rem;color:var(--color-texto-suave);"><%= titulos.toString() %></td>
                        <td>$ <%= String.format(java.util.Locale.US, "%.2f", p.getSubtotal()) %></td>
                        <td>$ <%= String.format(java.util.Locale.US, "%.2f", p.getIva()) %></td>
                        <td><strong style="color:var(--color-acento);">$ <%= String.format(java.util.Locale.US, "%.2f", p.getTotal()) %></strong></td>
                        <td><%= p.getMarcaTarjeta() != null ? p.getMarcaTarjeta() : "—" %>
                            <% if (p.getUltimos4() != null) { %><small>•••• <%= p.getUltimos4() %></small><% } %>
                        </td>
                        <td><span class="badge badge-cliente"><%= p.getEstado() %></span></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>

    </section>

</main>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
