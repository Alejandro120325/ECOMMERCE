<%-- empleado.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List,
                 ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito, ec.edu.ups.modelo.Libro,
                 ec.edu.ups.dao.LibroDAO,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
    if (usrActivo == null
        || (!"EMPLEADO".equalsIgnoreCase(usrActivo.getRol())
         && !"ADMIN".equalsIgnoreCase(usrActivo.getRol()))) {
        response.sendRedirect("index.jsp");
        return;
    }

    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = "open".equals(request.getParameter("carrito"));

    String sec = request.getParameter("sec");
    if (sec == null || sec.isBlank()) sec = "inventario";
    String urlActual = "empleado.jsp?sec=" + sec;
    String msg       = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventario &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=110">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%@ include file="WEB-INF/jspf/header.jspf" %>

<div class="dashboard-container">

    <aside class="sidebar">
        <h3><i class="fas fa-boxes" style="color:var(--color-acento);"></i> Módulo Empleado</h3>
        <ul class="admin-nav">
            <li><a href="empleado.jsp?sec=inventario" class="<%= "inventario".equals(sec) ? "activo" : "" %>"><i class="fas fa-list"></i> Catálogo Actual</a></li>
            <li><a href="empleado.jsp?sec=agregar"    class="<%= "agregar".equals(sec)    ? "activo" : "" %>"><i class="fas fa-plus-circle"></i> Nuevo Libro</a></li>
            <li><a href="empleado.jsp?sec=descuentos" class="<%= "descuentos".equals(sec) ? "activo" : "" %>"><i class="fas fa-tags"></i> Ofertas y Descuentos</a></li>
        </ul>

        <%-- Si el usuario es ADMIN, ofrece atajo de regreso al panel central --%>
        <% if ("ADMIN".equalsIgnoreCase(usrActivo.getRol())) { %>
        <h3 style="margin-top:1.5rem;"><i class="fas fa-crown" style="color:var(--color-acento);"></i> Privilegios Admin</h3>
        <ul class="admin-nav">
            <li><a href="admin.jsp?sec=dashboard"><i class="fas fa-chart-line"></i> Dashboard General</a></li>
            <li><a href="admin.jsp?sec=usuarios"><i class="fas fa-users"></i> Gestión de Usuarios</a></li>
            <li><a href="admin.jsp?sec=ventas"><i class="fas fa-file-invoice-dollar"></i> Ventas y Reportes</a></li>
        </ul>
        <% } %>
    </aside>

    <main class="main-content">

        <% if (msg != null) {
            String texto; String clase = "exito";
            switch (msg) {
                case "creado":          texto = "Libro registrado correctamente en el catálogo."; break;
                case "eliminado":       texto = "Libro eliminado del catálogo.";                  break;
                case "error_crear":     texto = "No se pudo registrar el libro. Verifica los datos."; clase = "error"; break;
                case "error_eliminar":  texto = "No se pudo eliminar el libro.";                  clase = "error"; break;
                default:                texto = null;
            }
            if (texto != null) { %>
            <div class="mensaje <%= clase %>"><i class="fas fa-info-circle"></i> <%= texto %></div>
        <%  } } %>

        <% if ("inventario".equals(sec)) {
            List<Libro> libros = new LibroDAO().listarTodos();
        %>
        <section class="empleado-section">
            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-book"></i> Libros en Base de Datos</h3>
                    <a href="empleado.jsp?sec=agregar" class="btn-accion btn-primario" style="text-decoration:none;">
                        <i class="fas fa-plus"></i> Añadir Registro
                    </a>
                </div>
                <table>
                    <thead><tr><th>Portada</th><th>Título</th><th>Autor</th><th>Categoría</th><th>Precio</th><th>Acción</th></tr></thead>
                    <tbody>
                    <% for (Libro l : libros) { %>
                    <tr>
                        <td><img src="<%= l.getImagen() %>" alt="" class="img-miniatura"></td>
                        <td><strong><%= l.getTitulo() %></strong><br>
                            <small style="color:var(--color-texto-suave);">ID: <%= l.getId() %></small></td>
                        <td><%= l.getAutor() %></td>
                        <td><span class="badge badge-empleado"><%= l.getCategoria() %></span></td>
                        <td><strong style="color:var(--color-acento);">$ <%= String.format(java.util.Locale.US, "%.2f", l.getPrecio()) %></strong></td>
                        <td>
                            <form action="LibroAdminServlet" method="post" class="form-inline">
                                <input type="hidden" name="accion"  value="ELIMINAR_LIBRO">
                                <input type="hidden" name="libroId" value="<%= l.getId() %>">
                                <button type="submit" class="btn-accion btn-danger"><i class="fas fa-trash"></i> Eliminar</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <% } else if ("agregar".equals(sec)) { %>
        <section class="empleado-section">
            <div class="admin-panel" style="max-width:820px; margin:0 auto; width:100%;">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-plus-circle"></i> Registrar Nuevo Libro</h3>
                </div>

                <form action="LibroAdminServlet" method="post" style="display:flex; flex-direction:column; gap:1.2rem;">
                    <input type="hidden" name="accion" value="CREAR_LIBRO">

                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:1.2rem;">
                        <div class="form-grupo" style="margin:0;">
                            <label for="titulo">Título del libro</label>
                            <input type="text" id="titulo" name="titulo" required maxlength="200">
                            <small>El id (slug) se genera automáticamente desde el título.</small>
                        </div>
                        <div class="form-grupo" style="margin:0;">
                            <label for="autor">Autor</label>
                            <input type="text" id="autor" name="autor" required maxlength="200">
                        </div>
                    </div>

                    <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:1.2rem;">
                        <div class="form-grupo" style="margin:0;">
                            <label for="isbn">ISBN (único)</label>
                            <input type="text" id="isbn" name="isbn" required pattern="[0-9X]{10,20}" maxlength="20">
                        </div>
                        <div class="form-grupo" style="margin:0;">
                            <label for="precio">Precio ($)</label>
                            <input type="number" id="precio" name="precio" step="0.01" min="0" required>
                        </div>
                        <div class="form-grupo" style="margin:0;">
                            <label for="stock">Stock</label>
                            <input type="number" id="stock" name="stock" min="0" value="0" required>
                        </div>
                    </div>

                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:1.2rem;">
                        <div class="form-grupo" style="margin:0;">
                            <label for="categoria">Categoría</label>
                            <select id="categoria" name="categoria" required>
                                <option value="latinoamericana">Literatura Latinoamericana</option>
                                <option value="clasicos">Clásicos Mundiales</option>
                                <option value="ciencia">Ciencia Ficción y Distopía</option>
                                <option value="tecnologia">Tecnología e Ingeniería</option>
                                <option value="historia">Historia y Filosofía</option>
                                <option value="fantasia">Fantasía y Épica</option>
                                <option value="biografias">Biografías</option>
                                <option value="desarrollo">Desarrollo Personal</option>
                                <option value="manga">Manga</option>
                            </select>
                        </div>
                        <div class="form-grupo" style="margin:0;">
                            <label for="paginas">Páginas</label>
                            <input type="number" id="paginas" name="paginas" min="1" value="200" required>
                        </div>
                    </div>

                    <div class="form-grupo" style="margin:0;">
                        <label for="portadaUrl">URL de la portada</label>
                        <input type="url" id="portadaUrl" name="portadaUrl" placeholder="https://covers.openlibrary.org/b/isbn/...-L.jpg">
                    </div>

                    <button type="submit" class="btn"><i class="fas fa-save"></i> Guardar en Inventario</button>
                    <a href="empleado.jsp?sec=inventario" class="btn btn-secundario" style="text-align:center;text-decoration:none;">
                        <i class="fas fa-arrow-left"></i> Cancelar
                    </a>
                </form>
            </div>
        </section>

        <% } else if ("descuentos".equals(sec)) { %>
        <section class="empleado-section">

            <%-- Mensaje contextual de descuentos --%>
            <%
                String tDsc = null; String cDsc = "exito";
                if (msg != null) {
                    if (msg.startsWith("ok_")) {
                        String filas = msg.substring(3);
                        tDsc = "Descuento aplicado correctamente. " + filas + " libro(s) actualizado(s).";
                    } else if ("sin_cambios".equals(msg))     { tDsc = "No se actualizó ningún libro (verifica el id o la categoría).";  cDsc = "error"; }
                    else if ("pct_invalido".equals(msg))      { tDsc = "El porcentaje debe estar entre 1 y 90.";                          cDsc = "error"; }
                    else if ("falta_categoria".equals(msg))   { tDsc = "Debes elegir una categoría válida.";                              cDsc = "error"; }
                    else if ("falta_libro".equals(msg))       { tDsc = "Debes ingresar el id de un libro.";                               cDsc = "error"; }
                    else if ("modo_invalido".equals(msg))     { tDsc = "Modo de descuento inválido.";                                     cDsc = "error"; }
                }
                if (tDsc != null) {
            %>
            <div class="mensaje <%= cDsc %>"><i class="fas fa-info-circle"></i> <%= tDsc %></div>
            <% } %>

            <div class="admin-panel" style="max-width:820px; margin:0 auto; width:100%;">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-tags"></i> Gestionar Promociones</h3>
                    <span class="badge badge-empleado">Aplicar descuento</span>
                </div>

                <p style="color:var(--color-texto-suave); margin-bottom:1.5rem;">
                    Aplica un descuento porcentual sobre el precio actual de los libros.
                    Puedes elegir descontar una <strong>categoría completa</strong> o un
                    <strong>libro individual</strong>. El cambio se persiste en PostgreSQL
                    inmediatamente.
                </p>

                <%-- ====== Form 1: descuento por CATEGORÍA ====== --%>
                <form action="AplicarDescuentoServlet" method="post" style="display:flex; flex-direction:column; gap:1.2rem; margin-bottom:2rem;">
                    <input type="hidden" name="modo" value="categoria">

                    <h3 class="form-seccion-titulo"><i class="fas fa-layer-group"></i> Descuento por categoría</h3>

                    <div style="display:grid; grid-template-columns: 2fr 1fr; gap:1.2rem;">
                        <div class="form-grupo" style="margin:0;">
                            <label for="dsc-categoria">Categoría afectada</label>
                            <select id="dsc-categoria" name="categoria" required>
                                <option value="">— Selecciona una categoría —</option>
                                <option value="latinoamericana">Literatura Latinoamericana</option>
                                <option value="clasicos">Clásicos Mundiales</option>
                                <option value="ciencia">Ciencia Ficción y Distopía</option>
                                <option value="tecnologia">Tecnología e Ingeniería</option>
                                <option value="historia">Historia y Filosofía</option>
                                <option value="fantasia">Fantasía y Épica</option>
                                <option value="biografias">Biografías</option>
                                <option value="desarrollo">Desarrollo Personal</option>
                                <option value="manga">Manga</option>
                            </select>
                        </div>
                        <div class="form-grupo" style="margin:0;">
                            <label for="dsc-pct-cat">Descuento (%)</label>
                            <input type="number" id="dsc-pct-cat" name="porcentaje"
                                   min="1" max="90" step="1" placeholder="Ej. 15" required>
                        </div>
                    </div>

                    <button type="submit" class="btn-accion btn-primario" style="justify-content:center; padding:0.95rem;">
                        <i class="fas fa-percentage"></i> Aplicar descuento a la categoría
                    </button>
                </form>

                <%-- ====== Form 2: descuento POR LIBRO ====== --%>
                <form action="AplicarDescuentoServlet" method="post" style="display:flex; flex-direction:column; gap:1.2rem;">
                    <input type="hidden" name="modo" value="libro">

                    <h3 class="form-seccion-titulo"><i class="fas fa-book"></i> Descuento por libro específico</h3>

                    <div style="display:grid; grid-template-columns: 2fr 1fr; gap:1.2rem;">
                        <div class="form-grupo" style="margin:0;">
                            <label for="dsc-libro">ID del libro (slug)</label>
                            <input type="text" id="dsc-libro" name="libroId"
                                   placeholder="ej. cien-anios-soledad" required pattern="[a-z0-9-]+">
                            <small>El slug aparece en la columna "ID" del catálogo de inventario.</small>
                        </div>
                        <div class="form-grupo" style="margin:0;">
                            <label for="dsc-pct-libro">Descuento (%)</label>
                            <input type="number" id="dsc-pct-libro" name="porcentaje"
                                   min="1" max="90" step="1" placeholder="Ej. 20" required>
                        </div>
                    </div>

                    <button type="submit" class="btn-accion btn-primario" style="justify-content:center; padding:0.95rem;">
                        <i class="fas fa-percentage"></i> Aplicar descuento al libro
                    </button>
                </form>
            </div>
        </section>
        <% } %>

    </main>
</div>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
