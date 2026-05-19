package ec.edu.ups.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class Conexion {

    // Se agrega '?sslmode=require' al final de la URL para cumplir con la seguridad de Supabase
    private static final String URL =
            "jdbc:postgresql://db.ybyfjuskywyauoefjoys.supabase.co:5432/postgres?sslmode=require";
    private static final String USER     = "postgres";
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