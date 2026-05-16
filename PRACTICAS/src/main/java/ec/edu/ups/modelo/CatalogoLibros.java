package ec.edu.ups.modelo;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * FOLIO - Catálogo de libros en memoria.
 * <p>
 * Singleton thread-safe (inicialización en clase) que actúa como
 * fuente de verdad del catálogo durante el ciclo de vida de la
 * aplicación. El {@code CarritoServlet} lo consulta para validar que
 * el id recibido del cliente corresponda a un libro real, evitando
 * que el frontend pueda inyectar precios arbitrarios.
 * <p>
 * En un escenario real esta clase se reemplazaría por un DAO contra
 * PostgreSQL — la firma pública ({@link #buscarPorId(String)}) ya está
 * pensada para esa sustitución sin tocar el servlet.
 */
public final class CatalogoLibros {

    private static final CatalogoLibros INSTANCIA = new CatalogoLibros();

    private final Map<String, Libro> libros = new LinkedHashMap<>();

    private CatalogoLibros() {
        cargarCatalogo();
    }

    public static CatalogoLibros getInstancia() {
        return INSTANCIA;
    }

    public Libro buscarPorId(String id) {
        if (id == null) return null;
        return libros.get(id);
    }

    public Map<String, Libro> obtenerTodos() {
        return Collections.unmodifiableMap(libros);
    }

    // ------------------------------------------------------------------
    // Carga inicial (datos hard-coded — sustituibles por DAO)
    // ------------------------------------------------------------------
    private void cargarCatalogo() {
        // --- Literatura Latinoamericana ---
        add("cien-anios-soledad", "Cien años de soledad", "Gabriel García Márquez", 18.90,
                "https://covers.openlibrary.org/b/isbn/9780307474728-L.jpg", 471, "latinoamericana");
        add("el-aleph", "El Aleph", "Jorge Luis Borges", 15.50,
                "https://covers.openlibrary.org/b/isbn/9788499089515-L.jpg", 224, "latinoamericana");
        add("rayuela", "Rayuela", "Julio Cortázar", 21.00,
                "https://covers.openlibrary.org/b/isbn/9788437604572-L.jpg", 736, "latinoamericana");
        add("pedro-paramo", "Pedro Páramo", "Juan Rulfo", 14.20,
                "https://covers.openlibrary.org/b/isbn/9789681601638-L.jpg", 132, "latinoamericana");

        // --- Clásicos Mundiales ---
        add("don-quijote", "Don Quijote", "Miguel de Cervantes", 25.00,
                "https://covers.openlibrary.org/b/isbn/9780142437230-L.jpg", 1056, "clasicos");
        add("orgullo-prejuicio", "Orgullo y Prejuicio", "Jane Austen", 12.80,
                "https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg", 432, "clasicos");
        add("crimen-castigo", "Crimen y Castigo", "Fiódor Dostoyevski", 19.50,
                "https://covers.openlibrary.org/b/isbn/9780143058144-L.jpg", 671, "clasicos");

        // --- Ciencia Ficción y Distopía ---
        add("1984", "1984", "George Orwell", 16.00,
                "https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg", 328, "ciencia");
        add("fahrenheit-451", "Fahrenheit 451", "Ray Bradbury", 13.90,
                "https://covers.openlibrary.org/b/isbn/9781451673319-L.jpg", 249, "ciencia");
        add("comunidad-anillo", "La Comunidad del Anillo", "J.R.R. Tolkien", 28.50,
                "https://covers.openlibrary.org/b/isbn/9780547928210-L.jpg", 423, "ciencia");

        // --- Tecnología e Ingeniería ---
        add("clean-code", "Clean Code", "Robert C. Martin", 32.00,
                "https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg", 464, "tecnologia");
        add("pragmatic-programmer", "The Pragmatic Programmer", "Andrew Hunt & David Thomas", 29.90,
                "https://covers.openlibrary.org/b/isbn/9780201616224-L.jpg", 352, "tecnologia");
        add("design-patterns", "Design Patterns", "Gamma, Helm, Johnson & Vlissides", 38.00,
                "https://covers.openlibrary.org/b/isbn/9780201633610-L.jpg", 395, "tecnologia");
        add("intro-algoritmos", "Introduction to Algorithms", "Cormen, Leiserson, Rivest, Stein", 49.50,
                "https://covers.openlibrary.org/b/isbn/9780262033848-L.jpg", 1312, "tecnologia");

        // --- Historia y Filosofía ---
        add("sapiens", "Sapiens: De animales a dioses", "Yuval Noah Harari", 22.50,
                "https://covers.openlibrary.org/b/isbn/9780062316097-L.jpg", 496, "historia");
        add("la-republica", "La República", "Platón", 14.80,
                "https://covers.openlibrary.org/b/isbn/9788420674063-L.jpg", 528, "historia");
        add("zaratustra", "Así habló Zaratustra", "Friedrich Nietzsche", 16.40,
                "https://covers.openlibrary.org/b/isbn/9780140441185-L.jpg?default=false", 432, "historia");
        add("meditaciones", "Meditaciones", "Marco Aurelio", 12.00,
                "https://covers.openlibrary.org/b/isbn/9788420674049-L.jpg", 256, "historia");

        // --- Fantasía y Épica ---
        add("harry-potter-1", "Harry Potter y la Piedra Filosofal", "J.K. Rowling", 19.90,
                "https://covers.openlibrary.org/b/isbn/9788478884452-L.jpg", 256, "fantasia");
        add("juego-tronos", "Juego de Tronos", "George R.R. Martin", 24.90,
                "https://covers.openlibrary.org/b/isbn/9780553103540-L.jpg", 694, "fantasia");
        add("nombre-viento", "El Nombre del Viento", "Patrick Rothfuss", 23.50,
                "https://covers.openlibrary.org/b/isbn/9780756404741-L.jpg", 662, "fantasia");
        add("dos-torres", "Las Dos Torres", "J.R.R. Tolkien", 26.00,
                "https://covers.openlibrary.org/b/isbn/9780547928203-L.jpg", 352, "fantasia");

        // --- Biografías ---
        add("steve-jobs", "Steve Jobs", "Walter Isaacson", 27.90,
                "https://covers.openlibrary.org/b/isbn/9781451648539-L.jpg", 656, "biografias");
        add("yo-malala", "Yo soy Malala", "Malala Yousafzai", 18.20,
                "https://covers.openlibrary.org/b/isbn/9780316322409-L.jpg", 327, "biografias");
        add("largo-camino", "Un largo camino hacia la libertad", "Nelson Mandela", 25.40,
                "https://covers.openlibrary.org/b/isbn/9780316548182-L.jpg", 656, "biografias");
        add("open-agassi", "Open: Memorias", "Andre Agassi", 21.30,
                "https://covers.openlibrary.org/b/isbn/9780307268198-L.jpg", 400, "biografias");

        // --- Desarrollo Personal ---
        add("habitos-atomicos", "Hábitos Atómicos", "James Clear", 19.50,
                "https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg", 320, "desarrollo");
        add("7-habitos", "Los 7 Hábitos de la Gente Altamente Efectiva", "Stephen R. Covey", 20.90,
                "https://covers.openlibrary.org/b/isbn/9781982137274-L.jpg", 432, "desarrollo");
        add("poder-ahora", "El Poder del Ahora", "Eckhart Tolle", 16.80,
                "https://covers.openlibrary.org/b/isbn/9781577314806-L.jpg", 236, "desarrollo");
        add("pensar-rapido", "Pensar rápido, pensar despacio", "Daniel Kahneman", 23.90,
                "https://covers.openlibrary.org/b/isbn/9780374533557-L.jpg", 499, "desarrollo");

        // --- Manga (10 títulos icónicos) ---
        add("one-piece-1",      "One Piece — Tomo 1",                "Eiichiro Oda",        9.90,
                "https://covers.openlibrary.org/b/isbn/9784088725093-L.jpg", 216, "manga");
        add("naruto-1",         "Naruto — Tomo 1",                   "Masashi Kishimoto",   8.90,
                "https://covers.openlibrary.org/b/isbn/9781591163589-L.jpg?default=false", 200, "manga");
        add("berserk-1",        "Berserk — Volumen 1",               "Kentaro Miura",      12.50,
                "https://covers.openlibrary.org/b/isbn/9781593070205-L.jpg", 232, "manga");
        add("hajime-ippo-1",    "Hajime no Ippo — Tomo 1",           "George Morikawa",     9.50,
                "https://covers.openlibrary.org/b/isbn/9781632361424-L.jpg?default=false", 200, "manga");
        add("dragon-ball-1",    "Dragon Ball — Tomo 1",              "Akira Toriyama",      8.90,
                "https://covers.openlibrary.org/b/isbn/9781569319208-L.jpg?default=false", 192, "manga");
        add("vagabond-1",       "Vagabond — Volumen 1",              "Takehiko Inoue",     11.50,
                "https://covers.openlibrary.org/b/isbn/9781421520544-L.jpg", 200, "manga");
        add("death-note-1",     "Death Note — Volumen 1",            "Tsugumi Ohba & Takeshi Obata", 10.20,
                "https://covers.openlibrary.org/b/isbn/9781421501680-L.jpg", 195, "manga");
        add("attack-titan-1",   "Attack on Titan — Volumen 1",       "Hajime Isayama",     10.90,
                "https://covers.openlibrary.org/b/isbn/9781935654513-L.jpg", 208, "manga");
        add("bleach-1",         "Bleach — Volumen 1",                "Tite Kubo",           9.20,
                "https://covers.openlibrary.org/b/isbn/9781591164418-L.jpg", 192, "manga");
        add("fullmetal-1",      "Fullmetal Alchemist — Volumen 1",   "Hiromu Arakawa",     10.50,
                "https://covers.openlibrary.org/b/isbn/9781591169208-L.jpg", 192, "manga");
    }

    private void add(String id, String titulo, String autor, double precio,
                     String imagen, int paginas, String categoria) {
        libros.put(id, new Libro(id, titulo, autor, precio, imagen, paginas, categoria));
    }
}
