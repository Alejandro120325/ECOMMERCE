<%--
    registro.jsp
    Formulario de registro de clientes - FOLIO
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="ec.edu.ups.modelo.Usuario" %>
<%
    Usuario usrActivo = (Usuario) session.getAttribute("usuarioActivo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de cliente | FOLIO</title>
    <link rel="stylesheet" href="css/estilos.css?v=15">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script defer src="js/carrito.js?v=10"></script>
</head>
<body>

<header>
    <div class="header-container">
        <div class="logo">
            <i class="fas fa-book-open fa-2x" style="color:var(--color-acento);"></i>
            <div>
                <h1>FO<span>L</span>IO</h1>
                <span class="logo-subtitle">Biblioteca Digital</span>
            </div>
        </div>
        <nav>
            <ul>
                <li><a href="index.jsp"><i class="fas fa-home"></i> Home</a></li>

                <%-- LÓGICA DE MENÚ DINÁMICO CON DROPDOWN --%>
                <% if (usrActivo != null) { %>
                <li class="dropdown">
                    <a href="javascript:void(0);" id="btn-perfil" style="color:var(--color-acento); font-weight:600; padding: 0.6rem 1.1rem; display:inline-block;">
                        <i class="fas fa-user-circle"></i> <%= usrActivo.getNombre() %> <i class="fas fa-chevron-down" style="font-size:0.8em;"></i>
                    </a>
                    <ul class="dropdown-menu" id="menu-perfil">
                        <% if ("ADMIN".equalsIgnoreCase(usrActivo.getRol())) { %>
                        <li><a href="admin.jsp"><i class="fas fa-crown" style="color:#ffc107;"></i> Dashboard Admin</a></li>
                        <% } else if ("EMPLEADO".equalsIgnoreCase(usrActivo.getRol())) { %>
                        <li><a href="empleado.jsp"><i class="fas fa-boxes" style="color:#17a2b8;"></i> Inventario</a></li>
                        <% } %>
                        <li><a href="LogoutServlet"><i class="fas fa-sign-out-alt" style="color:#da3633;"></i> Cerrar sesión</a></li>
                    </ul>
                </li>
                <% } else { %>
                <li><a href="login.jsp" class="btn-nav"><i class="fas fa-sign-in-alt"></i> Iniciar sesión</a></li>
                <% } %>

                <li>
                    <button id="btn-carrito" class="btn-carrito" aria-label="Abrir carrito">
                        <i class="fas fa-shopping-basket"></i>
                        <span class="carrito-badge">0</span>
                    </button>
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

<main class="form-wrapper">

    <div class="form-container" style="max-width: 640px;">
        <h2><i class="fas fa-user-plus" style="color:var(--color-acento);"></i> Crear cuenta nueva</h2>
        <p class="subtitulo">Únete a FOLIO y descubre tu próxima gran lectura.</p>

        <form action="RegistroServlet" method="post" enctype="multipart/form-data" autocomplete="on" onsubmit="return validarFormulario();">

            <h3 style="font-size:1rem;color:var(--color-titulos);margin-bottom:1rem;border-bottom:2px solid var(--color-acento);padding-bottom:0.4rem;">
                <i class="fas fa-id-card"></i> Datos personales
            </h3>

            <div class="form-grupo">
                <label for="nombre">Nombres completos</label>
                <input type="text" id="nombre" name="nombre" placeholder="Ej. Alejandro Andrés" required minlength="3" pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+">
            </div>

            <div class="form-grupo">
                <label for="apellido">Apellidos completos</label>
                <input type="text" id="apellido" name="apellido" placeholder="Ej. Ojeda Pérez" required minlength="3" pattern="[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+">
            </div>

            <div class="form-grupo">
                <label for="cedula">Cédula <span style="color:var(--color-acento);">(Ecuador)</span></label>
                <input type="text" id="cedula" name="cedula" placeholder="1102345678" required pattern="[0-9]{10}" maxlength="10">
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
                       required maxlength="10">
                <small>Móvil: 10 dígitos iniciando en 09 · Fijo: 9 dígitos iniciando en 02–07.</small>
            </div>

            <h3 style="font-size:1rem;color:var(--color-titulos);margin:1.5rem 0 1rem;border-bottom:2px solid var(--color-acento);padding-bottom:0.4rem;">
                <i class="fas fa-key"></i> Credenciales de acceso
            </h3>

            <div class="form-grupo">
                <label for="correo">Correo electrónico</label>
                <input type="email" id="correo" name="correo" placeholder="usuario@correo.com" required>
            </div>

            <div class="form-grupo">
                <label for="clave">Clave</label>
                <div style="position: relative; display: block; width: 100%;">
                    <input type="password" id="clave" name="clave" required minlength="8" pattern="(?=.*[A-Z])(?=.*[0-9]).{8,}" style="width: 100%; padding-right: 2.5rem;">
                    <button type="button" onclick="toggleVisibilidad('clave', this)" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: transparent; border: none; cursor: pointer; font-size: 1.1rem; color: var(--color-texto-suave); padding: 0; display: flex; align-items: center; justify-content: center; height: 100%;">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
                <small>Mínimo 8 caracteres, con al menos una mayúscula y un número.</small>
            </div>

            <div class="form-grupo">
                <label for="claveConfirm">Confirmar clave</label>
                <div style="position: relative; display: block; width: 100%;">
                    <input type="password" id="claveConfirm" name="claveConfirm" required minlength="8" style="width: 100%; padding-right: 2.5rem;">
                    <button type="button" onclick="toggleVisibilidad('claveConfirm', this)" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: transparent; border: none; cursor: pointer; font-size: 1.1rem; color: var(--color-texto-suave); padding: 0; display: flex; align-items: center; justify-content: center; height: 100%;">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>

            <h3 style="font-size:1rem;color:var(--color-titulos);margin:1.5rem 0 1rem;border-bottom:2px solid var(--color-acento);padding-bottom:0.4rem;">
                <i class="fas fa-camera"></i> Foto de perfil
            </h3>

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

<footer>
    <div class="footer-container">
        <p class="footer-copyright">© <%= java.time.Year.now() %> FOLIO Biblioteca Digital · Desarrollado por Jairo Alejandro Ojeda Herrera</p>
    </div>
</footer>

<script>
    const btnTema = document.getElementById('btn-tema');
    const iconoTema = document.getElementById('icono-tema');
    const temaActual = localStorage.getItem('folio-tema');
    if (temaActual === 'dark') {
        document.body.setAttribute('data-theme', 'dark');
        iconoTema.classList.replace('fa-moon', 'fa-sun');
    }
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

    function validarCedulaEcuatoriana(cedula) {
        if (!/^\d{10}$/.test(cedula)) return false;
        const provincia = parseInt(cedula.substring(0, 2), 10);
        if (provincia < 1 || provincia > 24) return false;
        const tercerDigito = parseInt(cedula.charAt(2), 10);
        if (tercerDigito > 5) return false;
        const coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
        let suma = 0;
        for (let i = 0; i < 9; i++) {
            let v = parseInt(cedula.charAt(i), 10) * coeficientes[i];
            if (v >= 10) v -= 9;
            suma += v;
        }
        const digitoVerificador = (10 - (suma % 10)) % 10;
        return digitoVerificador === parseInt(cedula.charAt(9), 10);
    }

    function validarTelefonoEcuador(tel) {
        if (!/^\d+$/.test(tel)) return false;
        // Móvil: 10 dígitos iniciando 09
        if (/^09\d{8}$/.test(tel)) return true;
        // Fijo: 9 dígitos iniciando 02-07 (códigos de provincia)
        if (/^0[2-7]\d{7}$/.test(tel)) return true;
        return false;
    }

    function validarEdadMinima(fechaStr, edadMin) {
        if (!fechaStr) return false;
        const hoy = new Date();
        const f = new Date(fechaStr);
        let edad = hoy.getFullYear() - f.getFullYear();
        const m = hoy.getMonth() - f.getMonth();
        if (m < 0 || (m === 0 && hoy.getDate() < f.getDate())) edad--;
        return edad >= edadMin;
    }

    function validarFormulario() {
        const cedula   = document.getElementById('cedula').value.trim();
        const telefono = document.getElementById('telefono').value.trim();
        const fecha    = document.getElementById('fechaNacimiento').value;
        const clave    = document.getElementById('clave').value;
        const claveC   = document.getElementById('claveConfirm').value;

        if (!validarCedulaEcuatoriana(cedula)) {
            alert('La cédula ingresada no es válida (algoritmo módulo 10 del Registro Civil).');
            document.getElementById('cedula').focus();
            return false;
        }
        if (!validarTelefonoEcuador(telefono)) {
            alert('Teléfono inválido.\n\nMóvil: 10 dígitos comenzando en 09 (ej. 0991234567)\nFijo: 9 dígitos comenzando en 02-07 (ej. 022345678)');
            document.getElementById('telefono').focus();
            return false;
        }
        if (!validarEdadMinima(fecha, 13)) {
            alert('Debes tener al menos 13 años para registrarte.');
            document.getElementById('fechaNacimiento').focus();
            return false;
        }
        if (!/(?=.*[A-Z])(?=.*[0-9]).{8,}/.test(clave)) {
            alert('La clave debe tener mínimo 8 caracteres, al menos una mayúscula y un número.');
            document.getElementById('clave').focus();
            return false;
        }
        if (clave !== claveC) {
            alert('Las claves no coinciden.');
            document.getElementById('claveConfirm').focus();
            return false;
        }
        return true;
    }

    // Solo permitir dígitos en cédula y teléfono
    ['cedula', 'telefono'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.addEventListener('input', () => {
            el.value = el.value.replace(/\D/g, '');
        });
    });

    // SCRIPT PARA EL OJITO
    function toggleVisibilidad(inputId, boton) {
        const input = document.getElementById(inputId);
        const icono = boton.querySelector('i');

        if (input.type === 'password') {
            input.type = 'text';
            icono.classList.remove('fa-eye');
            icono.classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            icono.classList.remove('fa-eye-slash');
            icono.classList.add('fa-eye');
        }
    }

    /* CONTROL DE MENÚS DESPLEGABLES */
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
</script>
</body>
</html>