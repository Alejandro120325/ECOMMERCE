package ec.edu.ups.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * FOLIO - Punto único de conexión a PostgreSQL.
 * <p>
 * Configurada explícitamente para que <strong>cliente y servidor
 * intercambien siempre en UTF-8</strong> mediante el parámetro
 * {@code client_encoding=UTF8} y los properties {@code characterEncoding}
 * y {@code allowEncodingChanges}. Esto evita que las tildes y eñes se
 * corrompan al viajar Java &lt;-&gt; PostgreSQL.
 */
public class Conexion {

    private static final String URL =
            "jdbc:postgresql://localhost:5432/folio_biblioteca";
    private static final String USER     = "postgres";
    private static final String PASSWORD = "root";

    private static final Properties PROPS = new Properties();
    static {
        PROPS.setProperty("user",                 USER);
        PROPS.setProperty("password",             PASSWORD);
        PROPS.setProperty("characterEncoding",    "UTF-8");
        PROPS.setProperty("client_encoding",      "UTF8");
        PROPS.setProperty("allowEncodingChanges", "true");
        PROPS.setProperty("useUnicode",           "true");
    }

    public static Connection getConnection() {
        try {
            Class.forName("org.postgresql.Driver");
            return DriverManager.getConnection(URL, PROPS);
        } catch (ClassNotFoundException | SQLException e) {
            System.err.println("Error de conexión: " + e.getMessage());
            return null;
        }
    }
}
