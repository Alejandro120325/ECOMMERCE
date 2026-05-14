# FOLIO - Biblioteca Digital

Proyecto de E-commerce para una biblioteca digital, desarrollado como parte de la formación académica en la **Universidad Politécnica Salesiana (UPS)**.

## 📖 Descripción
FOLIO es una plataforma web moderna y responsive que permite a los usuarios explorar catálogos literarios, gestionar un carrito de compras y realizar pagos seguros. El sistema cuenta con roles de usuario diferenciados (Cliente, Empleado, Administrador) y paneles de control específicos para la gestión de inventario y análisis de ventas.

## ✨ Características Principales
- **Gestión de Sesiones:** Registro e inicio de sesión seguro con validación de roles y persistencia de sesión.
- **Carrito de Compras:** Persistencia mediante `localStorage`, permitiendo mantener los libros añadidos incluso al navegar entre secciones.
- **Dashboard de Admin:** Panel central para supervisar ventas, gestionar usuarios y reportes del sistema.
- **Inventario para Empleados:** Módulo dedicado para agregar, editar, eliminar libros y gestionar descuentos directamente en la base de datos.
- **Interfaz Adaptable:** Soporte para modo oscuro/claro y diseño responsive utilizando GSAP para animaciones y CSS moderno.
- **Pasarela de Pagos:** Validación en tiempo real de tarjetas de crédito/débito utilizando el algoritmo de Luhn.

## 🛠 Tecnologías Utilizadas
- **Backend:** Java EE (Servlets, JSP).
- **Base de Datos:** PostgreSQL.
- **Frontend:** HTML5, CSS3, JavaScript (ES6+), GSAP (Animaciones), FontAwesome (Iconografía).
- **Servidor:** Apache Tomcat.
- **Gestión de dependencias:** Maven.

## 🚀 Instalación y Configuración

### Requisitos previos
1. Java JDK 17 o superior.
2. Apache Tomcat (versión recomendada 10/11).
3. PostgreSQL.
4. IDE recomendado: IntelliJ IDEA (con soporte para Jakarta EE).

### Pasos de despliegue
1. **Clonar el repositorio:**
   ```bash
   git clone [https://github.com/Alejandro120325/ECOMMERCE.git](https://github.com/Alejandro120325/ECOMMERCE.git)
   

2. **Configuración de Base de Datos:**
Ejecuta el script SQL en tu instancia de PostgreSQL para crear la estructura folio_biblioteca y los roles de usuario.


3. **Configuración del proyecto:**
Asegúrate de que la clase Conexion.java tenga las credenciales correctas para tu base de datos local.


4. **Despliegue:**

  - Abre el proyecto en IntelliJ.

  - Configura el servidor Tomcat local.

  - Ejecuta el proyecto.
  

**👤 Autor**
Jairo Alejandro Ojeda Herrera Estudiante de Ingeniería en Ciencias de la Computación - UPS
