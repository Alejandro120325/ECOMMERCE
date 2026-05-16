-- =====================================================================
-- FOLIO - Biblioteca Digital
-- Script de inicialización completo para PostgreSQL.
-- ---------------------------------------------------------------------
--   Base de datos:  folio_biblioteca
--   Encoding:       UTF-8
--   Esquema:        tb_usuario · clientes · tb_libro · tb_pedido · tb_pedido_item
--   Semilla:        90 libros (10 por cada una de las 9 categorías)
-- ---------------------------------------------------------------------
-- Ejecutar:
--   1)  CREATE DATABASE folio_biblioteca WITH ENCODING 'UTF8' LC_COLLATE='es_EC.UTF-8' LC_CTYPE='es_EC.UTF-8' TEMPLATE=template0;
--   2)  \c folio_biblioteca
--   3)  \i folio_setup.sql
-- =====================================================================

SET client_encoding = 'UTF8';
SET standard_conforming_strings = ON;

-- ---------------------------------------------------------------------
-- 0. Limpieza idempotente (orden inverso por las FKs)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS tb_pedido_item CASCADE;
DROP TABLE IF EXISTS tb_pedido      CASCADE;
DROP TABLE IF EXISTS tb_libro       CASCADE;
DROP TABLE IF EXISTS clientes       CASCADE;
DROP TABLE IF EXISTS tb_usuario     CASCADE;

-- =====================================================================
-- 1. tb_usuario  — Cuentas con rol (CLIENTE / EMPLEADO / ADMIN)
-- =====================================================================
CREATE TABLE tb_usuario (
    id               SERIAL       PRIMARY KEY,
    nombre           VARCHAR(80)  NOT NULL,
    apellido         VARCHAR(80)  NOT NULL,
    cedula           VARCHAR(20)  UNIQUE NOT NULL,
    fecha_nacimiento DATE,
    estado_civil     VARCHAR(20),
    genero           CHAR(1),
    provincia        VARCHAR(60),
    ciudad           VARCHAR(60),
    direccion        VARCHAR(200),
    telefono         VARCHAR(20),
    correo           VARCHAR(120) UNIQUE NOT NULL,
    clave            VARCHAR(120) NOT NULL,
    foto_perfil      VARCHAR(200),
    rol              VARCHAR(20)  NOT NULL DEFAULT 'CLIENTE'
                                  CHECK (rol IN ('CLIENTE','EMPLEADO','ADMIN')),
    activo           BOOLEAN      NOT NULL DEFAULT TRUE,   -- false = cuenta suspendida
    creado_en        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_tb_usuario_correo ON tb_usuario (correo);
CREATE INDEX idx_tb_usuario_rol    ON tb_usuario (rol);
CREATE INDEX idx_tb_usuario_activo ON tb_usuario (activo);

-- =====================================================================
-- 2. clientes  — Tabla auxiliar legada (ClienteDAO la usa para insertar)
-- =====================================================================
CREATE TABLE clientes (
    id           SERIAL       PRIMARY KEY,
    nombre       VARCHAR(120) NOT NULL,
    cedula       VARCHAR(20)  UNIQUE NOT NULL,
    estado_civil VARCHAR(20),
    correo       VARCHAR(120) UNIQUE NOT NULL,
    password     VARCHAR(120) NOT NULL,
    creado_en    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- 3. tb_libro  — Catálogo (consultado por LibroDAO)
-- =====================================================================
CREATE TABLE tb_libro (
    id         VARCHAR(60)  PRIMARY KEY,            -- slug legible (clave de negocio)
    titulo     VARCHAR(200) NOT NULL,
    autor      VARCHAR(200) NOT NULL,
    isbn       VARCHAR(20)  UNIQUE NOT NULL,
    precio     NUMERIC(8,2) NOT NULL CHECK (precio >= 0),
    stock      INTEGER      NOT NULL DEFAULT 0 CHECK (stock >= 0),
    imagen     VARCHAR(500),
    paginas    INTEGER      NOT NULL DEFAULT 200 CHECK (paginas > 0),
    categoria  VARCHAR(60)  NOT NULL,
    creado_en  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_tb_libro_categoria ON tb_libro (categoria);
CREATE INDEX idx_tb_libro_autor     ON tb_libro (autor);

-- =====================================================================
-- 4. tb_pedido  — Cabecera de pedido (post-checkout)
-- =====================================================================
CREATE TABLE tb_pedido (
    id            SERIAL        PRIMARY KEY,
    usuario_id    INTEGER       REFERENCES tb_usuario(id) ON DELETE SET NULL,
    fecha         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal      NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
    iva           NUMERIC(10,2) NOT NULL CHECK (iva      >= 0),
    total         NUMERIC(10,2) NOT NULL CHECK (total    >= 0),
    estado        VARCHAR(20)   NOT NULL DEFAULT 'PAGADO'
                                CHECK (estado IN ('PENDIENTE','PAGADO','ENVIADO','ENTREGADO','CANCELADO')),
    marca_tarjeta VARCHAR(30),
    ultimos4      CHAR(4)
);
CREATE INDEX idx_tb_pedido_usuario ON tb_pedido (usuario_id);
CREATE INDEX idx_tb_pedido_fecha   ON tb_pedido (fecha DESC);

-- =====================================================================
-- 5. tb_pedido_item  — Líneas de detalle por pedido
-- =====================================================================
CREATE TABLE tb_pedido_item (
    id              SERIAL       PRIMARY KEY,
    pedido_id       INTEGER      NOT NULL REFERENCES tb_pedido(id) ON DELETE CASCADE,
    libro_id        VARCHAR(60)  NOT NULL REFERENCES tb_libro(id),
    cantidad        INTEGER      NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(8,2) NOT NULL CHECK (precio_unitario >= 0)
);
CREATE INDEX idx_tb_pedido_item_pedido ON tb_pedido_item (pedido_id);
CREATE INDEX idx_tb_pedido_item_libro  ON tb_pedido_item (libro_id);

-- =====================================================================
-- 6. Cuentas semilla (credenciales de prueba para los 3 roles)
-- =====================================================================
INSERT INTO tb_usuario
    (nombre, apellido, cedula, fecha_nacimiento, estado_civil, genero,
     provincia, ciudad, direccion, telefono, correo, clave, foto_perfil, rol)
VALUES
('Alejandro','Ojeda Admin','1700000001','1995-05-20','Soltero','M',
 'Pichincha','Quito','Av. Isabel La Católica N23-52','0991234567',
 'admin@folio.ec','admin123',NULL,'ADMIN'),

('Carla','Pérez Empleada','1700000002','1996-09-12','Soltero','F',
 'Pichincha','Quito','Av. 6 de Diciembre N32-10','0992345678',
 'empleado@folio.ec','empleado123',NULL,'EMPLEADO'),

('María Elena','Rivera','1700000003','1998-03-04','Soltero','F',
 'Pichincha','Quito','Calle Las Casas y 9 de Octubre','0993456789',
 'cliente@folio.ec','cliente123',NULL,'CLIENTE');

-- =====================================================================
-- 7. tb_libro  — 90 libros: 10 por cada una de 9 categorías
-- ---------------------------------------------------------------------
-- Columnas: id (slug)  ·  titulo  ·  autor  ·  isbn  ·  precio  ·  stock
--           imagen (URL openlibrary)  ·  paginas  ·  categoria
-- =====================================================================
INSERT INTO tb_libro
    (id, titulo, autor, isbn, precio, stock, imagen, paginas, categoria) VALUES

-- =================== 1) LITERATURA LATINOAMERICANA (10) ===================
('cien-anios-soledad',        'Cien años de soledad',                  'Gabriel García Márquez',   '9780307474728', 18.90, 50, 'https://covers.openlibrary.org/b/isbn/9780307474728-L.jpg',  471, 'latinoamericana'),
('el-aleph',                  'El Aleph',                              'Jorge Luis Borges',        '9788499089515', 15.50, 35, 'https://covers.openlibrary.org/b/isbn/9788499089515-L.jpg',  224, 'latinoamericana'),
('rayuela',                   'Rayuela',                               'Julio Cortázar',           '9788437604572', 21.00, 28, 'https://covers.openlibrary.org/b/isbn/9788437604572-L.jpg',  736, 'latinoamericana'),
('pedro-paramo',              'Pedro Páramo',                          'Juan Rulfo',               '9789681601638', 14.20, 40, 'https://covers.openlibrary.org/b/isbn/9789681601638-L.jpg',  132, 'latinoamericana'),
('casa-espiritus',            'La casa de los espíritus',              'Isabel Allende',           '9780525433477', 22.50, 32, 'https://covers.openlibrary.org/b/isbn/9780525433477-L.jpg',  433, 'latinoamericana'),
('ciudad-y-perros',           'La ciudad y los perros',                'Mario Vargas Llosa',       '9788420471839', 19.80, 25, 'https://covers.openlibrary.org/b/isbn/9788420471839-L.jpg',  432, 'latinoamericana'),
('amor-tiempos-colera',       'El amor en los tiempos del cólera',     'Gabriel García Márquez',   '9780307389732', 20.40, 30, 'https://covers.openlibrary.org/b/isbn/9780307389732-L.jpg',  368, 'latinoamericana'),
('detectives-salvajes',       'Los detectives salvajes',               'Roberto Bolaño',           '9788433968630', 24.90, 18, 'https://covers.openlibrary.org/b/isbn/9788433968630-L.jpg',  609, 'latinoamericana'),
('ficciones-borges',          'Ficciones',                             'Jorge Luis Borges',        '9780802130303', 16.80, 22, 'https://covers.openlibrary.org/b/isbn/9780802130303-L.jpg',  174, 'latinoamericana'),
('conversacion-catedral',     'Conversación en La Catedral',           'Mario Vargas Llosa',       '9788420471846', 23.30, 20, 'https://covers.openlibrary.org/b/isbn/9788420471846-L.jpg',  697, 'latinoamericana'),

-- =================== 2) CLÁSICOS MUNDIALES (10) ===================
('don-quijote',               'Don Quijote de la Mancha',              'Miguel de Cervantes',      '9780142437230', 25.00, 40, 'https://covers.openlibrary.org/b/isbn/9780142437230-L.jpg', 1056, 'clasicos'),
('orgullo-prejuicio',         'Orgullo y Prejuicio',                   'Jane Austen',              '9780141439518', 12.80, 45, 'https://covers.openlibrary.org/b/isbn/9780141439518-L.jpg',  432, 'clasicos'),
('crimen-castigo',            'Crimen y Castigo',                      'Fiódor Dostoyevski',       '9780143058144', 19.50, 30, 'https://covers.openlibrary.org/b/isbn/9780143058144-L.jpg',  671, 'clasicos'),
('madame-bovary',             'Madame Bovary',                         'Gustave Flaubert',         '9780140449129', 15.20, 25, 'https://covers.openlibrary.org/b/isbn/9780140449129-L.jpg',  368, 'clasicos'),
('anna-karenina',             'Anna Karenina',                         'Lev Tolstói',              '9780143035008', 22.00, 24, 'https://covers.openlibrary.org/b/isbn/9780143035008-L.jpg',  864, 'clasicos'),
('los-miserables',            'Los Miserables',                        'Victor Hugo',              '9780451419439', 24.50, 28, 'https://covers.openlibrary.org/b/isbn/9780451419439-L.jpg', 1232, 'clasicos'),
('cumbres-borrascosas',       'Cumbres Borrascosas',                   'Emily Brontë',             '9780141439556', 13.90, 22, 'https://covers.openlibrary.org/b/isbn/9780141439556-L.jpg',  416, 'clasicos'),
('montecristo',               'El Conde de Montecristo',               'Alexandre Dumas',          '9780140449266', 21.40, 26, 'https://covers.openlibrary.org/b/isbn/9780140449266-L.jpg', 1276, 'clasicos'),
('guerra-y-paz',              'Guerra y Paz',                          'Lev Tolstói',              '9781400079988', 27.50, 18, 'https://covers.openlibrary.org/b/isbn/9781400079988-L.jpg', 1296, 'clasicos'),
('moby-dick',                 'Moby Dick',                             'Herman Melville',          '9780142437247', 17.60, 30, 'https://covers.openlibrary.org/b/isbn/9780142437247-L.jpg',  720, 'clasicos'),

-- =================== 3) CIENCIA FICCIÓN Y DISTOPÍA (10) ===================
('1984',                      '1984',                                  'George Orwell',            '9780451524935', 16.00, 60, 'https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg',  328, 'ciencia'),
('fahrenheit-451',            'Fahrenheit 451',                        'Ray Bradbury',             '9781451673319', 13.90, 45, 'https://covers.openlibrary.org/b/isbn/9781451673319-L.jpg',  249, 'ciencia'),
('mundo-feliz',               'Un mundo feliz',                        'Aldous Huxley',            '9780060850524', 14.50, 38, 'https://covers.openlibrary.org/b/isbn/9780060850524-L.jpg',  311, 'ciencia'),
('dune',                      'Dune',                                  'Frank Herbert',            '9780441013593', 22.80, 50, 'https://covers.openlibrary.org/b/isbn/9780441013593-L.jpg',  688, 'ciencia'),
('fundacion',                 'Fundación',                             'Isaac Asimov',             '9780553293357', 16.70, 32, 'https://covers.openlibrary.org/b/isbn/9780553293357-L.jpg',  244, 'ciencia'),
('fin-eternidad',             'El fin de la eternidad',                'Isaac Asimov',             '9780765319197', 17.90, 22, 'https://covers.openlibrary.org/b/isbn/9780765319197-L.jpg',  240, 'ciencia'),
('yo-robot',                  'Yo, Robot',                             'Isaac Asimov',             '9780553382563', 15.40, 28, 'https://covers.openlibrary.org/b/isbn/9780553382563-L.jpg',  224, 'ciencia'),
('solaris',                   'Solaris',                               'Stanisław Lem',            '9780156027601', 14.90, 18, 'https://covers.openlibrary.org/b/isbn/9780156027601-L.jpg',  204, 'ciencia'),
('cuento-criada',             'El cuento de la criada',                'Margaret Atwood',          '9780385490818', 18.20, 36, 'https://covers.openlibrary.org/b/isbn/9780385490818-L.jpg',  311, 'ciencia'),
('neuromante',                'Neuromante',                            'William Gibson',           '9780441569595', 17.30, 20, 'https://covers.openlibrary.org/b/isbn/9780441569595-L.jpg',  271, 'ciencia'),

-- =================== 4) TECNOLOGÍA E INGENIERÍA (10) ===================
('clean-code',                'Clean Code',                            'Robert C. Martin',         '9780132350884', 32.00, 40, 'https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg',  464, 'tecnologia'),
('pragmatic-programmer',      'The Pragmatic Programmer',              'Andrew Hunt & David Thomas','9780201616224', 29.90, 35, 'https://covers.openlibrary.org/b/isbn/9780201616224-L.jpg',  352, 'tecnologia'),
('design-patterns',           'Design Patterns',                       'Erich Gamma et al.',       '9780201633610', 38.00, 25, 'https://covers.openlibrary.org/b/isbn/9780201633610-L.jpg',  395, 'tecnologia'),
('intro-algoritmos',          'Introduction to Algorithms (CLRS)',     'Cormen, Leiserson, Rivest, Stein', '9780262033848', 49.50, 18, 'https://covers.openlibrary.org/b/isbn/9780262033848-L.jpg', 1312, 'tecnologia'),
('code-complete',             'Code Complete',                         'Steve McConnell',          '9780735619678', 41.20, 22, 'https://covers.openlibrary.org/b/isbn/9780735619678-L.jpg',  960, 'tecnologia'),
('refactoring',               'Refactoring',                           'Martin Fowler',            '9780134757599', 36.50, 28, 'https://covers.openlibrary.org/b/isbn/9780134757599-L.jpg',  448, 'tecnologia'),
('mythical-man-month',        'The Mythical Man-Month',                'Frederick P. Brooks Jr.',  '9780201835953', 28.40, 16, 'https://covers.openlibrary.org/b/isbn/9780201835953-L.jpg',  322, 'tecnologia'),
('sicp',                      'Structure and Interpretation of Computer Programs', 'Harold Abelson & Gerald Sussman', '9780262510875', 44.90, 14, 'https://covers.openlibrary.org/b/isbn/9780262510875-L.jpg',  657, 'tecnologia'),
('cracking-interview',        'Cracking the Coding Interview',         'Gayle Laakmann McDowell',  '9780984782857', 35.00, 38, 'https://covers.openlibrary.org/b/isbn/9780984782857-L.jpg',  696, 'tecnologia'),
('domain-driven-design',      'Domain-Driven Design',                  'Eric Evans',               '9780321125217', 42.80, 20, 'https://covers.openlibrary.org/b/isbn/9780321125217-L.jpg',  560, 'tecnologia'),

-- =================== 5) HISTORIA Y FILOSOFÍA (10) ===================
('sapiens',                   'Sapiens: De animales a dioses',         'Yuval Noah Harari',        '9780062316097', 22.50, 50, 'https://covers.openlibrary.org/b/isbn/9780062316097-L.jpg',  496, 'historia'),
('la-republica',              'La República',                          'Platón',                   '9788420674063', 14.80, 30, 'https://covers.openlibrary.org/b/isbn/9788420674063-L.jpg',  528, 'historia'),
('zaratustra',                'Así habló Zaratustra',                  'Friedrich Nietzsche',      '9788420651613', 16.40, 24, 'https://covers.openlibrary.org/b/isbn/9780140441185-L.jpg?default=false',  432, 'historia'),
('meditaciones',              'Meditaciones',                          'Marco Aurelio',            '9788420674049', 12.00, 35, 'https://covers.openlibrary.org/b/isbn/9788420674049-L.jpg',  256, 'historia'),
('arte-guerra',               'El arte de la guerra',                  'Sun Tzu',                  '9780486425573',  9.90, 60, 'https://covers.openlibrary.org/b/isbn/9780486425573-L.jpg',  100, 'historia'),
('critica-razon-pura',        'Crítica de la razón pura',              'Immanuel Kant',            '9788430942237', 26.00, 12, 'https://covers.openlibrary.org/b/isbn/9788430942237-L.jpg',  690, 'historia'),
('mundo-sofia',               'El mundo de Sofía',                     'Jostein Gaarder',          '9788478448524', 19.50, 28, 'https://covers.openlibrary.org/b/isbn/9788478448524-L.jpg',  638, 'historia'),
('homo-deus',                 'Homo Deus',                             'Yuval Noah Harari',        '9780062464347', 23.40, 32, 'https://covers.openlibrary.org/b/isbn/9780062464347-L.jpg',  450, 'historia'),
('breve-historia-tiempo',     'Breve historia del tiempo',             'Stephen Hawking',          '9780553380163', 17.80, 22, 'https://covers.openlibrary.org/b/isbn/9780553380163-L.jpg',  256, 'historia'),
('etica-amador',              'Ética para Amador',                     'Fernando Savater',         '9788434453982', 13.20, 30, 'https://covers.openlibrary.org/b/isbn/9788434453982-L.jpg',  192, 'historia'),

-- =================== 6) FANTASÍA Y ÉPICA (10) ===================
('comunidad-anillo',          'La Comunidad del Anillo',               'J.R.R. Tolkien',           '9780547928210', 28.50, 40, 'https://covers.openlibrary.org/b/isbn/9780547928210-L.jpg',  423, 'fantasia'),
('dos-torres',                'Las Dos Torres',                        'J.R.R. Tolkien',           '9780547928203', 26.00, 35, 'https://covers.openlibrary.org/b/isbn/9780547928203-L.jpg',  352, 'fantasia'),
('retorno-rey',               'El Retorno del Rey',                    'J.R.R. Tolkien',           '9780547928197', 27.80, 32, 'https://covers.openlibrary.org/b/isbn/9780547928197-L.jpg',  464, 'fantasia'),
('el-hobbit',                 'El Hobbit',                             'J.R.R. Tolkien',           '9780547928227', 19.90, 50, 'https://covers.openlibrary.org/b/isbn/9780547928227-L.jpg',  310, 'fantasia'),
('harry-potter-1',            'Harry Potter y la Piedra Filosofal',    'J.K. Rowling',             '9788478884452', 19.90, 60, 'https://covers.openlibrary.org/b/isbn/9788478884452-L.jpg',  256, 'fantasia'),
('juego-tronos',              'Juego de Tronos',                       'George R.R. Martin',       '9780553103540', 24.90, 38, 'https://covers.openlibrary.org/b/isbn/9780553103540-L.jpg',  694, 'fantasia'),
('nombre-viento',             'El Nombre del Viento',                  'Patrick Rothfuss',         '9780756404741', 23.50, 28, 'https://covers.openlibrary.org/b/isbn/9780756404741-L.jpg',  662, 'fantasia'),
('cronicas-narnia',           'Las Crónicas de Narnia',                'C.S. Lewis',               '9780066238500', 32.40, 30, 'https://covers.openlibrary.org/b/isbn/9780066238500-L.jpg',  767, 'fantasia'),
('mistborn-imperio-final',    'Mistborn: El Imperio Final',            'Brandon Sanderson',        '9780765311788', 24.20, 24, 'https://covers.openlibrary.org/b/isbn/9780765311788-L.jpg',  657, 'fantasia'),
('buenos-presagios',          'Buenos Presagios',                      'Terry Pratchett & Neil Gaiman', '9780060853983', 18.40, 20, 'https://covers.openlibrary.org/b/isbn/9780060853983-L.jpg',  412, 'fantasia'),

-- =================== 7) BIOGRAFÍAS (10) ===================
('steve-jobs',                'Steve Jobs',                            'Walter Isaacson',          '9781451648539', 27.90, 35, 'https://covers.openlibrary.org/b/isbn/9781451648539-L.jpg',  656, 'biografias'),
('yo-malala',                 'Yo soy Malala',                         'Malala Yousafzai',         '9780316322409', 18.20, 28, 'https://covers.openlibrary.org/b/isbn/9780316322409-L.jpg',  327, 'biografias'),
('largo-camino',              'Un largo camino hacia la libertad',     'Nelson Mandela',           '9780316548182', 25.40, 22, 'https://covers.openlibrary.org/b/isbn/9780316548182-L.jpg',  656, 'biografias'),
('open-agassi',               'Open: Memorias',                        'Andre Agassi',             '9780307268198', 21.30, 24, 'https://covers.openlibrary.org/b/isbn/9780307268198-L.jpg',  400, 'biografias'),
('becoming-michelle',         'Becoming (Mi historia)',                'Michelle Obama',           '9781524763138', 23.90, 30, 'https://covers.openlibrary.org/b/isbn/9781524763138-L.jpg',  448, 'biografias'),
('diario-ana-frank',          'El diario de Ana Frank',                'Ana Frank',                '9788423334346', 14.90, 40, 'https://covers.openlibrary.org/b/isbn/9788423334346-L.jpg',  368, 'biografias'),
('einstein-isaacson',         'Einstein: Su vida y su universo',       'Walter Isaacson',          '9780743264747', 26.70, 18, 'https://covers.openlibrary.org/b/isbn/9780743264747-L.jpg',  675, 'biografias'),
('elon-musk-vance',           'Elon Musk',                             'Ashlee Vance',             '9780062301239', 22.50, 26, 'https://covers.openlibrary.org/b/isbn/9780062301239-L.jpg',  400, 'biografias'),
('autobiografia-franklin',    'Autobiografía de Benjamin Franklin',    'Benjamin Franklin',        '9780300098587', 16.50, 14, 'https://covers.openlibrary.org/b/isbn/9780300098587-L.jpg',  240, 'biografias'),
('aliento-aire',              'Cuando el aliento se vuelve aire',      'Paul Kalanithi',           '9780812988406', 19.90, 16, 'https://covers.openlibrary.org/b/isbn/9780812988406-L.jpg',  256, 'biografias'),

-- =================== 8) DESARROLLO PERSONAL (10) ===================
('habitos-atomicos',          'Hábitos Atómicos',                      'James Clear',              '9780735211292', 19.50, 60, 'https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg',  320, 'desarrollo'),
('7-habitos',                 'Los 7 Hábitos de la Gente Altamente Efectiva', 'Stephen R. Covey',  '9781982137274', 20.90, 45, 'https://covers.openlibrary.org/b/isbn/9781982137274-L.jpg',  432, 'desarrollo'),
('poder-ahora',               'El Poder del Ahora',                    'Eckhart Tolle',            '9781577314806', 16.80, 38, 'https://covers.openlibrary.org/b/isbn/9781577314806-L.jpg',  236, 'desarrollo'),
('pensar-rapido',             'Pensar rápido, pensar despacio',        'Daniel Kahneman',          '9780374533557', 23.90, 30, 'https://covers.openlibrary.org/b/isbn/9780374533557-L.jpg',  499, 'desarrollo'),
('mindset',                   'Mindset: La actitud del éxito',         'Carol S. Dweck',           '9780345472328', 18.60, 32, 'https://covers.openlibrary.org/b/isbn/9780345472328-L.jpg',  320, 'desarrollo'),
('ganar-amigos',              'Cómo ganar amigos e influir sobre las personas', 'Dale Carnegie',  '9780671027032', 14.20, 50, 'https://covers.openlibrary.org/b/isbn/9780671027032-L.jpg',  291, 'desarrollo'),
('monje-ferrari',             'El monje que vendió su Ferrari',        'Robin Sharma',             '9788483460023', 15.40, 28, 'https://covers.openlibrary.org/b/isbn/9788483460023-L.jpg',  208, 'desarrollo'),
('semana-4-horas',            'La semana laboral de 4 horas',          'Timothy Ferriss',          '9780307465351', 21.30, 24, 'https://covers.openlibrary.org/b/isbn/9780307465351-L.jpg',  416, 'desarrollo'),
('inteligencia-emocional',    'Inteligencia Emocional',                'Daniel Goleman',           '9780553804911', 19.80, 26, 'https://covers.openlibrary.org/b/isbn/9780553804911-L.jpg',  384, 'desarrollo'),
('padre-rico',                'Padre Rico, Padre Pobre',               'Robert T. Kiyosaki',       '9781612680194', 17.50, 36, 'https://covers.openlibrary.org/b/isbn/9781612680194-L.jpg',  336, 'desarrollo'),

-- =================== 9) MANGA (10) ===================
('one-piece-1',               'One Piece — Tomo 1',                    'Eiichiro Oda',             '9784088725093',  9.90, 80, 'https://covers.openlibrary.org/b/isbn/9784088725093-L.jpg',  216, 'manga'),
('naruto-1',                  'Naruto — Tomo 1',                       'Masashi Kishimoto',        '9784088725369',  8.90, 70, 'https://covers.openlibrary.org/b/isbn/9781591163589-L.jpg?default=false',  200, 'manga'),
('berserk-1',                 'Berserk — Volumen 1',                   'Kentaro Miura',            '9781593070205', 12.50, 40, 'https://covers.openlibrary.org/b/isbn/9781593070205-L.jpg',  232, 'manga'),
('hajime-ippo-1',             'Hajime no Ippo — Tomo 1',               'George Morikawa',          '9784063340303',  9.50, 30, 'https://covers.openlibrary.org/b/isbn/9781632361424-L.jpg?default=false',  200, 'manga'),
('dragon-ball-1',             'Dragon Ball — Tomo 1',                  'Akira Toriyama',           '9784088722405',  8.90, 65, 'https://covers.openlibrary.org/b/isbn/9781569319208-L.jpg?default=false',  192, 'manga'),
('vagabond-1',                'Vagabond — Volumen 1',                  'Takehiko Inoue',           '9781421520544', 11.50, 28, 'https://covers.openlibrary.org/b/isbn/9781421520544-L.jpg',  200, 'manga'),
('death-note-1',              'Death Note — Volumen 1',                'Tsugumi Ohba & Takeshi Obata', '9781421501680', 10.20, 50, 'https://covers.openlibrary.org/b/isbn/9781421501680-L.jpg', 195, 'manga'),
('attack-titan-1',            'Attack on Titan — Volumen 1',           'Hajime Isayama',           '9781935654513', 10.90, 60, 'https://covers.openlibrary.org/b/isbn/9781935654513-L.jpg',  208, 'manga'),
('bleach-1',                  'Bleach — Volumen 1',                    'Tite Kubo',                '9781591164418',  9.20, 42, 'https://covers.openlibrary.org/b/isbn/9781591164418-L.jpg',  192, 'manga'),
('fullmetal-1',               'Fullmetal Alchemist — Volumen 1',       'Hiromu Arakawa',           '9781591169208', 10.50, 38, 'https://covers.openlibrary.org/b/isbn/9781591169208-L.jpg',  192, 'manga');

-- =====================================================================
-- 8. Pedidos semilla — un par de compras del usuario CLIENTE
--    para que el perfil/admin tengan algo que mostrar de entrada.
-- =====================================================================
WITH cliente AS (
    SELECT id FROM tb_usuario WHERE correo = 'cliente@folio.ec' LIMIT 1
)
INSERT INTO tb_pedido (usuario_id, subtotal, iva, total, estado, marca_tarjeta, ultimos4)
SELECT id, 38.40, 5.76, 44.16, 'PAGADO', 'VISA', '4242' FROM cliente
UNION ALL
SELECT id, 22.50, 3.38, 25.88, 'ENTREGADO', 'MASTERCARD', '5454' FROM cliente;

-- Las dos cabeceras anteriores reciben ids consecutivos. Sus líneas:
WITH p1 AS (
    SELECT id FROM tb_pedido WHERE marca_tarjeta = 'VISA' AND ultimos4 = '4242' LIMIT 1
), p2 AS (
    SELECT id FROM tb_pedido WHERE marca_tarjeta = 'MASTERCARD' AND ultimos4 = '5454' LIMIT 1
)
INSERT INTO tb_pedido_item (pedido_id, libro_id, cantidad, precio_unitario)
SELECT id, 'cien-anios-soledad', 1, 18.90 FROM p1
UNION ALL
SELECT id, 'el-aleph',           1, 15.50 FROM p1
UNION ALL
SELECT id, 'sapiens',            1, 22.50 FROM p2;

-- =====================================================================
-- 9. Hot-fix de portadas — algunas URLs ISBN-based de Open Library
--    no devolvían imagen. Las reemplazamos por URLs estables.
-- =====================================================================
-- Open Library expone su CDN para hotlinking. Con ?default=false devuelve
-- 404 si no hay portada → el <object> en el frontend muestra el fallback
-- dorado en lugar del icono de imagen rota.

UPDATE tb_libro SET imagen = 'https://covers.openlibrary.org/b/isbn/9780140441185-L.jpg?default=false'
 WHERE id = 'zaratustra';

UPDATE tb_libro SET imagen = 'https://covers.openlibrary.org/b/isbn/9781591163589-L.jpg?default=false'
 WHERE id = 'naruto-1';

UPDATE tb_libro SET imagen = 'https://covers.openlibrary.org/b/isbn/9781632361424-L.jpg?default=false'
 WHERE id = 'hajime-ippo-1';

UPDATE tb_libro SET imagen = 'https://covers.openlibrary.org/b/isbn/9781569319208-L.jpg?default=false'
 WHERE id = 'dragon-ball-1';

-- ---------------------------------------------------------------------
-- 10. Verificación rápida (no falla — sólo informa)
-- ---------------------------------------------------------------------
SELECT categoria, COUNT(*) AS total
FROM tb_libro
GROUP BY categoria
ORDER BY categoria;

SELECT rol, COUNT(*) AS cuentas FROM tb_usuario GROUP BY rol;
SELECT COUNT(*) AS pedidos_semilla FROM tb_pedido;
