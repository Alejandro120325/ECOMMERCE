<%--
    catalogo.jsp
    FOLIO - Vista del catálogo filtrado por categoría.
    ------------------------------------------------------------------
    Recibe del FiltrarLibrosServlet:
      * request attribute "libros"          (List<Libro>)
      * request attribute "categoriaSlug"   (String)
      * request attribute "categoriaNombre" (String legible)

    Si se accede directamente (sin pasar por el servlet) consultamos
    todo el catálogo. Sin JavaScript en ningún punto.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.*,
                 ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Libro, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.dao.LibroDAO, ec.edu.ups.controlador.CarritoServlet,
                 ec.edu.ups.util.LibroRenderer" %>
<%
    Usuario usrActivo     = (Usuario) session.getAttribute("usuarioActivo");
    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = "open".equals(request.getParameter("carrito"));

    // Si se accede directamente (no via servlet) usamos el DAO directamente
    List<Libro> libros           = (List<Libro>) request.getAttribute("libros");
    String      categoriaSlug    = (String)       request.getAttribute("categoriaSlug");
    String      categoriaNombre  = (String)       request.getAttribute("categoriaNombre");
    if (libros == null) {
        libros          = new LibroDAO().listarTodos();
        categoriaSlug   = "todas";
        categoriaNombre = "Catálogo completo";
    }

    // URL actual (para mantener carrito=open y construir redirects)
    String urlActual = "catalogo.jsp";
    if (categoriaSlug != null && !"todas".equalsIgnoreCase(categoriaSlug)) {
        urlActual = "FiltrarLibrosServlet?categoria=" + categoriaSlug;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catálogo &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=40">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>

<%@ include file="WEB-INF/jspf/header.jspf" %>

<main class="catalogo-main">

    <header class="catalogo-titulo">
        <span class="eyebrow">CATÁLOGO</span>
        <h2><%= categoriaNombre %></h2>
        <p>Mostrando <strong><%= libros.size() %></strong> título<%= libros.size() == 1 ? "" : "s" %>.
            Pasa el cursor sobre cualquier libro para girarlo en 360°.</p>

        <%-- Filtros (links a FiltrarLibrosServlet) --%>
        <nav class="filtros-categoria" aria-label="Filtros por categoría">
            <a href="FiltrarLibrosServlet?categoria=todas"
               class="<%= "todas".equalsIgnoreCase(categoriaSlug) ? "activo" : "" %>">Todas</a>
            <a href="FiltrarLibrosServlet?categoria=latinoamericana"
               class="<%= "latinoamericana".equalsIgnoreCase(categoriaSlug) ? "activo" : "" %>">Latinoamericana</a>
            <a href="FiltrarLibrosServlet?categoria=clasicos"
               class="<%= "clasicos".equalsIgnoreCase(categoriaSlug) ? "activo" : "" %>">Clásicos</a>
            <a href="FiltrarLibrosServlet?categoria=ciencia"
               class="<%= "ciencia".equalsIgnoreCase(categoriaSlug) ? "activo" : "" %>">Ciencia Ficción</a>
            <a href="FiltrarLibrosServlet?categoria=tecnologia"
               class="<%= "tecnologia".equalsIgnoreCase(categoriaSlug) ? "activo" : "" %>">Tecnología</a>
            <a href="FiltrarLibrosServlet?categoria=historia"
               class="<%= "historia".equalsIgnoreCase(categoriaSlug) ? "activo" : "" %>">Historia y Filosofía</a>
            <a href="FiltrarLibrosServlet?categoria=fantasia"
               class="<%= "fantasia".equalsIgnoreCase(categoriaSlug) ? "activo" : "" %>">Fantasía</a>
            <a href="FiltrarLibrosServlet?categoria=biografias"
               class="<%= "biografias".equalsIgnoreCase(categoriaSlug) ? "activo" : "" %>">Biografías</a>
            <a href="FiltrarLibrosServlet?categoria=desarrollo"
               class="<%= "desarrollo".equalsIgnoreCase(categoriaSlug) ? "activo" : "" %>">Desarrollo</a>
            <a href="FiltrarLibrosServlet?categoria=manga"
               class="<%= "manga".equalsIgnoreCase(categoriaSlug) ? "activo" : "" %>">Manga</a>
        </nav>
    </header>

    <% if (libros.isEmpty()) { %>
        <div class="catalogo-vacio">
            <i class="fas fa-book-open"></i>
            <h3>Sin resultados en esta categoría</h3>
            <p>Prueba con otra sección o explora el catálogo completo.</p>
            <a href="FiltrarLibrosServlet?categoria=todas" class="btn-link">Ver todos los libros <i class="fas fa-arrow-right"></i></a>
        </div>
    <% } else { %>
        <%-- Si la categoría es "todas", agrupamos por categoría para una vista editorial. --%>
        <% if ("todas".equalsIgnoreCase(categoriaSlug)) {
            Map<String, List<Libro>> grupos = new LinkedHashMap<>();
            for (Libro l : libros) {
                grupos.computeIfAbsent(l.getCategoria(), k -> new ArrayList<>()).add(l);
            }
            String[] orden = {"latinoamericana","clasicos","ciencia","tecnologia","historia","fantasia","biografias","desarrollo","manga"};
            String[] nombres = {"Literatura Latinoamericana","Clásicos Mundiales","Ciencia Ficción y Distopía","Tecnología e Ingeniería","Historia y Filosofía","Fantasía y Épica","Biografías","Desarrollo Personal","Manga"};
            String[] iconos  = {"fa-leaf","fa-feather","fa-rocket","fa-microchip","fa-landmark","fa-dragon","fa-user-tie","fa-seedling","fa-torii-gate"};

            for (int i = 0; i < orden.length; i++) {
                List<Libro> grupo = grupos.get(orden[i]);
                if (grupo == null || grupo.isEmpty()) continue;
        %>
            <section class="categoria-bloque" id="cat-<%= orden[i] %>">
                <h3><i class="fas <%= iconos[i] %>"></i> <%= nombres[i] %></h3>
                <div class="catalogo">
                    <% for (Libro l : grupo) { %>
                        <%= LibroRenderer.render(l, urlActual) %>
                    <% } %>
                </div>
            </section>
        <%  }
        } else { %>
            <%-- Categoría única: render plano --%>
            <section class="categoria-bloque">
                <div class="catalogo">
                    <% for (Libro l : libros) { %>
                        <%= LibroRenderer.render(l, urlActual) %>
                    <% } %>
                </div>
            </section>
        <% } %>
    <% } %>

</main>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
