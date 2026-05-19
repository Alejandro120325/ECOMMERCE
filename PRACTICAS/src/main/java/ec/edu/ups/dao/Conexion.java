package ec.edu.ups.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class Conexion {

    // 1. URL usando el host de AWS, el puerto 6543 del Pooler y el SSL obligatorio
    private static final String URL =
            "jdbc:postgresql://aws-1-us-east-1.pooler.supabase.com:6543/postgres?sslmode=require";

    // 2. IMPORTANTE: El usuario ahora incluye el identificador de tu proyecto de Supabase
    private static final String USER     = "postgres.ybyfjuskywyauoefjoys";
    private static final String PASSWORD = "Alejo1203251809";

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