# 📚 FOLIO — Biblioteca Digital Premium

> E-commerce literario **server-side rendering puro** construido con Java EE
> (Jakarta EE 10), JSP/Servlets y PostgreSQL. Estética **Gold & Dark** con
> libros 3D interactivos en CSS3.  
> **Cero JavaScript en el cliente** — todo el flujo se procesa en el servidor.

![Java](https://img.shields.io/badge/Java-24-orange?logo=openjdk)
![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10-blueviolet)
![Tomcat](https://img.shields.io/badge/Tomcat-10.1%2B-yellow?logo=apachetomcat)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15%2B-336791?logo=postgresql)
![Maven](https://img.shields.io/badge/Maven-3.9%2B-red?logo=apachemaven)
![License](https://img.shields.io/badge/license-Academic-success)

---

## 🧭 Tabla de contenido

1. [Filosofía del proyecto](#-filosofía-del-proyecto)
2. [Arquitectura MVC Server-Side](#%EF%B8%8F-arquitectura-mvc-server-side)
3. [Estructura del repositorio](#-estructura-del-repositorio)
4. [Modelo de datos PostgreSQL](#-modelo-de-datos-postgresql)
5. [Catálogo (90 libros · 9 categorías)](#-catálogo-90-libros--9-categorías)
6. [Stack técnico](#-stack-técnico)
7. [Instalación paso a paso](#%EF%B8%8F-instalación-paso-a-paso)
8. [Credenciales de prueba](#-credenciales-de-prueba)
9. [Flujos clave](#-flujos-clave)
10. [UI/UX premium](#-uiux-premium)
11. [Convenciones de código](#-convenciones-de-código)
12. [Autoría](#-autoría)

---

## 💡 Filosofía del proyecto

FOLIO es una **librería online** con tres principios duros:

- **Cero JavaScript en el cliente.** Sin `<script>`, sin `onclick`, sin AJAX.
  Toda la lógica e interacción se resuelve mediante formularios POST
  tradicionales, `response.sendRedirect()` (Post-Redirect-Get) y CSS3 puro.
- **Server-Side Rendering estricto.** Las JSPs reciben sus datos desde
  servlets controladores; los modelos (`Libro`, `Carrito`, `ItemCarrito`)
  viven en la `HttpSession`.
- **POO + MVC.** Cada capa tiene una responsabilidad única. Los servlets
  jamás tocan SQL; los DAOs jamás tocan HTTP; las JSPs jamás tocan negocio.

---

## 🏛️ Arquitectura MVC Server-Side

```
┌────────────────────────────────────────────────────────────────────┐
│                            NAVEGADOR                                │
│  HTML + CSS3 puro (libros 3D, drawer carrito, dropdowns, glass)     │
│                            ▲     │                                  │
│   sendRedirect + Set-Cookie│     │POST <form>  /  GET <a href>      │
└────────────────────────────┼─────┼──────────────────────────────────┘
                             │     ▼
┌────────────────────────────┴────────────────────────────────────────┐
│   APACHE TOMCAT 10.1 + JAKARTA EE 10  (jakarta.servlet 6.0)         │
│                                                                     │
│   ┌──────────────────────────────────────────────────────────────┐  │
│   │  FILTROS                                                     │  │
│   │   · CharacterEncodingFilter  → fuerza UTF-8 entrada y salida │  │
│   └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌──────────────────── CONTROLADORES (servlets) ────────────────┐  │
│   │  LoginServlet / LogoutServlet / RegistroServlet              │  │
│   │  CarritoServlet         (AGREGAR/ELIMINAR/ACTUALIZAR/VACIAR) │  │
│   │  FiltrarLibrosServlet   (filtro por categoría)               │  │
│   │  ProcesarPagoServlet    (validación Luhn server-side)        │  │
│   └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌──────────────────── MODELO (POO) ────────────────────────────┐  │
│   │  Usuario · Libro · ItemCarrito · Carrito · CatalogoLibros    │  │
│   │  Carrito vive en HttpSession; encapsula IVA 15% y total.     │  │
│   └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌──────────────────── DAO (JDBC) ──────────────────────────────┐  │
│   │  Conexion · UsuarioDAO · ClienteDAO · LibroDAO               │  │
│   │  LibroDAO cae limpiamente a memoria si no hay PostgreSQL.    │  │
│   └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│   ┌──────────────────── VISTAS (JSP + JSPF) ─────────────────────┐  │
│   │  index · catalogo · contacto · pago · pago-exito             │  │
│   │  login · registro · respuesta · admin · empleado             │  │
│   │  Fragmentos: header.jspf · footer.jspf · carrito-drawer.jspf │  │
│   │  Helper: LibroRenderer (libro 3D HTML)                       │  │
│   └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────┬───────────────────────────────┘
                                      │ JDBC + UTF-8
                                      ▼
┌────────────────────────────────────────────────────────────────────┐
│        POSTGRESQL 15+   ·   BD: folio_biblioteca                    │
│   tb_usuario · clientes · tb_libro · tb_pedido · tb_pedido_item     │
└────────────────────────────────────────────────────────────────────┘
```

### Patrón Post-Redirect-Get

Cada acción del carrito sigue este flujo (sin AJAX):

```
[Cliente]  POST /CarritoServlet  (accion, libroId, redirect, carrito=open)
   │
   ▼
[Servlet]  carrito.agregar(libro)              ← muta la HttpSession
   │
   ▼
[Servlet]  response.sendRedirect(redirect + "?carrito=open")
   │
   ▼
[Cliente]  GET /index.jsp?carrito=open         ← recarga limpia
   │
   ▼
[JSP]      renderiza el drawer con la sesión actualizada
```

---

## 📂 Estructura del repositorio

```
PRACTICAS/                              ← raíz del proyecto Maven
├── .gitignore                          ← exclusiones limpias (IDE, target/, docx, etc.)
├── README.md                           ← este archivo
├── pom.xml                             ← Maven · empaqueta WAR como "FOLIO.war"
│
└── src/
    ├── main/
    │   ├── java/ec/edu/ups/
    │   │   ├── controlador/            ← servlets (capa C de MVC)
    │   │   │   ├── CarritoServlet.java
    │   │   │   ├── FiltrarLibrosServlet.java
    │   │   │   ├── ProcesarPagoServlet.java
    │   │   │   ├── LoginServlet.java
    │   │   │   ├── LogoutServlet.java
    │   │   │   ├── RegistroServlet.java
    │   │   │   └── CharacterEncodingFilter.java   ← UTF-8 global
    │   │   │
    │   │   ├── dao/                    ← acceso a PostgreSQL
    │   │   │   ├── Conexion.java
    │   │   │   ├── LibroDAO.java
    │   │   │   ├── UsuarioDAO.java
    │   │   │   └── ClienteDAO.java
    │   │   │
    │   │   ├── modelo/                 ← POJOs y reglas de negocio
    │   │   │   ├── Libro.java
    │   │   │   ├── ItemCarrito.java
    │   │   │   ├── Carrito.java        ← subtotal · IVA 15% · total
    │   │   │   ├── CatalogoLibros.java ← fallback en memoria
    │   │   │   ├── Usuario.java
    │   │   │   └── Cliente.java
    │   │   │
    │   │   └── util/
    │   │       └── LibroRenderer.java  ← genera HTML del libro 3D
    │   │
    │   └── webapp/
    │       ├── WEB-INF/
    │       │   └── jspf/               ← fragmentos reutilizables
    │       │       ├── header.jspf
    │       │       ├── footer.jspf
    │       │       └── carrito-drawer.jspf
    │       │
    │       ├── css/
    │       │   └── estilos.css         ← Dark & Gold, libros 3D, glassmorphism
    │       │
    │       ├── db/
    │       │   └── folio_setup.sql     ← schema + 90 libros semilla
    │       │
    │       ├── uploads/                ← fotos de perfil (excluidas por .gitignore)
    │       │
    │       ├── index.jsp               ← home
    │       ├── catalogo.jsp            ← catálogo filtrado
    │       ├── contacto.jsp
    │       ├── pago.jsp                ← formulario POST de pago
    │       ├── pago-exito.jsp
    │       ├── login.jsp
    │       ├── registro.jsp
    │       ├── respuesta.jsp
    │       ├── admin.jsp               ← dashboard ADMIN
    │       └── empleado.jsp            ← dashboard EMPLEADO
    │
    └── test/java/                      ← (espacio reservado para JUnit)
```

> ⚠️ **Lo que NO debe estar en el repo** (incluido en `.gitignore`):
> `target/`, `.idea/`, `.smarttomcat/`, `.ollamassist/`, `*.iml`, `*.class`,
> y archivos personales del estudiante (`*.docx`, `*.pdf`, `*.mp4`, `CURSO PREGUNTAS.docx`).

---

## 🗄️ Modelo de datos PostgreSQL

Cinco tablas en `folio_biblioteca`:

| Tabla              | Responsabilidad                                      | Servlet/DAO consumidor       |
| ------------------ | ---------------------------------------------------- | ---------------------------- |
| `tb_usuario`       | Cuentas con rol (CLIENTE / EMPLEADO / ADMIN)         | `UsuarioDAO`, `LoginServlet` |
| `clientes`         | Tabla legada simple (compat. con `ClienteDAO`)       | `ClienteDAO`                 |
| `tb_libro`         | Catálogo de 90 libros · 9 categorías                 | `LibroDAO`                   |
| `tb_pedido`        | Cabecera de pedido (post-pago)                       | `ProcesarPagoServlet`        |
| `tb_pedido_item`   | Líneas de cada pedido (FK a libro y pedido)          | `ProcesarPagoServlet`        |

### Diagrama relacional simplificado

```
tb_usuario(id) ◄────┐
                    │ usuario_id
                    │
                    ├─── tb_pedido(id) ◄────┐
                                            │ pedido_id
                                            │
                                            ├─── tb_pedido_item
                                                       │
                                                       │ libro_id
                                                       ▼
                                                  tb_libro(id)
```

El script completo (`src/main/webapp/db/folio_setup.sql`) crea:

- las cinco tablas con sus `CHECK`, `UNIQUE` e índices apropiados,
- tres cuentas semilla (ADMIN, EMPLEADO, CLIENTE),
- **90 libros reales** con ISBN único y portada en alta calidad.

---

## 📚 Catálogo (90 libros · 9 categorías)

10 títulos por categoría, todos con su ISBN real:

| Categoría                          | Slug              | Ejemplos representativos                                      |
| ---------------------------------- | ----------------- | ------------------------------------------------------------- |
| Literatura Latinoamericana         | `latinoamericana` | Cien años de soledad · Rayuela · Pedro Páramo · El Aleph      |
| Clásicos Mundiales                 | `clasicos`        | Don Quijote · Anna Karenina · Crimen y Castigo · Moby Dick    |
| Ciencia Ficción y Distopía         | `ciencia`         | 1984 · Dune · Fundación · Neuromante · El cuento de la criada |
| Tecnología e Ingeniería            | `tecnologia`      | Clean Code · CLRS · Refactoring · Design Patterns             |
| Historia y Filosofía               | `historia`        | Sapiens · Meditaciones · La República · El arte de la guerra  |
| Fantasía y Épica                   | `fantasia`        | Trilogía LOTR · Harry Potter · Mistborn · Juego de Tronos     |
| Biografías                         | `biografias`      | Steve Jobs · Yo soy Malala · Becoming · Elon Musk · Einstein  |
| Desarrollo Personal                | `desarrollo`      | Hábitos Atómicos · 7 Hábitos · Mindset · Pensar rápido…       |
| **Manga**                          | `manga`           | One Piece · Naruto · Berserk · Hajime no Ippo · Dragon Ball · Vagabond · Death Note · Attack on Titan · Bleach · Fullmetal Alchemist |

---

## 🧰 Stack técnico

| Capa            | Tecnología                                                     |
| --------------- | -------------------------------------------------------------- |
| Lenguaje        | Java 24 (compatible con LTS 21+)                                |
| Web container   | Apache Tomcat 10.1 (Jakarta EE 10)                              |
| API servlet     | `jakarta.servlet-api` 6.0.0                                     |
| Vistas          | JSP 3.1 + fragmentos `.jspf`                                    |
| Base de datos   | PostgreSQL 15+ (driver `postgresql` 42.7.3)                     |
| Estilos         | CSS3 puro (`perspective`, `backdrop-filter`, `keyframes`)       |
| Build           | Maven 3.9+ (`maven-war-plugin` 3.4.0)                           |
| **JavaScript**  | **NINGUNO** — ni un solo `<script>` en todo el proyecto.        |

---

## ⚙️ Instalación paso a paso

### 0) Requisitos

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
# desde el shell del sistema operativo
psql -U postgres -c "CREATE DATABASE folio_biblioteca WITH ENCODING 'UTF8' TEMPLATE template0;"
psql -U postgres -d folio_biblioteca -f src/main/webapp/db/folio_setup.sql
```

> Si la collation `es_EC.UTF-8` no está disponible en tu host, omite los
> parámetros `LC_COLLATE`/`LC_CTYPE` del `CREATE DATABASE`. El script
> ya está blindado con `SET client_encoding = 'UTF8'`.

Verifica:

```sql
\c folio_biblioteca
SELECT categoria, COUNT(*) FROM tb_libro GROUP BY categoria ORDER BY categoria;
-- Debe devolver 10 filas, una por cada categoría, con count = 10.
```

### 3) Ajustar credenciales si tu PostgreSQL no usa los defaults

Edita [`src/main/java/ec/edu/ups/dao/Conexion.java`](src/main/java/ec/edu/ups/dao/Conexion.java):

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

Copia el WAR a `${CATALINA_HOME}/webapps/` (o usa el deployer de tu IDE).
Arranca Tomcat y abre:

```
http://localhost:8080/FOLIO/
```

### 6) Variables de entorno recomendadas

Para forzar UTF-8 en el conector HTTP de Tomcat añade en
`${CATALINA_HOME}/conf/server.xml`:

```xml
<Connector port="8080" protocol="HTTP/1.1"
           URIEncoding="UTF-8"
           useBodyEncodingForURI="true" />
```

Y en `bin/setenv.sh` (Linux/Mac) o `bin/setenv.bat` (Windows):

```bash
JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=UTF-8 -Duser.language=es -Duser.region=EC"
```

---

## 🔑 Credenciales de prueba

El script `folio_setup.sql` inserta tres cuentas para testear cada rol:

| Rol         | Correo               | Clave         | Pantalla post-login          |
| ----------- | -------------------- | ------------- | ---------------------------- |
| 👑 ADMIN     | `admin@folio.ec`     | `admin123`    | `admin.jsp` (Panel Central)  |
| 🛠️ EMPLEADO  | `empleado@folio.ec`  | `empleado123` | `empleado.jsp` (Inventario)  |
| 👤 CLIENTE   | `cliente@folio.ec`   | `cliente123`  | `index.jsp` (catálogo + carrito) |

> ⚠️ **Estas son credenciales de demostración.** En producción deberías
> almacenar las claves con `BCrypt` y exigir cambio en el primer acceso.

---

## 🔄 Flujos clave

### Añadir un libro al carrito
```
1. Usuario hace clic en "Añadir al carrito"
   → <form method="POST" action="CarritoServlet">
        <input name="accion"   value="AGREGAR_LIBRO">
        <input name="libroId"  value="cien-anios-soledad">
        <input name="redirect" value="FiltrarLibrosServlet?categoria=latinoamericana">
        <input name="carrito"  value="open">
      </form>

2. CarritoServlet recibe POST → carrito.agregar(libro)
3. CarritoServlet hace sendRedirect("FiltrarLibrosServlet?categoria=latinoamericana&carrito=open")
4. El navegador recarga la página
5. carrito-drawer.jspf detecta carrito=open y renderiza el drawer
```

### Procesar un pago
```
1. /pago.jsp muestra el formulario con resumen IVA 15%
2. <form action="ProcesarPagoServlet" method="post">
3. ProcesarPagoServlet ejecuta en orden:
     · detectarMarca(numero)            ← VISA / MC / AMEX / DISCOVER / DINERS
     · longitud válida según marca
     · ALGORITMO DE LUHN                 ← módulo 10 server-side
     · validar titular (nombre + apellido, sólo letras)
     · validar fecha (YearMonth no vencida)
     · validar CVV (3 ó 4 dígitos según marca)
4. Si OK → carrito.vaciar() + sendRedirect("pago-exito.jsp?...")
   Si falla → sendRedirect("pago.jsp?error=<codigo>")
```

### Filtrar el catálogo por categoría
```
GET /FiltrarLibrosServlet?categoria=manga
   → LibroDAO.listarPorCategoria("manga")
   → SELECT * FROM tb_libro WHERE LOWER(categoria) = 'manga'
   → request.setAttribute("libros", lista)
   → forward a catalogo.jsp
```

---

## 🎨 UI/UX premium

- **Paleta Gold & Dark.** `#d4af6a` sobre `#07070d` y `#14141d`.
- **Libros 3D reales** (seis caras CSS: portada, contraportada, lomo,
  canto frontal, superior e inferior). El grosor del lomo se calcula
  por `Math.max(18, min(70, paginas/15))` e inyecta como `--book-d`.
  Rotación 360° al `:hover` mediante `@keyframes girarLibro`.
- **Glassmorphism** en KPIs, sidebar y formularios: `backdrop-filter:
  blur(22px) saturate(150%)` + bordes degradados dorados.
- **Scrollbar dorado** custom (Webkit + Firefox).
- **Dropdowns sin JS** con `:hover` y `:focus-within`.
- **Drawer del carrito** server-side: visible cuando la URL incluye
  `?carrito=open`. Cerrar = enlace sin ese parámetro.

---

## 📐 Convenciones de código

- **JSP**: siempre `<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>`.
- **Servlet**: registrado con `@WebServlet`. POST → mutación + redirect; GET → lectura.
- **DAO**: usa try-with-resources; nunca expone `ResultSet` fuera del DAO.
- **Modelo**: campos privados + getters/setters; `Serializable` si vive en la sesión.
- **CSS**: variables `:root`, sin inline styles excepto cuando es trivial.
- **HTML**: semántico (`<header>`, `<main>`, `<section>`, `<article>`, `<aside>`).
- **Cero `<script>`**, cero `onclick`, cero `javascript:`.

---

## 👤 Autoría

**Jairo Alejandro Ojeda Herrera**  
Estudiante de Programación Web — Universidad Politécnica Salesiana (UPS), Quito · Ecuador.  
Quinto semestre · 2026.

> Este proyecto es académico y se distribuye con fines educativos.
> Las portadas son referencias públicas de Open Library.
