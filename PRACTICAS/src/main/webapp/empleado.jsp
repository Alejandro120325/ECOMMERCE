<%--
    empleado.jsp
    Dashboard de Gestión de Inventario - FOLIO
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario" %>
<%
    // SEGURIDAD: Solo EMPLEADO o ADMIN pueden entrar aquí
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
    if (usrActivo == null || (!"EMPLEADO".equalsIgnoreCase(usrActivo.getRol()) && !"ADMIN".equalsIgnoreCase(usrActivo.getRol()))) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventario | FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=15">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        /* Estilos específicos para el Layout del Dashboard */
        body { display: flex; flex-direction: column; min-height: 100vh; }
        .dashboard-container { display: flex; flex: 1; max-width: 1400px; margin: 0 auto; width: 100%; padding: 2rem 1rem; gap: 2rem; align-items: flex-start; }

        /* Sidebar */
        .sidebar { width: 280px; background: var(--color-blanco); border-radius: var(--radio); box-shadow: var(--sombra-suave); padding: 1.5rem; border: 1px solid var(--color-borde); position: sticky; top: 90px; transition: var(--transicion); }
        .sidebar h3 { color: var(--color-titulos); margin-bottom: 1.5rem; font-size: 1.2rem; display: flex; align-items: center; gap: 0.5rem; padding-bottom: 1rem; border-bottom: 1px solid var(--color-borde); }
        .sidebar ul { list-style: none; display: flex; flex-direction: column; gap: 0.5rem; }
        .sidebar ul li a { display: flex; align-items: center; gap: 0.8rem; padding: 0.8rem 1rem; color: var(--color-texto); text-decoration: none; border-radius: var(--radio); transition: var(--transicion); font-weight: 500; cursor: pointer; }
        .sidebar ul li a:hover, .sidebar ul li a.activo { background-color: rgba(23, 162, 184, 0.15); color: #17a2b8; }

        /* Contenido Principal */
        .main-content { flex: 1; display: flex; flex-direction: column; width: 100%; overflow: hidden; }
        .empleado-section { display: none; animation: aparecer 0.4s ease; flex-direction: column; gap: 2rem; }
        .empleado-section.active { display: flex; }

        /* Paneles y Tablas */
        .admin-panel { background: var(--color-blanco); padding: 2rem; border-radius: var(--radio); box-shadow: var(--sombra-suave); border: 1px solid var(--color-borde); transition: var(--transicion); overflow-x: auto; }
        .admin-panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
        .admin-panel-header h3 { margin: 0; color: var(--color-titulos); font-size: 1.25rem; }

        table { width: 100%; border-collapse: collapse; min-width: 800px; }
        th, td { padding: 1rem; text-align: left; border-bottom: 1px solid var(--color-borde); vertical-align: middle; }
        th { background-color: var(--color-fondo); color: var(--color-texto-suave); font-weight: 600; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
        td { color: var(--color-texto); font-size: 0.95rem; }

        .img-miniatura { width: 40px; height: 60px; object-fit: cover; border-radius: 4px; box-shadow: var(--sombra-suave); }

        .btn-accion { padding: 0.5rem 0.9rem; border: none; border-radius: 4px; cursor: pointer; font-size: 0.85rem; font-weight: 600; transition: var(--transicion); display: inline-flex; align-items: center; gap: 0.4rem; }
        .btn-peligro { background-color: rgba(218, 54, 51, 0.1); color: #da3633; }
        .btn-peligro:hover { background-color: #da3633; color: white; transform: translateY(-2px); }
        .btn-primario { background-color: #17a2b8; color: #fff; }
        .btn-primario:hover { background-color: #138496; transform: translateY(-2px); }
        .btn-secundario-empleado { background-color: rgba(201, 169, 110, 0.2); color: var(--color-acento-hover); }
        .btn-secundario-empleado:hover { background-color: var(--color-acento); color: #fff; transform: translateY(-2px); }
    </style>
</head>
<body>

<header>
    <div class="header-container">
        <div class="logo">
            <i class="fas fa-book-open fa-2x" style="color:var(--color-acento);"></i>
            <div>
                <h1>FO<span>L</span>IO</h1>
                <span class="logo-subtitle" style="color:#17a2b8;">Gestión de Inventario</span>
            </div>
        </div>
        <nav>
            <ul>
                <li><a href="index.jsp"><i class="fas fa-store"></i> Ver Tienda</a></li>
                <li class="dropdown">
                    <a href="javascript:void(0);" id="btn-perfil" style="color:#17a2b8; font-weight:600;">
                        <i class="fas fa-user-tie"></i> <%= usrActivo.getNombre() %> <i class="fas fa-chevron-down" style="font-size:0.8em;"></i>
                    </a>
                    <ul class="dropdown-menu" id="menu-perfil">
                        <li><a href="LogoutServlet"><i class="fas fa-sign-out-alt" style="color:#da3633;"></i> Cerrar sesión</a></li>
                    </ul>
                </li>
                <li>
                    <button id="btn-tema" aria-label="Cambiar tema" style="background:transparent; border:none; color:var(--color-acento); font-size:1.2rem; cursor:pointer; padding: 0.5rem; transition: transform 0.3s;">
                        <i class="fas fa-moon" id="icono-tema"></i>
                    </button>
                </li>
            </ul>
        </nav>
    </div>
</header>

<div class="dashboard-container">

    <aside class="sidebar">
        <h3><i class="fas fa-boxes" style="color:#17a2b8;"></i> Módulo Empleado</h3>
        <ul id="empleado-nav">
            <li><a class="activo" onclick="cambiarSeccionEmpleado('sec-inventario', this)"><i class="fas fa-list"></i> Catálogo Actual</a></li>
            <li><a onclick="cambiarSeccionEmpleado('sec-agregar', this)"><i class="fas fa-plus-circle"></i> Nuevo Libro</a></li>
            <li><a onclick="cambiarSeccionEmpleado('sec-descuentos', this)"><i class="fas fa-tags"></i> Ofertas y Descuentos</a></li>
        </ul>
    </aside>

    <main class="main-content">

        <div id="sec-inventario" class="empleado-section active">
            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-book"></i> Libros en Base de Datos</h3>
                    <button class="btn-accion btn-primario" onclick="cambiarSeccionEmpleado('sec-agregar', document.querySelectorAll('#empleado-nav a')[1])"><i class="fas fa-plus"></i> Añadir Registro</button>
                </div>
                <table>
                    <thead>
                    <tr>
                        <th>Portada</th>
                        <th>Título</th>
                        <th>Autor</th>
                        <th>Stock</th>
                        <th>Precio</th>
                        <th>Acciones</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td><img src="https://covers.openlibrary.org/b/isbn/9780307474728-S.jpg" alt="Portada" class="img-miniatura"></td>
                        <td><strong>Cien años de soledad</strong><br><small style="color:var(--color-texto-suave);">Latinoamericana</small></td>
                        <td>Gabriel García Márquez</td>
                        <td>25</td>
                        <td><strong style="color:#17a2b8;">$ 18.90</strong></td>
                        <td style="display:flex; gap:0.5rem; align-items:center; height:100%;">
                            <button class="btn-accion btn-secundario-empleado"><i class="fas fa-edit"></i> Editar</button>
                            <button class="btn-accion btn-peligro"><i class="fas fa-trash"></i> Eliminar</button>
                        </td>
                    </tr>
                    <tr>
                        <td><img src="https://covers.openlibrary.org/b/isbn/9780451524935-S.jpg" alt="Portada" class="img-miniatura"></td>
                        <td><strong>1984</strong><br><small style="color:var(--color-texto-suave);">Ciencia Ficción</small></td>
                        <td>George Orwell</td>
                        <td>30</td>
                        <td><strong style="color:#17a2b8;">$ 16.00</strong></td>
                        <td style="display:flex; gap:0.5rem; align-items:center; height:100%;">
                            <button class="btn-accion btn-secundario-empleado"><i class="fas fa-edit"></i> Editar</button>
                            <button class="btn-accion btn-peligro"><i class="fas fa-trash"></i> Eliminar</button>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="sec-agregar" class="empleado-section">
            <div class="admin-panel" style="max-width: 800px; margin: 0 auto; width: 100%;">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-plus-circle"></i> Registrar Nuevo Libro</h3>
                </div>
                <form action="#" method="post" style="display:flex; flex-direction:column; gap:1.5rem;">

                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:1.5rem;">
                        <div class="form-grupo" style="margin:0;">
                            <label style="display:block; font-weight:600; margin-bottom:0.5rem; color:var(--color-texto);">Título del Libro</label>
                            <input type="text" name="titulo" required style="width:100%; padding:0.8rem; border:1px solid var(--color-borde); border-radius:var(--radio); background:var(--color-fondo); color:var(--color-texto);">
                        </div>
                        <div class="form-grupo" style="margin:0;">
                            <label style="display:block; font-weight:600; margin-bottom:0.5rem; color:var(--color-texto);">Autor</label>
                            <input type="text" name="autor" required style="width:100%; padding:0.8rem; border:1px solid var(--color-borde); border-radius:var(--radio); background:var(--color-fondo); color:var(--color-texto);">
                        </div>
                    </div>

                    <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:1.5rem;">
                        <div class="form-grupo" style="margin:0;">
                            <label style="display:block; font-weight:600; margin-bottom:0.5rem; color:var(--color-texto);">ISBN</label>
                            <input type="text" name="isbn" style="width:100%; padding:0.8rem; border:1px solid var(--color-borde); border-radius:var(--radio); background:var(--color-fondo); color:var(--color-texto);">
                        </div>
                        <div class="form-grupo" style="margin:0;">
                            <label style="display:block; font-weight:600; margin-bottom:0.5rem; color:var(--color-texto);">Precio ($)</label>
                            <input type="number" step="0.01" name="precio" required style="width:100%; padding:0.8rem; border:1px solid var(--color-borde); border-radius:var(--radio); background:var(--color-fondo); color:var(--color-texto);">
                        </div>
                        <div class="form-grupo" style="margin:0;">
                            <label style="display:block; font-weight:600; margin-bottom:0.5rem; color:var(--color-texto);">Stock Inicial</label>
                            <input type="number" name="stock" value="0" style="width:100%; padding:0.8rem; border:1px solid var(--color-borde); border-radius:var(--radio); background:var(--color-fondo); color:var(--color-texto);">
                        </div>
                    </div>

                    <div class="form-grupo" style="margin:0;">
                        <label style="display:block; font-weight:600; margin-bottom:0.5rem; color:var(--color-texto);">Categoría</label>
                        <select name="categoria" style="width:100%; padding:0.8rem; border:1px solid var(--color-borde); border-radius:var(--radio); background:var(--color-fondo); color:var(--color-texto);">
                            <option value="Latinoamericana">Literatura Latinoamericana</option>
                            <option value="Clásicos">Clásicos Mundiales</option>
                            <option value="Ciencia Ficción">Ciencia Ficción y Distopía</option>
                        </select>
                    </div>

                    <div class="form-grupo" style="margin:0;">
                        <label style="display:block; font-weight:600; margin-bottom:0.5rem; color:var(--color-texto);">URL de la Portada</label>
                        <input type="url" name="portadaUrl" placeholder="https://..." style="width:100%; padding:0.8rem; border:1px solid var(--color-borde); border-radius:var(--radio); background:var(--color-fondo); color:var(--color-texto);">
                    </div>

                    <div class="form-grupo" style="margin:0;">
                        <label style="display:block; font-weight:600; margin-bottom:0.5rem; color:var(--color-texto);">Descripción / Sinopsis</label>
                        <textarea name="descripcion" rows="4" style="width:100%; padding:0.8rem; border:1px solid var(--color-borde); border-radius:var(--radio); background:var(--color-fondo); color:var(--color-texto); resize:vertical;"></textarea>
                    </div>

                    <button type="submit" class="btn-accion btn-primario" style="justify-content:center; padding: 1rem; font-size:1rem;"><i class="fas fa-save"></i> Guardar en Inventario</button>
                </form>
            </div>
        </div>

        <div id="sec-descuentos" class="empleado-section">
            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-tags"></i> Gestionar Promociones</h3>
                </div>
                <div style="text-align:center; padding: 4rem 1rem; color:var(--color-texto-suave);">
                    <i class="fas fa-percent fa-3x" style="margin-bottom:1rem; opacity:0.3;"></i>
                    <p>Aquí se implementará la lógica para aplicar descuentos por categorías o a libros específicos.</p>
                </div>
            </div>
        </div>

    </main>

</div>

<script>
    // 1. SISTEMA DE MODO OSCURO
    const btnTema = document.getElementById('btn-tema');
    const iconoTema = document.getElementById('icono-tema');
    const temaActual = localStorage.getItem('folio-tema');

    if (temaActual === 'dark') {
        document.body.setAttribute('data-theme', 'dark');
        iconoTema.classList.replace('fa-moon', 'fa-sun');
    }

    if (btnTema) {
        btnTema.addEventListener('click', () => {
            btnTema.style.transform = "rotate(360deg)";
            setTimeout(() => btnTema.style.transform = "rotate(0deg)", 300);

            if (document.body.getAttribute('data-theme') === 'dark') {
                document.body.removeAttribute('data-theme');
                localStorage.setItem('folio-tema', 'light');
                iconoTema.classList.replace('fa-sun', 'fa-moon');
            } else {
                document.body.setAttribute('data-theme', 'dark');
                localStorage.setItem('folio-tema', 'dark');
                iconoTema.classList.replace('fa-moon', 'fa-sun');
            }
        });
    }

    // 2. CONTROL DEL MENÚ DESPLEGABLE DEL PERFIL
    const btnPerfil = document.getElementById('btn-perfil');
    const menuPerfil = document.getElementById('menu-perfil');
    if (btnPerfil && menuPerfil) {
        btnPerfil.addEventListener('click', function(e) {
            e.stopPropagation();
            menuPerfil.classList.toggle('activo');
        });
    }
    document.addEventListener('click', function(e) {
        if (menuPerfil && !menuPerfil.contains(e.target) && e.target !== btnPerfil) {
            menuPerfil.classList.remove('activo');
        }
    });

    // 3. NAVEGACIÓN SPA DEL DASHBOARD EMPLEADO (Cambiar de panel sin recargar)
    function cambiarSeccionEmpleado(idSeccion, btnActual) {
        document.querySelectorAll('.empleado-section').forEach(sec => {
            sec.classList.remove('active');
        });
        document.querySelectorAll('#empleado-nav a').forEach(enlace => {
            enlace.classList.remove('activo');
        });

        document.getElementById(idSeccion).classList.add('active');
        btnActual.classList.add('activo');
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
</script>
</body>
</html>