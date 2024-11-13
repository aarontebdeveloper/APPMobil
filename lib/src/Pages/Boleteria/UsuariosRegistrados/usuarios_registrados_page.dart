import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/rol.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Pages/Boleteria/Menu/boleteria_menu_page.dart';
import 'package:flutter_demo/src/Pages/Boleteria/UsuariosRegistrados/usuarios_registrados_controller.dart';

class UsuariosRegistradosPage extends StatefulWidget {
  @override
  _UsuariosRegistradosPageState createState() =>
      _UsuariosRegistradosPageState();
}

class _UsuariosRegistradosPageState extends State<UsuariosRegistradosPage> {
  final UsuariosRegistradosController _controller =
      UsuariosRegistradosController();
  List<User> _usuarios = [];
  List<User> _usuariosFiltrados = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.init(context);
    _obtenerUsuarios();
    _searchController.addListener(_filtrarUsuarios); // Escucha los cambios en el campo de búsqueda
  }

  Future<void> _obtenerUsuarios() async {
    var respuesta = await _controller.obtenerUsuariosRegistrados();

    setState(() {
      _usuarios = respuesta ?? [];
      _usuariosFiltrados = _usuarios; // Inicializa la lista filtrada con todos los usuarios
      _isLoading = false;
    });
  }

  String _getRole(List<Rol> roles) {
    bool isCliente = roles.any((rol) => rol.id == '1');
    bool isAdministrador = roles.any((rol) => rol.id == '2');

    if (isCliente && isAdministrador) {
      return "Cliente y Administrador";
    } else if (isCliente) {
      return "Cliente";
    } else if (isAdministrador) {
      return "Administrador";
    } else {
      return "No disponible";
    }
  }

  // Filtra la lista de usuarios basado en el texto de búsqueda
  void _filtrarUsuarios() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _usuariosFiltrados = _usuarios
          .where((usuario) =>
              usuario.name!.toLowerCase().contains(query) || // Filtra por nombre
              usuario.cedula!.toLowerCase().contains(query)) // Filtra por cédula
          .toList();
    });
  }

  // Método para modificar el rol de un usuario
  Future<void> _modificarRol(String userId, int roleId, String action) async {
    await _controller.agregarOEliminarRol(userId, roleId, action);
    _obtenerUsuarios();  // Refresca la lista de usuarios después de modificar el rol
  }

  // Determina si se debe mostrar el botón para agregar o eliminar el rol de administrador
  String _getButtonLabel(List<Rol> roles) {
    bool isCliente = roles.any((rol) => rol.id == '1');
    bool isAdministrador = roles.any((rol) => rol.id == '2');

    if (isCliente && isAdministrador) {
      return "Eliminar rol Admin";
    } else if (isCliente) {
      return "Agregar rol Admin";
    } else {
      return "No disponible";
    }
  }

  // Determina el color del botón según la acción
  Color _getButtonColor(List<Rol> roles) {
    return _getButtonLabel(roles) == "Agregar rol Admin"
        ? Colors.green // Verde para agregar rol
        : Colors.red; // Rojo para eliminar rol
  }

  @override
  void dispose() {
    _searchController.dispose(); // Limpia el controlador de búsqueda cuando se destruye el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Usuarios Registrados",
          style: TextStyle(color: Colors.white), // Letras blancas
        ),
        backgroundColor: Colors.blue, // Fondo azul en la barra
        centerTitle: true, // Centra el título
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Icono de flecha hacia atrás blanco
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BoleteriaMenuPage(), // Cambia a BoleteriaMenuPage
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Buscar por nombre o cédula",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _usuariosFiltrados.isEmpty
                  ? Center(child: Text("No hay usuarios registrados."))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _usuariosFiltrados.length,
                        itemBuilder: (context, index) {
                          User user = _usuariosFiltrados[index];
                          return ListTile(
                            leading: Container(
                              width: 100, // Ancho de la imagen en tamaño carnet
                              height: 120, // Alto de la imagen en tamaño carnet
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: user.image != null
                                      ? NetworkImage(user.image!)
                                      : AssetImage('assets/images/default_user.png')
                                          as ImageProvider,
                                  fit: BoxFit.cover, // Asegura que la imagen se ajuste bien al contenedor
                                ),
                              ),
                            ),
                            title: Text('Nombre: ${user.name ?? "No disponible"}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Apellido: ${user.lastname ?? "No disponible"}'),
                                Text('Email: ${user.email ?? "No disponible"}'),
                                Text('Dirección: ${user.direccion ?? "No disponible"}'),
                                Text('Cédula: ${user.cedula ?? "No disponible"}'),
                                Text('Teléfono: ${user.phone ?? "No disponible"}'),
                                Text('Rol: ${_getRole(user.roles)}'), // Asignación del rol
                                // Aquí puedes agregar un botón para modificar el rol
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        String action = _getButtonLabel(user.roles) == "Agregar rol Admin" ? 'add' : 'remove';
                                        _modificarRol(user.id!, 2, action); // 2 es el ID del rol Admin
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, backgroundColor: _getButtonColor(user.roles), // Letras blancas
                                      ),
                                      child: Text(_getButtonLabel(user.roles)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
