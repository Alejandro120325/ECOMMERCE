<%-- registro.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario, ec.edu.ups.modelo.Carrito,
                 ec.edu.ups.controlador.CarritoServlet" %>
<%
    Usuario usrActivo     = (Usuario) session.getAttribute("usuarioActivo");
    Carrito carrito       = CarritoServlet.obtenerCarrito(request);
    boolean mostrarDrawer = false;
    String  urlActual     = "registro.jsp";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de cliente &middot; FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=110">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">

<%@ include file="WEB-INF/jspf/header.jspf" %>

<main class="form-wrapper">
    <div class="form-container" style="max-width: 640px;">
        <h2><i class="fas fa-user-plus" style="color:var(--color-acento);"></i> Crear cuenta nueva</h2>
        <p class="subtitulo">Únete a FOLIO y descubre tu próxima gran lectura.</p>

        <% String error = request.getParameter("error");
           if (error != null) { %>
        <div class="mensaje error">
            <i class="fas fa-exclamation-triangle"></i> <%= error %>
        </div>
        <% } %>

        <form action="RegistroServlet" method="post" enctype="multipart/form-data" autocomplete="on">

            <h3 class="form-seccion-titulo"><i class="fas fa-id-card"></i> Datos personales</h3>

            <div class="form-grupo">
                <label for="nombre">Nombres completos</label>
                <input type="text" id="nombre" name="nombre" placeholder="Ej. Alejandro Andrés"
                       required minlength="3" pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+">
            </div>

            <div class="form-grupo">
                <label for="apellido">Apellidos completos</label>
                <input type="text" id="apellido" name="apellido" placeholder="Ej. Ojeda Pérez"
                       required minlength="3" pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+">
            </div>

            <div class="form-grupo">
                <label for="cedula">Cédula <span style="color:var(--color-acento);">(Ecuador)</span></label>
                <input type="text" id="cedula" name="cedula" placeholder="1102345678"
                       required pattern="[0-9]{10}" maxlength="10" inputmode="numeric">
                <small>10 dígitos. La validez se verifica en el servidor.</small>
            </div>

            <div class="form-grupo">
                <label for="fechaNacimiento">Fecha de nacimiento</label>
                <input type="date" id="fechaNacimiento" name="fechaNacimiento" required max="2010-12-31">
            </div>

            <div class="form-grupo">
                <label>Estado civil</label>
                <div class="form-radios">
                    <label><input type="radio" name="estadoCivil" value="Soltero" required> Soltero</label>
                    <label><input type="radio" name="estadoCivil" value="Casado"> Casado</label>
                    <label><input type="radio" name="estadoCivil" value="Divorciado"> Divorciado</label>
                    <label><input type="radio" name="estadoCivil" value="Viudo"> Viudo</label>
                </div>
            </div>

            <div class="form-grupo">
                <label>Género</label>
                <div class="form-radios">
                    <label><input type="radio" name="genero" value="M" required> Masculino</label>
                    <label><input type="radio" name="genero" value="F"> Femenino</label>
                    <label><input type="radio" name="genero" value="O"> Otro</label>
                </div>
            </div>

            <div class="form-grupo">
                <label for="provincia">Lugar de residencia (Provincia)</label>
                <select id="provincia" name="provincia" required>
                    <option value="">-- Selecciona una provincia --</option>
                    <option value="Azuay">Azuay</option>
                    <option value="Bolivar">Bolívar</option>
                    <option value="Canar">Cañar</option>
                    <option value="Carchi">Carchi</option>
                    <option value="Chimborazo">Chimborazo</option>
                    <option value="Cotopaxi">Cotopaxi</option>
                    <option value="El Oro">El Oro</option>
                    <option value="Esmeraldas">Esmeraldas</option>
                    <option value="Galapagos">Galápagos</option>
                    <option value="Guayas">Guayas</option>
                    <option value="Imbabura">Imbabura</option>
                    <option value="Loja">Loja</option>
                    <option value="Los Rios">Los Ríos</option>
                    <option value="Manabi">Manabí</option>
                    <option value="Morona Santiago">Morona Santiago</option>
                    <option value="Napo">Napo</option>
                    <option value="Orellana">Orellana</option>
                    <option value="Pastaza">Pastaza</option>
                    <option value="Pichincha">Pichincha</option>
                    <option value="Santa Elena">Santa Elena</option>
                    <option value="Santo Domingo">Santo Domingo de los Tsáchilas</option>
                    <option value="Sucumbios">Sucumbíos</option>
                    <option value="Tungurahua">Tungurahua</option>
                    <option value="Zamora Chinchipe">Zamora Chinchipe</option>
                </select>
            </div>

            <div class="form-grupo">
                <label for="ciudad">Ciudad</label>
                <input type="text" id="ciudad" name="ciudad" placeholder="Ej. Quito" required>
            </div>

            <div class="form-grupo">
                <label for="direccion">Dirección domiciliaria</label>
                <textarea id="direccion" name="direccion" rows="2" placeholder="Calle principal y secundaria..."></textarea>
            </div>

            <div class="form-grupo">
                <label for="telefono">Teléfono <span style="color:var(--color-acento);">(Ecuador)</span></label>
                <input type="tel" id="telefono" name="telefono"
                       pattern="(09[0-9]{8})|(0[2-7][0-9]{7})"
                       placeholder="0991234567"
                       required maxlength="10" inputmode="numeric">
                <small>Móvil: 10 dígitos iniciando en 09 &middot; Fijo: 9 dígitos iniciando en 02–07.</small>
            </div>

            <h3 class="form-seccion-titulo"><i class="fas fa-key"></i> Credenciales de acceso</h3>

            <div class="form-grupo">
                <label for="correo">Correo electrónico</label>
                <input type="email" id="correo" name="correo" placeholder="usuario@correo.com" required>
            </div>

            <div class="form-grupo">
                <label for="clave">Clave</label>
                <%-- Ojo CSS-only sobre el campo de contraseña --%>
                <div class="campo-clave">
                    <input type="checkbox" id="ver-clave-1" class="ojo-toggle" tabindex="-1" aria-hidden="true">
                    <input type="text" id="clave" name="clave" class="input-password"
                           required minlength="8" pattern="(?=.*[A-Z])(?=.*[0-9]).{8,}"
                           autocomplete="new-password" spellcheck="false">
                    <label for="ver-clave-1" class="ojo" aria-label="Mostrar u ocultar contraseña" title="Mostrar / ocultar contraseña">
                        <i class="fas fa-eye       icono-mostrar"></i>
                        <i class="fas fa-eye-slash icono-ocultar"></i>
                    </label>
                </div>
                <small>Mínimo 8 caracteres, con al menos una mayúscula y un número.</small>
            </div>

            <div class="form-grupo">
                <label for="claveConfirm">Confirmar clave</label>
                <div class="campo-clave">
                    <input type="checkbox" id="ver-clave-2" class="ojo-toggle" tabindex="-1" aria-hidden="true">
                    <input type="text" id="claveConfirm" name="claveConfirm" class="input-password"
                           required minlength="8" autocomplete="new-password" spellcheck="false">
                    <label for="ver-clave-2" class="ojo" aria-label="Mostrar u ocultar contraseña" title="Mostrar / ocultar contraseña">
                        <i class="fas fa-eye       icono-mostrar"></i>
                        <i class="fas fa-eye-slash icono-ocultar"></i>
                    </label>
                </div>
            </div>

            <h3 class="form-seccion-titulo"><i class="fas fa-camera"></i> Foto de perfil</h3>

            <div class="form-grupo">
                <label for="foto">Sube tu foto de perfil</label>
                <input type="file" id="foto" name="foto" accept="image/png, image/jpeg, image/jpg">
            </div>

            <div class="form-grupo">
                <label style="font-weight:400;cursor:pointer;">
                    <input type="checkbox" name="terminos" value="aceptados" required> Acepto los términos y condiciones.
                </label>
            </div>

            <button type="submit" class="btn"><i class="fas fa-user-check"></i> Crear mi cuenta</button>
            <a href="index.jsp" class="btn btn-secundario" style="text-align:center;text-decoration:none;display:block;margin-top:0.6rem;">
                <i class="fas fa-arrow-left"></i> Cancelar
            </a>
        </form>
    </div>
</main>

<%@ include file="WEB-INF/jspf/carrito-drawer.jspf" %>
<%@ include file="WEB-INF/jspf/footer.jspf" %>

</body>
</html>
