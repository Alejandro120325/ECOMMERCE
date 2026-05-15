<%--
    empleado.jsp
    FOLIO - Gestión de Inventario (CERO JavaScript).
    Navegación por query string ?sec=inventario|agregar|descuentos.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    // SEGURIDAD: sólo EMPLEADO o ADMIN
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
    if (usrActivo == null || (!"EMPLEADO".equalsIgnoreCase(usrActivo.getRol()) && !"ADMIN".equalsIgnoreCase(usrActivo.getRol()))) {
        response.sendRedirect("index.jsp");
        return;
    }

    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = "open".equals(request.getParameter("carrito"));

    String  sec           = request.getParameter("sec");
    if (sec == null || sec.isBlank()) sec = "inventario";
    String  urlActual     = "empleado.jsp?sec=" + sec;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventario &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=40">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>

<%@ include file="WEB-INF/jspf/header.jspf" %>

<div class="dashboard-container">

    <aside class="sidebar">
        <h3><i class="fas fa-boxes" style="color:#17a2b8;"></i> Módulo Empleado</h3>
        <ul class="admin-nav">
            <li><a href="empleado.jsp?sec=inventario" class="<%= "inventario".equals(sec) ? "activo" : "" %>"><i class="fas fa-list"></i> Catálogo Actual</a></li>
            <li><a href="empleado.jsp?sec=agregar"    class="<%= "agregar".equals(sec)    ? "activo" : "" %>"><i class="fas fa-plus-circle"></i> Nuevo Libro</a></li>
            <li><a href="empleado.jsp?sec=descuentos" class="<%= "descuentos".equals(sec) ? "activo" : "" %>"><i class="fas fa-tags"></i> Ofertas y Descuentos</a></li>
        </ul>
    </aside>

    <main class="main-content">

        <% if ("inventario".equals(sec)) { %>
        <section class="empleado-section">
            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-book"></i> Libros en Base de Datos</h3>
                    <a href="empleado.jsp?sec=agregar" class="btn-accion btn-primario" style="text-decoration:none;">
                        <i class="fas fa-plus"></i> Añadir Registro
                    </a>
                </div>
                <table>
                    <thead><tr><th>Portada</th><th>Título</th><th>Autor</th><th>Stock</th><th>Precio</th></tr></thead>
                    <tbody>
                    <tr>
                        <td><img src="https://covers.openlibrary.org/b/isbn/9780307474728-S.jpg" alt="Portada" class="img-miniatura"></td>
                        <td><strong>Cien años de soledad</strong><br><small style="color:var(--color-texto-suave);">Latinoamericana</small></td>
                        <td>Gabriel García Márquez</td>
                        <td>25</td>
                        <td><strong style="color:#17a2b8;">$ 18.90</strong></td>
                    </tr>
                    <tr>
                        <td><img src="https://covers.openlibrary.org/b/isbn/9780451524935-S.jpg" alt="Portada" class="img-miniatura"></td>
                        <td><strong>1984</strong><br><small style="color:var(--color-texto-suave);">Ciencia Ficción</small></td>
                        <td>George Orwell</td>
                        <td>30</td>
                        <td><strong style="color:#17a2b8;">$ 16.00</strong></td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </section>
        <% } else if ("agregar".equals(sec)) { %>
        <section class="empleado-section">
            <div class="admin-panel" style="max-width:800px; margin:0 auto; width:100%;">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-plus-circle"></i> Registrar Nuevo Libro</h3>
                </div>
                <form action="#" method="post" style="display:flex; flex-direction:column; gap:1.5rem;">
                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:1.5rem;">
                        <div class="form-grupo" style="margin:0;">
                            <label>Título del Libro</label>
                            <input type="text" name="titulo" required>
                        </div>
                        <div class="form-grupo" style="margin:0;">
                            <label>Autor</label>
                            <input type="text" name="autor" required>
                        </div>
                    </div>
                    <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:1.5rem;">
                        <div class="form-grupo" style="margin:0;"><label>ISBN</label><input type="text" name="isbn"></div>
                        <div class="form-grupo" style="margin:0;"><label>Precio ($)</label><input type="number" step="0.01" name="precio" required></div>
                        <div class="form-grupo" style="margin:0;"><label>Stock Inicial</label><input type="number" name="stock" value="0"></div>
                    </div>
                    <div class="form-grupo" style="margin:0;">
                        <label>Categoría</label>
                        <select name="categoria">
                            <option value="latinoamericana">Latinoamericana</option>
                            <option value="clasicos">Clásicos</option>
                            <option value="ciencia">Ciencia Ficción</option>
                            <option value="tecnologia">Tecnología e Ingeniería</option>
                            <option value="historia">Historia y Filosofía</option>
                            <option value="fantasia">Fantasía y Épica</option>
                            <option value="biografias">Biografías</option>
                            <option value="desarrollo">Desarrollo Personal</option>
                        </select>
                    </div>
                    <div class="form-grupo" style="margin:0;"><label>URL de la Portada</label><input type="url" name="portadaUrl"></div>
                    <div class="form-grupo" style="margin:0;"><label>Descripción / Sinopsis</label><textarea name="descripcion" rows="4"></textarea></div>
                    <button type="submit" class="btn-accion btn-primario" style="justify-content:center; padding:1rem;">
                        <i class="fas fa-save"></i> Guardar en Inventario
                    </button>
                </form>
            </div>
        </section>
        <% } else if ("descuentos".equals(sec)) { %>
        <section class="empleado-section">
            <div class="admin-panel">
                <div class="admin-panel-header"><h3><i class="fas fa-tags"></i> Gestionar Promociones</h3></div>
                <div style="text-align:center; padding:4rem 1rem; color:var(--color-texto-suave);">
                    <i class="fas fa-percent fa-3x" style="margin-bottom:1rem; opacity:0.3;"></i>
                    <p>Aquí se implementará la lógica para aplicar descuentos por categorías o a libros específicos.</p>
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
