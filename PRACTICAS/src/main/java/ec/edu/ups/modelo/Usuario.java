package ec.edu.ups.modelo;

public class Usuario {
    private int id;
    private String nombre;
    private String apellido;
    private String cedula;
    private String fechaNacimiento;
    private String estadoCivil;
    private String genero;
    private String provincia;
    private String ciudad;
    private String direccion;
    private String telefono;
    private String correo;
    private String clave;
    private String fotoPerfil;
    private String rol;          // ADMIN / EMPLEADO / CLIENTE
    private boolean activo = true; // false => cuenta suspendida

    public Usuario() {}

    // Constructor que usas en el Servlet
    public Usuario(String nombre, String apellido, String cedula, String fechaNacimiento, String estadoCivil,
                   String genero, String provincia, String ciudad, String direccion, String telefono,
                   String correo, String clave, String fotoPerfil) {
        this.nombre = nombre;
        this.apellido = apellido;
        this.cedula = cedula;
        this.fechaNacimiento = fechaNacimiento;
        this.estadoCivil = estadoCivil;
        this.genero = genero;
        this.provincia = provincia;
        this.ciudad = ciudad;
        this.direccion = direccion;
        this.telefono = telefono;
        this.correo = correo;
        this.clave = clave;
        this.fotoPerfil = fotoPerfil;
    }

    // --- GETTERS ---
    public int getId() { return id; }
    public String getNombre() { return nombre; }
    public String getApellido() { return apellido; }
    public String getCedula() { return cedula; }
    public String getFechaNacimiento() { return fechaNacimiento; }
    public String getEstadoCivil() { return estadoCivil; }
    public String getGenero() { return genero; }
    public String getProvincia() { return provincia; }
    public String getCiudad() { return ciudad; }
    public String getDireccion() { return direccion; }
    public String getTelefono() { return telefono; }
    public String getCorreo() { return correo; }
    public String getClave() { return clave; }
    public String getFotoPerfil() { return fotoPerfil; }
    public String getRol() { return rol; }
    public boolean isActivo() { return activo; }

    // --- SETTERS ---
    public void setId(int id) { this.id = id; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public void setApellido(String apellido) { this.apellido = apellido; }
    public void setCedula(String cedula) { this.cedula = cedula; }
    public void setFechaNacimiento(String fechaNacimiento) { this.fechaNacimiento = fechaNacimiento; }
    public void setEstadoCivil(String estadoCivil) { this.estadoCivil = estadoCivil; }
    public void setGenero(String genero) { this.genero = genero; }
    public void setProvincia(String provincia) { this.provincia = provincia; }
    public void setCiudad(String ciudad) { this.ciudad = ciudad; }
    public void setDireccion(String direccion) { this.direccion = direccion; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    public void setCorreo(String correo) { this.correo = correo; }
    public void setClave(String clave) { this.clave = clave; }
    public void setFotoPerfil(String fotoPerfil) { this.fotoPerfil = fotoPerfil; }
    public void setRol(String rol) { this.rol = rol; }
    public void setActivo(boolean activo) { this.activo = activo; }
}