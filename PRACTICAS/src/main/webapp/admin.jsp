<%--
    admin.jsp
    Dashboard de Administración - FOLIO
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario" %>
<%
    // SEGURIDAD: Solo ADMIN puede entrar aquí
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
    if (usrActivo == null || !"ADMIN".equalsIgnoreCase(usrActivo.getRol())) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin | FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=14">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        /* Ajustes estructurales sobre los estilos globales */
        body { display: flex; flex-direction: column; min-height: 100vh; }
        .dashboard-container { display: flex; flex: 1; max-width: 1400px; margin: 0 auto; width: 100%; padding: 2rem 1rem; gap: 2rem; align-items: flex-start; }

        /* Sidebar */
        .sidebar { width: 280px; background: var(--color-blanco); border-radius: var(--radio); box-shadow: var(--sombra-suave); padding: 1.5rem; border: 1px solid var(--color-borde); position: sticky; top: 90px; transition: var(--transicion); }
        .sidebar h3 { color: var(--color-titulos); margin-bottom: 1.5rem; font-size: 1.2rem; display: flex; align-items: center; gap: 0.5rem; padding-bottom: 1rem; border-bottom: 1px solid var(--color-borde); }
        .sidebar ul { list-style: none; display: flex; flex-direction: column; gap: 0.5rem; }
        .sidebar ul li a { display: flex; align-items: center; gap: 0.8rem; padding: 0.8rem 1rem; color: var(--color-texto); text-decoration: none; border-radius: var(--radio); transition: var(--transicion); font-weight: 500; cursor: pointer; }
        .sidebar ul li a:hover, .sidebar ul li a.activo { background-color: rgba(201, 169, 110, 0.15); color: var(--color-acento); }

        /* Contenido y Secciones */
        .main-content { flex: 1; display: flex; flex-direction: column; width: 100%; overflow: hidden; }
        .admin-section { display: none; animation: aparecer 0.4s ease; flex-direction: column; gap: 2rem; }
        .admin-section.active { display: flex; }

        /* Tarjetas KPI */
        .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.5rem; }
        .kpi-card { background: var(--color-blanco); padding: 1.5rem; border-radius: var(--radio); box-shadow: var(--sombra-suave); border-left: 4px solid var(--color-acento); display: flex; flex-direction: column; gap: 0.5rem; transition: var(--transicion); border-top: 1px solid var(--color-borde); border-right: 1px solid var(--color-borde); border-bottom: 1px solid var(--color-borde); }
        .kpi-card:hover { transform: translateY(-3px); box-shadow: var(--sombra-media); }
        .kpi-card span { color: var(--color-texto-suave); font-size: 0.85rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
        .kpi-card h2 { color: var(--color-titulos); font-size: 2.2rem; margin: 0; font-family: var(--fuente-titulo); }

        /* Paneles / Tablas */
        .admin-panel { background: var(--color-blanco); padding: 2rem; border-radius: var(--radio); box-shadow: var(--sombra-suave); border: 1px solid var(--color-borde); transition: var(--transicion); overflow-x: auto; }
        .admin-panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
        .admin-panel-header h3 { margin: 0; color: var(--color-titulos); font-size: 1.25rem; }

        table { width: 100%; border-collapse: collapse; min-width: 600px; }
        th, td { padding: 1rem; text-align: left; border-bottom: 1px solid var(--color-borde); }
        th { background-color: var(--color-fondo); color: var(--color-texto-suave); font-weight: 600; text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
        td { color: var(--color-texto); font-size: 0.95rem; }

        .badge { padding: 4px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: bold; letter-spacing: 0.05em; display: inline-block; }
        .badge-cliente { background: rgba(46, 160, 67, 0.1); color: #2ea043; border: 1px solid rgba(46, 160, 67, 0.2); }
        .badge-empleado { background: rgba(23, 162, 184, 0.1); color: #17a2b8; border: 1px solid rgba(23, 162, 184, 0.2); }

        .btn-accion { padding: 0.5rem 0.9rem; border: none; border-radius: 4px; cursor: pointer; font-size: 0.85rem; font-weight: 600; transition: var(--transicion); display: inline-flex; align-items: center; gap: 0.4rem; }
        .btn-peligro { background-color: rgba(218, 54, 51, 0.1); color: #da3633; }
        .btn-peligro:hover { background-color: #da3633; color: white; transform: translateY(-2px); }
        .btn-primario { background-color: var(--color-acento); color: #1a1a2e; }
        .btn-primario:hover { background-color: var(--color-acento-hover); transform: translateY(-2px); }
    </style>
</head>
<body>

<header>
    <div class="header-container">
        <div class="logo">
            <i class="fas fa-book-open fa-2x" style="color:var(--color-acento);"></i>
            <div>
                <h1>FO<span>L</span>IO</h1>
                <span class="logo-subtitle" style="color:#ffc107;">Administración</span>
            </div>
        </div>
        <nav>
            <ul>
                <li><a href="index.jsp"><i class="fas fa-store"></i> Ver Tienda</a></li>
                <li class="dropdown">
                    <a href="javascript:void(0);" id="btn-perfil" style="color:#ffc107; font-weight:600;">
                        <i class="fas fa-user-shield"></i> <%= usrActivo.getNombre() %> <i class="fas fa-chevron-down" style="font-size:0.8em;"></i>
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
        <h3><i class="fas fa-crown" style="color:var(--color-acento);"></i> Panel Central</h3>
        <ul id="admin-nav">
            <li><a class="activo" onclick="cambiarSeccionAdmin('sec-dashboard', this)"><i class="fas fa-chart-line"></i> Dashboard General</a></li>
            <li><a onclick="cambiarSeccionAdmin('sec-usuarios', this)"><i class="fas fa-users"></i> Gestión de Usuarios</a></li>
            <li><a onclick="cambiarSeccionAdmin('sec-ventas', this)"><i class="fas fa-file-invoice-dollar"></i> Ventas y Reportes</a></li>
            <li><a onclick="cambiarSeccionAdmin('sec-config', this)"><i class="fas fa-cog"></i> Configuración</a></li>
        </ul>
    </aside>

    <main class="main-content">

        <div id="sec-dashboard" class="admin-section active">
            <div class="kpi-grid">
                <div class="kpi-card">
                    <span>Total Ventas Mes</span>
                    <h2>$ 1,245.50</h2>
                </div>
                <div class="kpi-card">
                    <span>Usuarios Registrados</span>
                    <h2>142</h2>
                </div>
                <div class="kpi-card">
                    <span>Libros Vendidos</span>
                    <h2>87</h2>
                </div>
            </div>

            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-shopping-bag"></i> Últimas Ventas</h3>
                    <button class="btn-accion btn-primario"><i class="fas fa-download"></i> Exportar Reporte</button>
                </div>
                <table>
                    <thead>
                    <tr>
                        <th>ID Pedido</th>
                        <th>Cliente</th>
                        <th>Fecha</th>
                        <th>Total</th>
                        <th>Estado</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td>#10045</td>
                        <td>María Elena R.</td>
                        <td>Hace 2 horas</td>
                        <td><strong style="color:var(--color-acento);">$ 34.40</strong></td>
                        <td><span class="badge badge-cliente" style="color:#fff; background:#2ea043;">Completado</span></td>
                    </tr>
                    <tr>
                        <td>#10044</td>
                        <td>Juan Carlos M.</td>
                        <td>Hace 5 horas</td>
                        <td><strong style="color:var(--color-acento);">$ 21.00</strong></td>
                        <td><span class="badge badge-cliente" style="color:#fff; background:#2ea043;">Completado</span></td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="sec-usuarios" class="admin-section">
            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-users-cog"></i> Directorio de Cuentas</h3>
                    <button class="btn-accion btn-primario"><i class="fas fa-plus"></i> Nuevo Empleado</button>
                </div>
                <table>
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nombre Completo</th>
                        <th>Correo</th>
                        <th>Rol</th>
                        <th>Acciones</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td>101</td>
                        <td>María Elena R.</td>
                        <td>maria@correo.com</td>
                        <td><span class="badge badge-cliente">CLIENTE</span></td>
                        <td>
                            <button class="btn-accion btn-peligro"><i class="fas fa-user-slash"></i> Suspender</button>
                        </td>
                    </tr>
                    <tr>
                        <td>102</td>
                        <td>Gestor Inventario</td>
                        <td>empleado@folio.com</td>
                        <td><span class="badge badge-empleado">EMPLEADO</span></td>
                        <td>
                            <button class="btn-accion btn-peligro"><i class="fas fa-user-slash"></i> Revocar</button>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="sec-ventas" class="admin-section">
            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-chart-bar"></i> Reporte Detallado</h3>
                </div>
                <div style="text-align:center; padding: 4rem 1rem; color:var(--color-texto-suave);">
                    <i class="fas fa-tools fa-3x" style="margin-bottom:1rem; opacity:0.3;"></i>
                    <p>Módulo de gráficas en construcción. Conectaremos con los datos de PostgreSQL pronto.</p>
                </div>
            </div>
        </div>

        <div id="sec-config" class="admin-section">
            <div class="admin-panel">
                <div class="admin-panel-header">
                    <h3><i class="fas fa-sliders-h"></i> Ajustes del Sistema</h3>
                </div>
                <div style="text-align:center; padding: 4rem 1rem; color:var(--color-texto-suave);">
                    <i class="fas fa-cogs fa-3x" style="margin-bottom:1rem; opacity:0.3;"></i>
                    <p>Aquí podrás gestionar variables globales, impuestos y correos del sistema.</p>
                </div>
            </div>
        </div>

    </main>

</div>

<script>
    // 1. SISTEMA DE MODO OSCURO (Integrado con el panel Admin)
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

    // 3. NAVEGACIÓN SPA DEL DASHBOARD (Cambiar de panel sin recargar)
    function cambiarSeccionAdmin(idSeccion, btnActual) {
        // Ocultar todas las secciones
        document.querySelectorAll('.admin-section').forEach(sec => {
            sec.classList.remove('active');
        });

        // Quitar la clase "activo" de todos los enlaces del menú
        document.querySelectorAll('#admin-nav a').forEach(enlace => {
            enlace.classList.remove('activo');
        });

        // Activar la sección elegida y pintar el botón correspondiente
        document.getElementById(idSeccion).classList.add('active');
        btnActual.classList.add('activo');

        // Scrollear arriba suavemente por si bajó mucho
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
</script>
</body>
</html>