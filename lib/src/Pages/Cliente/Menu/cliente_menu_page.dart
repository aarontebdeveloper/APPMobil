import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Pages/Cliente/Menu/cliente_menu_controller.dart';
import 'package:flutter_demo/src/Pages/cliente/Editar/cliente_update_page.dart';

class ClienteMenuPage extends StatefulWidget {
  const ClienteMenuPage({super.key});

  @override
  _ClienteMenuPageState createState() => _ClienteMenuPageState();
}

class _ClienteMenuPageState extends State<ClienteMenuPage> {
  final ClienteMenuController _con = ClienteMenuController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() async {
    await _con.init(context);
    setState(() {
      _isLoading = false; // Indica que la carga ha terminado
    });
  }

  // Método para actualizar los datos
  void _updateUser() async {
    await _con.refresh();  // Refresca los datos de usuario después de actualizar
    setState(() {
      // Vuelve a actualizar el estado para reflejar los cambios
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      appBar: AppBar(
        title: Text(
          'MENU', // Título "MENU"
          style: TextStyle(
            color: const Color.fromARGB(255, 4, 68, 122), // Letras verdes
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Centra el título en el AppBar
        backgroundColor: Colors.white, // Fondo blanco para el AppBar
        elevation: 0,
      ),
      drawer: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _drawer(), // Mostrar el drawer cuando no se está cargando
      body: Container(
        color: Colors.white, // Fondo blanco
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Center( // Centra el contenido en la pantalla
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
                  children: [
                    const SizedBox(height: 10), // Espacio entre la imagen y el texto
                    Text(
                      'Bienvenido, ${_con.user?.name ?? ''} ${_con.user?.lastname ?? ''}', // Título con nombre
                      style: TextStyle(
                        color: const Color.fromARGB(255, 6, 73, 128), // Letras verdes
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40), // Espacio entre el título y los íconos
                    Card(
                      margin: const EdgeInsets.all(16.0),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.event, size: 40), // Icono de eventos
                              title: const Center(child: Text('Ver Eventos')), // Centra el texto
                              onTap: () {
                                Navigator.pushNamed(context, 'cliente/listarEvento'); // Navegar a la página de eventos
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.shopping_cart, size: 40), // Icono de compras
                              title: const Center(child: Text('Mis Compras')), // Centra el texto
                              onTap: () {
                                Navigator.pushNamed(context, 'client/orders/list'); // Navegar a la página de mis compras
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.person, size: 40), // Icono de perfil
                              title: const Center(child: Text('Editar Perfil')), // Centra el texto
                              onTap: () {
                                if (_con.user != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClienteUpdatePage(user: _con.user!), // Pasa el usuario aquí
                                    ),
                                  ).then((_) {
                                    _updateUser(); // Refresca los datos después de editar
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('No se pudo cargar el usuario')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: Container(
        color: Colors.white, // Cambia el color de fondo del drawer a blanco
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                'Hola, ${_con.user?.name ?? ''} ${_con.user?.lastname ?? ''}', // Mostrar saludo con nombre y apellido
              ),
              accountEmail: Text(_con.user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _con.user?.image != null
                    ? NetworkImage(_con.user!.image!)
                    : const AssetImage('assets/img/default_user.png') as ImageProvider,
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 6, 66, 116), // Color de fondo para el encabezado
              ),
            ),
            if ((_con.user?.roles.length ?? 0) > 1)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Seleccionar Rol'),
                onTap: _con.openclean,
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                _con.logout(); 
              },
            ),
          ],
        ),
      ),
    );
  }
}
