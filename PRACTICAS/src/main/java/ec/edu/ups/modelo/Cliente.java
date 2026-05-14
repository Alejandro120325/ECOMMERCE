package ec.edu.ups.modelo;

public class Cliente {
    private String nombre;
    private String cedula;
    private String estadoCivil;
    private String correo;
    private String password;

    public Cliente(String nombre, String cedula, String estadoCivil, String correo, String password) {
        this.nombre = nombre;
        this.cedula = cedula;
        this.estadoCivil = estadoCivil;
        this.correo = correo;
        this.password = password;
    }

    // Getters
    public String getNombre() { return nombre; }
    public String getCedula() { return cedula; }
    public String getEstadoCivil() { return estadoCivil; }
    public String getCorreo() { return correo; }
    public String getPassword() { return password; }
}