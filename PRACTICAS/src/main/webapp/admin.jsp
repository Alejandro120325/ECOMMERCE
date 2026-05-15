<%--
    admin.jsp
    FOLIO - Dashboard de Administración (CERO JavaScript).
    ------------------------------------------------------------------
    La navegación entre secciones del dashboard se realiza por query
    string (?sec=dashboard|usuarios|ventas|config). Cada cambio de
    sección es una recarga server-side, sin SPA en cliente.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    // SEGURIDAD: solo ADMIN puede entrar
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
    if (usrActivo == null || !"ADMIN".equalsIgnoreCase(usrActivo.getRol())) {
        response.sendRedirect("index.jsp");
        return;
    }

    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = "open".equals(request.getParameter("carrito"));

    String  sec           = request.getParameter("sec");
    if (sec == null || sec.isBlank()) sec = "dashboard";
    String  urlActual     = "admin.jsp?sec=" + sec;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=40">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>

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
    </aside>

    <main class="main-content">

        <% if ("dashboard".equals(sec)) { %>
        <section class="admin-section">
            <div class="kpi-grid">
                <div class="kpi-card"><span>Total Ventas Mes</span><h2>$ 1,245.50</h2></div>
                <div class="kpi-card"><span>Usuarios Registrados</span><h2>142</h2></div>
                <div class="kpi-card"><span>Libros Vendidos</span><h2>87</h2></div>
            </div>
            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-shopping-bag"></i> Últimas Ventas</h3>
                </div>
                <table>
                    <thead><tr><th>ID Pedido</th><th>Cliente</th><th>Fecha</th><th>Total</th><th>Estado</th></tr></thead>
                    <tbody>
                    <tr><td>#10045</td><td>María Elena R.</td><td>Hace 2 horas</td><td><strong style="color:var(--color-acento);">$ 34.40</strong></td><td><span class="badge badge-cliente" style="color:#fff; background:#2ea043;">Completado</span></td></tr>
                    <tr><td>#10044</td><td>Juan Carlos M.</td><td>Hace 5 horas</td><td><strong style="color:var(--color-acento);">$ 21.00</strong></td><td><span class="badge badge-cliente" style="color:#fff; background:#2ea043;">Completado</span></td></tr>
                    </tbody>
                </table>
            </div>
        </section>
        <% } else if ("usuarios".equals(sec)) { %>
        <section class="admin-section">
            <div class="admin-panel">
                <div class="admin-panel-header"><h3><i class="fas fa-users-cog"></i> Directorio de Cuentas</h3></div>
                <table>
                    <thead><tr><th>ID</th><th>Nombre Completo</th><th>Correo</th><th>Rol</th></tr></thead>
                    <tbody>
                    <tr><td>101</td><td>María Elena R.</td><td>maria@correo.com</td><td><span class="badge badge-cliente">CLIENTE</span></td></tr>
                    <tr><td>102</td><td>Gestor Inventario</td><td>empleado@folio.com</td><td><span class="badge badge-empleado">EMPLEADO</span></td></tr>
                    </tbody>
                </table>
            </div>
        </section>
        <% } else if ("ventas".equals(sec)) { %>
        <section class="admin-section">
            <div class="admin-panel">
                <div class="admin-panel-header"><h3><i class="fas fa-chart-bar"></i> Reporte Detallado</h3></div>
                <div style="text-align:center; padding:4rem 1rem; color:var(--color-texto-suave);">
                    <i class="fas fa-tools fa-3x" style="margin-bottom:1rem; opacity:0.3;"></i>
                    <p>Módulo de gráficas en construcción. Conectaremos con los datos de PostgreSQL pronto.</p>
                </div>
            </div>
        </section>
        <% } else if ("config".equals(sec)) { %>
        <section class="admin-section">
            <div class="admin-panel">
                <div class="admin-panel-header"><h3><i class="fas fa-sliders-h"></i> Ajustes del Sistema</h3></div>
                <div style="text-align:center; padding:4rem 1rem; color:var(--color-texto-suave);">
                    <i class="fas fa-cogs fa-3x" style="margin-bottom:1rem; opacity:0.3;"></i>
                    <p>Aquí podrás gestionar variables globales, impuestos y correos del sistema.</p>
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
