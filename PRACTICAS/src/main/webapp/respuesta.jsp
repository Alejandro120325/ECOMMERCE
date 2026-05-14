<%--
    respuesta.jsp
    Muestra los datos capturados en el registro
    Recibe el Usuario desde el RegistroServlet vía request attribute
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario" %>
<%
    Usuario u = (Usuario) request.getAttribute("usuario");
    Boolean exito = (Boolean) request.getAttribute("exito");
    String mensaje = (String) request.getAttribute("mensaje");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro recibido | FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=5">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script defer src="js/carrito.js?v=2"></script>
</head>
<body>

    <!-- HEADER -->
    <header>
        <div class="header-container">
            <div class="logo">
                <i class="fas fa-book-open fa-2x" style="color:#c9a96e;"></i>
                <div>
                    <h1>FO<span>L</span>IO</h1>
                    <span class="logo-subtitle">Biblioteca Digital</span>
                </div>
            </div>
            <nav>
                <ul>
                    <li><a href="index.jsp"><i class="fas fa-home"></i> Home</a></li>
                    <li><a href="login.jsp" class="btn-nav"><i class="fas fa-sign-in-alt"></i> Iniciar sesión</a></li>
                    <li>
                        <button id="btn-carrito" class="btn-carrito" aria-label="Abrir carrito">
                            <i class="fas fa-shopping-basket"></i>
                            <span class="carrito-badge">0</span>
                        </button>
                    </li>
                </ul>
            </nav>
        </div>
    </header>

    <main class="form-wrapper">

        <div class="form-container" style="max-width: 720px;">

            <% if (exito != null && exito) { %>
                <div class="mensaje exito">
                    <i class="fas fa-check-circle"></i>
                    <strong>¡Registro exitoso!</strong> Tus datos han sido guardados en la base de datos de FOLIO.
                </div>
            <% } else if (mensaje != null) { %>
                <div class="mensaje error">
                    <i class="fas fa-exclamation-triangle"></i>
                    <%= mensaje %>
                </div>
            <% } %>

            <h2><i class="fas fa-clipboard-check" style="color:#c9a96e;"></i> Resumen de tu registro</h2>
            <p class="subtitulo">A continuación se muestran los datos capturados.</p>

            <% if (u != null) { %>
                <table class="tabla-respuesta">
                    <tr>
                        <th>Nombres</th>
                        <td><%= u.getNombre() %></td>
                    </tr>
                    <tr>
                        <th>Apellidos</th>
                        <td><%= u.getApellido() %></td>
                    </tr>
                    <tr>
                        <th>Cédula</th>
                        <td><%= u.getCedula() %></td>
                    </tr>
                    <tr>
                        <th>Fecha de nacimiento</th>
                        <td><%= u.getFechaNacimiento() %></td>
                    </tr>
                    <tr>
                        <th>Género</th>
                        <td><%= u.getGenero() %></td>
                    </tr>
                    <tr>
                        <th>Estado civil</th>
                        <td><%= u.getEstadoCivil() %></td>
                    </tr>
                    <tr>
                        <th>Provincia</th>
                        <td><%= u.getProvincia() %></td>
                    </tr>
                    <tr>
                        <th>Ciudad</th>
                        <td><%= u.getCiudad() %></td>
                    </tr>
                    <tr>
                        <th>Dirección</th>
                        <td><%= (u.getDireccion()==null?"-":u.getDireccion()) %></td>
                    </tr>
                    <tr>
                        <th>Teléfono</th>
                        <td><%= u.getTelefono() %></td>
                    </tr>
                    <tr>
                        <th>Correo</th>
                        <td><%= u.getCorreo() %></td>
                    </tr>
                    <tr>
                        <th>Clave</th>
                        <td>**********</td>
                    </tr>
                    <tr>
                        <th>Foto de perfil</th>
                        <td>
                            <% if (u.getFotoPerfil() != null && !u.getFotoPerfil().isEmpty()) { %>
                                <img src="uploads/<%= u.getFotoPerfil() %>"
                                     alt="Foto"
                                     style="max-width:120px;border-radius:8px;border:2px solid #c9a96e;">
                            <% } else { %>
                                <em>No se cargó imagen</em>
                            <% } %>
                        </td>
                    </tr>
                </table>
            <% } else { %>
                <div class="mensaje error">No se recibieron datos del registro.</div>
            <% } %>

            <div style="display:flex;gap:0.8rem;margin-top:1.5rem;flex-wrap:wrap;">
                <a href="login.jsp" class="btn" style="text-decoration:none;text-align:center;flex:1;min-width:180px;">
                    <i class="fas fa-sign-in-alt"></i> Iniciar sesión
                </a>
                <a href="index.jsp" class="btn btn-secundario" style="text-decoration:none;text-align:center;flex:1;min-width:180px;">
                    <i class="fas fa-home"></i> Volver al inicio
                </a>
            </div>
        </div>
    </main>

    <footer>
        <div class="footer-container">
            <p class="footer-copyright">
                &copy; <%= java.time.Year.now() %> FOLIO Biblioteca Digital · Desarrollado por Alejandro Ojeda
            </p>
        </div>
    </footer>

    <% if (exito != null && exito && u != null && u.getCorreo() != null) { %>
    <script>
        // Migrar el carrito anónimo a la cuenta recién registrada
        window.addEventListener('DOMContentLoaded', () => {
            if (window.FolioCarrito) {
                window.FolioCarrito.setUser(<%= "\"" + u.getCorreo().replace("\"", "\\\"").toLowerCase() + "\"" %>);
            }
        });
    </script>
    <% } %>
</body>
</html>
