# 📚 FOLIO — Biblioteca Digital Premium

> E-commerce literario de alta gama desarrollado bajo arquitectura
> **Server-Side Rendering estricta**. **Cero JavaScript en el cliente** —
> todo el comportamiento, lógica y validación se procesa en el servidor
> mediante Servlets, `HttpSession` y recargas HTTP tradicionales.
> Estética **Gold & Dark** con conmutador a un modo claro corporativo,
> tarjetas 3D de libros en CSS3 puro y pasarela de pago localizada para
> Ecuador.

![Java](https://img.shields.io/badge/Java-24-orange?logo=openjdk)
![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10-blueviolet)
![Tomcat](https://img.shields.io/badge/Tomcat-10.1%2B-yellow?logo=apachetomcat)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15%2B-336791?logo=postgresql)
![Maven](https://img.shields.io/badge/Maven-3.9%2B-red?logo=apachemaven)
![JSTL](https://img.shields.io/badge/JSTL-3.0-success)
![Zero JS](https://img.shields.io/badge/JavaScript-CERO-red)
![Encoding](https://img.shields.io/badge/UTF--8-Infalible-blue)
![License](https://img.shields.io/badge/license-Academic-success)

---

## 🧭 Tabla de contenido

1. [Descripción ejecutiva](#-descripción-ejecutiva)
2. [Arquitectura MVC Server-Side](#%EF%B8%8F-arquitectura-mvc-server-side)
3. [Codificación UTF-8 infalible](#-codificación-utf-8-infalible)
4. [Sistema de sesiones por rol](#-sistema-de-sesiones-por-rol)
5. [Pasarela de pago Ecuador](#-pasarela-de-pago-ecuador)
6. [Catálogo (90 libros · 9 categorías)](#-catálogo-90-libros--9-categorías)
7. [Modelo de datos PostgreSQL](#-modelo-de-datos-postgresql)
8. [Estructura del repositorio](#-estructura-del-repositorio)
9. [Funcionalidades por pantalla](#-funcionalidades-por-pantalla)
10. [UI/UX premium (Gold & Dark)](#-uiux-premium-gold--dark)
11. [Stack técnico](#-stack-técnico)
12. [Instalación paso a paso](#%EF%B8%8F-instalación-paso-a-paso)
13. [Credenciales maestras de prueba](#-credenciales-maestras-de-prueba)
14. [Convenciones de código](#-convenciones-de-código)
15. [Créditos académicos](#-créditos-académicos)

---

## 💡 Descripción ejecutiva

**FOLIO** es una librería online de literatura curada que opera con un
catálogo de **90 títulos reales** distribuidos en **9 categorías**
(Latinoamericana, Clásicos, Ciencia Ficción, Tecnología, Historia y
Filosofía, Fantasía, Biografías, Desarrollo Personal y **Manga**).

Filosofía técnica del proyecto:

- **Cero JavaScript en el cliente.** Sin `<script>`, sin `onclick`,
  sin `fetch`/AJAX. Toda interacción se modela como un `<form>` POST,
  un `<a href>` HTTP o un `<details>` HTML5 nativo.
- **Server-Side Rendering estricto.** Cada vista JSP recibe los datos
  desde un Servlet controlador; el modelo (`Libro`, `Carrito`, `Pedido`,
  `Usuario`) vive en la `HttpSession` y se sirve precompuesto al
  navegador.
- **Patrón MVC limpio.** Servlets controlan, DAOs hablan SQL, JSPs
  pintan. Ninguna capa cruza su responsabilidad.
- **POO sólida.** Modelos serializables, encapsulamiento total,
  validación de invariantes en setters (`ItemCarrito.cantidad >= 1`,
  `Carrito.disminuir()` con borrado en cascada, etc.).
- **Diseño Gold & Dark inmersivo** con glassmorphism, scrollbar dorado
  personalizado, libros 3D rotando 360° en hover con `transform-style:
  preserve-3d` (sin Three.js, CSS3 puro) y conmutador de tema
  server-side.

---

## 🏛️ Arquitectura MVC Server-Side

```
┌──────────────────────────────────────────────────────────────────────┐
│                            NAVEGADOR                                  │
│   HTML + CSS3 puro · 3D books · Glassmorphism · Drawer carrito        │
│                            ▲     │                                    │
│   sendRedirect + Set-Cookie│     │POST <form>  /  GET <a href>        │
└────────────────────────────┼─────┼────────────────────────────────────┘
                             │     ▼
┌────────────────────────────┴──────────────────────────────────────────┐
│   APACHE TOMCAT 10.1 + JAKARTA EE 10  (jakarta.servlet 6.0)           │
│                                                                       │
│   ┌────────────── FILTROS ──────────────────────────────────────────┐ │
│   │  · CharacterEncodingFilter   → fuerza UTF-8 en req y res        │ │
│   └────────────────────────────────────────────────────────────────-┘ │
│                                                                       │
│   ┌────────────── CONTROLADORES (Servlets) ─────────────────────────┐ │
│   │  Autenticación      LoginServlet · LogoutServlet · RegistroServlet
│   │  Compras            CarritoServlet · ProcesarPagoServlet         │
│   │  Catálogo           FiltrarLibrosServlet                         │
│   │  Admin              GestionUsuariosServlet                       │
│   │  Empleado           LibroAdminServlet · AplicarDescuentoServlet  │
│   │  Tema               SetThemeServlet                              │
│   └─────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│   ┌────────────── MODELO (POO + sesión) ────────────────────────────┐ │
│   │  Usuario · Libro · Carrito · ItemCarrito                        │ │
│   │  Pedido  · ItemPedido      · CatalogoLibros (fallback memoria)  │ │
│   │  Carrito vive en HttpSession; encapsula IVA 15% y total         │ │
│   └─────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│   ┌────────────── DAO (JDBC con Try-with-resources) ────────────────┐ │
│   │  Conexion · UsuarioDAO · LibroDAO · PedidoDAO · ClienteDAO      │ │
│   │  Defensivos: caen a fallback en memoria si PG no está disponible│ │
│   └─────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│   ┌────────────── VISTAS (JSP + JSPF + JSTL 3.0) ───────────────────┐ │
│   │  Home: index.jsp                                                │ │
│   │  Catálogo: catalogo.jsp (filtrado por slug de categoría)        │ │
│   │  Contacto: contacto.jsp                                         │ │
│   │  Carrito: WEB-INF/jspf/carrito-drawer.jspf                      │ │
│   │  Pago: pago.jsp + pago-exito.jsp                                │ │
│   │  Cliente: perfil.jsp                                            │ │
│   │  Empleado: empleado.jsp                                         │ │
│   │  Admin: admin.jsp (con JSTL <c:forEach>)                        │ │
│   │  Acceso: login.jsp · registro.jsp · respuesta.jsp               │ │
│   │  Helpers: LibroRenderer.java (HTML del libro 3D)                │ │
│   └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────┬─────────────────────────────────┘
                                      │ JDBC + UTF-8 cliente
                                      ▼
┌──────────────────────────────────────────────────────────────────────┐
│   POSTGRESQL 15+  ·  BD: folio_biblioteca                            │
│   tb_usuario · clientes · tb_libro · tb_pedido · tb_pedido_item      │
└──────────────────────────────────────────────────────────────────────┘
```

### Flujo Post-Redirect-Get (sin AJAX)

Cada acción del usuario sigue este ciclo:

```
[Cliente]  POST /CarritoServlet (accion=AGREGAR_LIBRO, libroId, redirect, carrito=open)
   │
   ▼
[Servlet]  Carrito.agregar(libro)            ← muta la HttpSession
   │
   ▼
[Servlet]  response.sendRedirect(redirect + "?carrito=open")
   │
   ▼
[Cliente]  GET /index.jsp?carrito=open       ← navegador recarga
   │
   ▼
[JSP]      carrito-drawer.jspf itera items y pinta total + IVA
```

---

## 🔤 Codificación UTF-8 infalible

Tres capas redundantes garantizan que ningún acento ni eñe se rompa:

### 1) Directiva en TODAS las JSP y JSPF
```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
```

> Sin `pageEncoding`, Tomcat lee la JSP del disco con la codificación de
> la plataforma (Windows-1252) y entrega "Catã¡logo" en lugar de
> "Catálogo". Es la causa #1 de texto roto en Java EE.

### 2) Filtro global en el backend
```java
@WebFilter(urlPatterns = {"/*"}, asyncSupported = true)
public class CharacterEncodingFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain ch)
            throws IOException, ServletException {
        if (req.getCharacterEncoding() == null) req.setCharacterEncoding("UTF-8");
        res.setCharacterEncoding("UTF-8");
        ch.doFilter(req, res);
    }
}
```

Aplica ANTES de cualquier `getParameter()`, de modo que los POST con
tildes y eñes llegan limpios al servlet.

### 3) Conexión JDBC explícita
```java
Properties props = new Properties();
props.setProperty("characterEncoding",    "UTF-8");
props.setProperty("client_encoding",      "UTF8");
props.setProperty("allowEncodingChanges", "true");
props.setProperty("useUnicode",           "true");
DriverManager.getConnection(URL, props);
```

Así las tildes viajan limpias en ambos sentidos Java ↔ PostgreSQL.

---

## 👥 Sistema de sesiones por rol

FOLIO maneja tres roles diferenciados + sesión de invitado:

| Rol | Página principal | Funciones que ve |
|-----|------------------|------------------|
| **Invitado** | `index.jsp` | Catálogo, carrito anónimo, registro/login |
| **CLIENTE** | `index.jsp` + `perfil.jsp` | Carrito persistente, checkout, historial de pedidos |
| **EMPLEADO** | `empleado.jsp` | CRUD de libros, descuentos por categoría/libro |
| **ADMIN** | `admin.jsp` | Gestión de usuarios + **hereda todas las funciones de EMPLEADO** |

### Herencia ADMIN → EMPLEADO

El administrador no necesita "cambiar de rol" para acceder a las
funciones de inventario. Su dropdown en el header muestra ambas
entradas, y la sidebar de `admin.jsp` incluye un grupo dedicado
"Módulo Empleado":

```jsp
<% if ("ADMIN".equalsIgnoreCase(usrActivo.getRol())) { %>
    <li><a href="admin.jsp"><i class="fas fa-crown"></i> Dashboard Admin</a></li>
    <li><a href="empleado.jsp"><i class="fas fa-boxes"></i> Inventario (CRUD)</a></li>
<% } else if ("EMPLEADO".equalsIgnoreCase(usrActivo.getRol())) { %>
    <li><a href="empleado.jsp"><i class="fas fa-boxes"></i> Inventario</a></li>
<% } else { %>
    <li><a href="perfil.jsp"><i class="fas fa-receipt"></i> Mi perfil & Pedidos</a></li>
<% } %>
```

Los Servlets de privilegio (`LibroAdminServlet`,
`AplicarDescuentoServlet`) aceptan tanto `EMPLEADO` como `ADMIN`.
`GestionUsuariosServlet` valida estrictamente `ADMIN`.

### Suspensión de cuentas
El admin puede:
- **Suspender** una cuenta (`activo = FALSE`)
- **Reactivar** una cuenta (`activo = TRUE`)
- **Eliminar** una cuenta (con guardia: no puede borrarse a sí mismo)

Las cuentas suspendidas mantienen su fila pero no pueden iniciar sesión.

### Conmutador de tema server-side

Botón ☀/🌙 en el header envía un POST a `SetThemeServlet`, que guarda
`tema = "light"|"dark"` en la sesión. Cada JSP lee con EL puro
`<body class="${empty sessionScope.tema ? 'dark' : sessionScope.tema}">`.

---

## 💳 Pasarela de pago Ecuador

**Tres métodos de pago localizados** dentro de `pago.jsp`, cada uno en
un `<details>` HTML5 (acordeón nativo sin JavaScript):

### a) Tarjeta de crédito / débito
- Marcas: **Visa, Mastercard, American Express, Discover, Diners**.
- Validación 100% server-side dentro de `ProcesarPagoServlet`:
  1. Detección de marca por BIN (regex sobre dígitos iniciales).
  2. Longitud válida por marca (Amex 15, Diners 14, Visa/MC 16, etc.).
  3. **Algoritmo de Luhn (módulo 10)** sobre todos los dígitos.
  4. Titular: mínimo nombre + apellido, sólo letras (incluyendo acentos).
  5. Fecha `MM/AA` no vencida (validada con `java.time.YearMonth`).
  6. CVV de 3 dígitos (4 para Amex).

### b) Transferencia bancaria
- Lista de **bancos ecuatorianos reales**: Banco Pichincha, Banco
  Guayaquil, Produbanco, Banco del Pacífico, Bolivariano, Internacional,
  Banco del Austro.
- Se le muestra al cliente un **número de cuenta determinista por
  sesión** (`"22" + hash(sessionId)`).
- Captura: banco, titular emisor, número de comprobante (6–20 dígitos).
- El servlet valida lista blanca de bancos + longitud del comprobante
  antes de persistir el pedido con marca `"TRANSFERENCIA PICHINCHA"`,
  etc.

### c) PayPal (simulado)
- Captura email PayPal.
- Validación regex de formato `usuario@dominio.com`.
- Persistido con marca `"PAYPAL"` y "últimos 4" = primeras 4 letras del
  dominio (`GMAI`, `OUTL`, etc.).

Todos los métodos terminan invocando `PedidoDAO.crearDesdeCarrito()`,
que persiste `tb_pedido` + `tb_pedido_item` en una sola transacción
JDBC con `setAutoCommit(false)` y rollback ante fallos.

---

## 📚 Catálogo (90 libros · 9 categorías)

| # | Categoría | Slug | Ejemplos |
|---|-----------|------|----------|
| 1 | Literatura Latinoamericana | `latinoamericana` | Cien años de soledad · Rayuela · Pedro Páramo · El Aleph |
| 2 | Clásicos Mundiales | `clasicos` | Don Quijote · Anna Karenina · Crimen y Castigo · Moby Dick |
| 3 | Ciencia Ficción y Distopía | `ciencia` | 1984 · Dune · Fundación · Neuromante |
| 4 | Tecnología e Ingeniería | `tecnologia` | Clean Code · CLRS · Refactoring · Design Patterns |
| 5 | Historia y Filosofía | `historia` | Sapiens · Meditaciones · La República · Así habló Zaratustra |
| 6 | Fantasía y Épica | `fantasia` | Trilogía LOTR · Harry Potter · Mistborn · Juego de Tronos |
| 7 | Biografías | `biografias` | Steve Jobs · Yo soy Malala · Becoming · Elon Musk |
| 8 | Desarrollo Personal | `desarrollo` | Hábitos Atómicos · 7 Hábitos · Mindset · Pensar rápido |
| 9 | **Manga** | `manga` | One Piece · Naruto · Berserk · **Hajime no Ippo** · Dragon Ball · Vagabond · Death Note · Attack on Titan · Bleach · Fullmetal Alchemist |

### Fallback nativo para portadas rotas

Las portadas se sirven mediante `<object data="url">`. Si la URL falla
(404, CORS, hotlinking bloqueado), el navegador **automáticamente**
renderiza el contenido interno del `<object>`:

```html
<object data="https://covers.openlibrary.org/b/isbn/9781591163589-L.jpg?default=false"
        type="image/jpeg" class="cover-obj">
    <span class="cover-fallback">Naruto — Tomo 1</span>
</object>
```

El span de fallback dibuja un gradiente oscuro/dorado con el título
centrado en tipografía Playfair, una barra dorada superior y la marca
"FOLIO" inferior. **El usuario nunca ve el icono de imagen rota.**

---

## 🗄️ Modelo de datos PostgreSQL

Cinco tablas en `folio_biblioteca`:

| Tabla | Responsabilidad | Consumidor |
|-------|-----------------|------------|
| `tb_usuario` | Cuentas con rol y flag `activo` | `UsuarioDAO`, `LoginServlet`, `GestionUsuariosServlet` |
| `clientes` | Tabla legada simple (compat. con `ClienteDAO`) | `ClienteDAO` |
| `tb_libro` | Catálogo de 90 libros (slug, ISBN único, stock, precio, categoría) | `LibroDAO`, `LibroAdminServlet`, `AplicarDescuentoServlet` |
| `tb_pedido` | Cabecera (usuario, fecha, subtotal, IVA, total, marca de pago) | `ProcesarPagoServlet`, `PedidoDAO` |
| `tb_pedido_item` | Líneas de cada pedido (FK libro + cantidad + precio snapshot) | `PedidoDAO` |

### Diagrama relacional

```
tb_usuario(id) ◄────┐
                    │ usuario_id
                    ▼
              tb_pedido(id) ◄────┐
                                 │ pedido_id
                                 ▼
                           tb_pedido_item
                                 │ libro_id
                                 ▼
                            tb_libro(id)
```

El script completo (`src/main/webapp/db/folio_setup.sql`) crea las
cinco tablas con `PRIMARY KEY`, `UNIQUE`, `CHECK`, FKs e índices,
inserta **3 cuentas semilla** (ADMIN/EMPLEADO/CLIENTE), **90 libros**
con ISBN único y **2 pedidos de demostración** para que admin y perfil
muestren datos al instalar.

---

## 📂 Estructura del repositorio

```
PRACTICAS/
├── .gitignore                          ← exclusiones limpias (IDE, target/, docx, etc.)
├── README.md                           ← este archivo
├── pom.xml                             ← Maven · empaqueta WAR como "FOLIO.war"
│
└── src/main/
    ├── java/ec/edu/ups/
    │   ├── controlador/                ← capa C de MVC (servlets + filtros)
    │   │   ├── CarritoServlet.java
    │   │   ├── FiltrarLibrosServlet.java
    │   │   ├── ProcesarPagoServlet.java       (Luhn + Transferencia + PayPal)
    │   │   ├── LoginServlet.java
    │   │   ├── LogoutServlet.java
    │   │   ├── RegistroServlet.java
    │   │   ├── GestionUsuariosServlet.java    (suspender/activar/eliminar)
    │   │   ├── LibroAdminServlet.java         (CRUD libros)
    │   │   ├── AplicarDescuentoServlet.java   (descuentos por categoría/libro)
    │   │   ├── SetThemeServlet.java           (conmutador tema)
    │   │   └── CharacterEncodingFilter.java   (UTF-8 global)
    │   │
    │   ├── dao/                        ← acceso a PostgreSQL
    │   │   ├── Conexion.java
    │   │   ├── LibroDAO.java           (listarTodos / porCategoria / insertar / eliminar / descuentos)
    │   │   ├── UsuarioDAO.java         (defensivo con/sin columna activo)
    │   │   ├── PedidoDAO.java          (transaccional)
    │   │   └── ClienteDAO.java
    │   │
    │   ├── modelo/                     ← POJOs + reglas de negocio
    │   │   ├── Libro.java
    │   │   ├── ItemCarrito.java
    │   │   ├── Carrito.java            (subtotal + IVA 15% + total)
    │   │   ├── CatalogoLibros.java     (fallback en memoria si no hay PG)
    │   │   ├── Pedido.java
    │   │   ├── ItemPedido.java
    │   │   ├── Usuario.java            (con campo activo)
    │   │   └── Cliente.java
    │   │
    │   └── util/
    │       └── LibroRenderer.java      (genera HTML del libro 3D con <object>)
    │
    └── webapp/
        ├── WEB-INF/jspf/               ← fragmentos reutilizables
        │   ├── header.jspf             (dropdown + tema + dropdown roles)
        │   ├── footer.jspf
        │   └── carrito-drawer.jspf
        │
        ├── css/estilos.css             (≈ 1500 líneas · Dark&Gold · Light · 3D · glassmorphism)
        │
        ├── db/folio_setup.sql          (schema + 90 libros + 2 pedidos semilla)
        │
        ├── index.jsp                   ← home
        ├── catalogo.jsp                ← catálogo filtrado
        ├── contacto.jsp                ← contacto con redes sociales premium
        ├── pago.jsp                    ← 3 métodos de pago en <details>
        ├── pago-exito.jsp
        ├── login.jsp                   ← con CSS Checkbox Hack para mostrar/ocultar clave
        ├── registro.jsp                ← idem
        ├── respuesta.jsp
        ├── admin.jsp                   ← dashboard ADMIN + sidebar empleado heredada
        ├── empleado.jsp                ← dashboard EMPLEADO + privilegios admin si aplica
        ├── perfil.jsp                  ← historial de pedidos del cliente
        └── uploads/                    ← fotos de perfil (excluidas por .gitignore)
```

---

## 🖼️ Funcionalidades por pantalla

### Home (`index.jsp`)
- Hero con CTA "Explorar catálogo".
- Barra de stats (5000 libros · 2500 lectores · 24 provincias · 15 años).
- 4 libros destacados con tarjetas 3D rotando 360° en hover.
- "Por qué FOLIO" (6 beneficios con icono dorado).
- "Cómo funciona" (3 pasos con flechas conectoras).
- Newsletter con `<form action="index.jsp" method="get">`.

### Catálogo (`catalogo.jsp` + `FiltrarLibrosServlet`)
- Filtros pill: Todas + 9 categorías.
- Vista "Todas" agrupa por sección con título e icono.
- Vista por categoría muestra grilla plana.
- Cada libro es una tarjeta 3D con seis caras (portada, contraportada,
  lomo con texto vertical, canto frontal, canto superior, canto
  inferior). Rotación 360° automática al pasar el cursor mediante
  `@keyframes girarLibro`.
- Botón "Añadir al carrito" = `<form method="POST">` al `CarritoServlet`.

### Carrito (drawer en `carrito-drawer.jspf`)
- Renderizado server-side por scriptlets que iteran `carrito.getItems()`.
- Cada línea tiene tres `<form>` independientes (+, −, eliminar) que
  POSTean al `CarritoServlet`.
- Resumen Subtotal / IVA 15% / Total calculado por `Carrito.java`.
- Drawer abierto/cerrado vía query string `?carrito=open` (sin JS).

### Pago (`pago.jsp` + `ProcesarPagoServlet`)
- Tres `<details>` con métodos de pago localizados (descritos arriba).
- Mensajes de error contextuales (`?error=marca_no_reconocida`,
  `?error=banco_invalido`, etc.) renderizados en español.

### Perfil del cliente (`perfil.jsp`)
- 3 KPIs: bienvenida, pedidos realizados, total gastado.
- Tabla del historial de pedidos con `PedidoDAO.listarPorUsuario(id)`.

### Dashboard Admin (`admin.jsp`)
- 4 secciones (`?sec=dashboard|usuarios|ventas|config`):
  - **Dashboard General**: estado del sistema, KPIs.
  - **Gestión de Usuarios**: lista completa con `<c:forEach>` JSTL,
    3 acciones por fila (Suspender / Activar / Eliminar) mediante
    `<form method="POST">` al `GestionUsuariosServlet`.
  - **Ventas y Reportes**: agregados de `tb_pedido` con totales por IVA.
  - **Configuración**: KPIs del sistema.
- Sidebar incluye `Módulo Empleado` (herencia ADMIN → EMPLEADO).

### Dashboard Empleado (`empleado.jsp`)
- 3 secciones (`?sec=inventario|agregar|descuentos`):
  - **Catálogo Actual**: tabla con todos los libros + botón Eliminar.
  - **Nuevo Libro**: formulario CRUD (título, autor, ISBN, precio,
    stock, categoría, páginas, URL portada). Slug autogenerado.
  - **Ofertas y Descuentos**: **dos formularios** server-side al
    `AplicarDescuentoServlet`:
    - Descuento por categoría (`<select>` de las 9 categorías).
    - Descuento por libro específico (id slug).
    Ambos aceptan 1–90% y emiten `UPDATE tb_libro SET precio = ...`.
- Si el usuario es ADMIN, ve además el grupo "Privilegios Admin".

### Acceso (`login.jsp` + `registro.jsp`)
- Campos de contraseña con **CSS Checkbox Hack** para mostrar/ocultar
  caracteres usando `-webkit-text-security` y selectores hermanos
  `:checked ~`. **Cero JavaScript.**

---

## 🎨 UI/UX premium (Gold & Dark)

- **Paleta dark default**: `#0b0b13`/`#14141d` con acento dorado
  `#d4af6a` y soft accent `rgba(212, 175, 106, 0.18)`.
- **Paleta light**: cream `#faf6ef` con texto `#14142b` (ratio AAA
  16:1) y oro oscurecido `#8a6b30`.
- **Glassmorphism** en sidebar, KPI cards, paneles, redes sociales y
  formularios (`backdrop-filter: blur(22px) saturate(150%)`).
- **Libros 3D** sin Three.js: seis caras CSS con `transform-style:
  preserve-3d` + `perspective: 1600px`. Espesor del lomo proporcional
  a las páginas (`Math.max(18, Math.min(70, paginas/15))`).
- **Scrollbar dorado** custom (Webkit + Firefox `scrollbar-color`).
- **Dropdowns sin JS** mediante `:hover` y `:focus-within`.
- **Micro-interacciones** con `transition: all 0.35s cubic-bezier(.2,
  .9, .25, 1)` en TODO botón/link/card.
- **Modo claro/oscuro** persistido en `HttpSession`.

---

## 🧰 Stack técnico

| Capa | Tecnología |
|------|------------|
| Lenguaje | Java 24 (compatible con LTS 21+) |
| Web container | Apache Tomcat 10.1+ (Jakarta namespace) |
| Servlet API | `jakarta.servlet-api` 6.0.0 |
| JSP / JSTL | JSP 3.1 + JSTL 3.0 (`jakarta.tags.core`) |
| Base de datos | PostgreSQL 15+ (driver 42.7.3) |
| Estilos | CSS3 puro (`perspective`, `backdrop-filter`, `@keyframes`) |
| Build | Maven 3.9+ + `maven-war-plugin` |
| **JavaScript** | **CERO** — auditado, sin `<script>` ni handlers `on*` |

---

## ⚙️ Instalación paso a paso

### Requisitos previos
- **JDK 21+** (probado con Java 24)
- **Apache Tomcat 10.1+** (Jakarta namespace, NO Tomcat 9)
- **PostgreSQL 15+**
- **Maven 3.9+**

### 1) Clonar el repositorio
```bash
git clone <URL-de-tu-repo> folio
cd folio
```

### 2) Crear la base de datos
```bash
psql -U postgres -c "CREATE DATABASE folio_biblioteca WITH ENCODING 'UTF8' TEMPLATE template0;"
psql -U postgres -d folio_biblioteca -f src/main/webapp/db/folio_setup.sql
```

Verificación rápida:
```sql
\c folio_biblioteca
SELECT categoria, COUNT(*) FROM tb_libro GROUP BY categoria ORDER BY categoria;
-- Debe retornar 9 filas, cada una con count = 10.

SELECT rol, COUNT(*) FROM tb_usuario GROUP BY rol;
-- ADMIN: 1, EMPLEADO: 1, CLIENTE: 1
```

### 3) Configurar credenciales JDBC
Edita `src/main/java/ec/edu/ups/dao/Conexion.java` si tu PostgreSQL
no usa los defaults:
```java
private static final String URL      = "jdbc:postgresql://localhost:5432/folio_biblioteca";
private static final String USER     = "postgres";
private static final String PASSWORD = "root";
```

### 4) Empaquetar el WAR
```bash
mvn clean package
```
Genera `target/FOLIO.war`.

### 5) Desplegar en Tomcat 10.1
Copia el WAR a `${CATALINA_HOME}/webapps/` (o usa el deployer del IDE).
Arranca Tomcat:
```
http://localhost:8080/FOLIO/
```

### 6) Encoding UTF-8 a nivel de conector
En `${CATALINA_HOME}/conf/server.xml`:
```xml
<Connector port="8080" protocol="HTTP/1.1"
           URIEncoding="UTF-8"
           useBodyEncodingForURI="true" />
```

En `bin/setenv.sh` (Linux/Mac) o `bin/setenv.bat` (Windows):
```bash
JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=UTF-8 -Duser.language=es -Duser.region=EC"
```

---

## 🔑 Credenciales maestras de prueba

El script `folio_setup.sql` inserta tres cuentas semilla — una por rol —
para que el profesor pueda probar todos los flujos al instante:

| Rol | Correo | Clave | Pantalla al entrar |
|-----|--------|-------|---------------------|
| 👑 **ADMIN** | `admin@folio.ec` | `admin123` | `admin.jsp` — Panel Central + Módulo Empleado |
| 🛠️ **EMPLEADO** | `empleado@folio.ec` | `empleado123` | `empleado.jsp` — Inventario, Nuevo Libro, Descuentos |
| 👤 **CLIENTE** | `cliente@folio.ec` | `cliente123` | `index.jsp` (con catálogo + carrito + perfil) |

> ⚠️ Estas son credenciales **académicas** para evaluación. En producción
> debes almacenar las contraseñas con **BCrypt** (`spring-security-crypto`
> o `at.favre.lib:bcrypt`) y exigir cambio en el primer ingreso.

---

## 📐 Convenciones de código

### JSP
```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
```
Siempre, sin excepción. Para usar JSTL: `<%@ taglib uri="jakarta.tags.core" prefix="c" %>`.

### Servlet
- Anotado con `@WebServlet(name = "...", urlPatterns = {"/..."})`.
- POST → mutación + `sendRedirect()` (Post-Redirect-Get).
- GET → consulta + render directo.
- Validación SIEMPRE server-side, nunca solo cosmética HTML5.

### DAO
- `try-with-resources` para `Connection`, `PreparedStatement`,
  `ResultSet`.
- Nunca expone `ResultSet` fuera del DAO.
- Implementación defensiva: cae a fallback en memoria si la conexión
  PG no está disponible.

### Modelo
- `private` + getters/setters convencionales.
- `implements Serializable` para todo objeto que viva en `HttpSession`.
- Validación de invariantes en setters (ej. `ItemCarrito.cantidad >= 1`).

### HTML
- Semántico: `<header>`, `<main>`, `<section>`, `<article>`, `<aside>`.
- **Cero `<script>`, cero `onclick`, cero `javascript:`.**

### CSS
- Variables en `:root` con override en `body.light`.
- Sin estilos inline excepto los triviales (`style="margin-top:1rem;"`).

---

## 👤 Créditos académicos

**Jairo Alejandro Ojeda Herrera**
Estudiante de Programación Web — **Universidad Politécnica Salesiana
(UPS)**, sede Quito.
Quinto Semestre · Periodo 2026.

> Asignatura: **Programación Web**
> Docente: (PATSY MALENA PRIETO VELEZ)
> Universidad Politécnica Salesiana, Ecuador.

Este proyecto se entrega con fines exclusivamente académicos. Las
portadas de los libros son referencias públicas de
[Open Library](https://openlibrary.org/) y similares.

---

## 📜 Licencia

Académico · uso educativo. Reutilización libre con atribución al autor.
