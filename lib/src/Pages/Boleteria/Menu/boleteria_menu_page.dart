import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Pages/boleteria/Menu/boleteria_menu_controller.dart';
import 'package:flutter_demo/src/Pages/cliente/Editar/cliente_update_page.dart'; // Asegúrate de que esta importación sea correcta

class BoleteriaMenuPage extends StatefulWidget { 
  const BoleteriaMenuPage({super.key}); 

  @override
  State<BoleteriaMenuPage> createState() => _BoleteriaMenuPageState(); 
}

class _BoleteriaMenuPageState extends State<BoleteriaMenuPage> { 
  final BoleteriaMenuController _con = BoleteriaMenuController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.key,
      appBar: AppBar(
        title: Text(
          'MENU', // Título "MENU"
          style: TextStyle(
            color: Colors.blue, // Letras verdes
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
                    CircleAvatar(
                      radius: 50, // Tamaño del círculo
                      backgroundImage: _con.user?.image != null
                          ? NetworkImage(_con.user!.image!) // Muestra la imagen del usuario si existe
                          : const AssetImage('assets/img/default_user.png') as ImageProvider,
                    ),
                    const SizedBox(height: 10), // Espacio entre la imagen y el texto
                    Text(
                      'Bienvenido, ${_con.user?.name ?? ''} ${_con.user?.lastname ?? ''}', // Título con nombre
                      style: TextStyle(
                        color: Colors.blue, // Letras verdes
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
                              leading: const Icon(Icons.event, size: 40), // Tamaño del ícono
                              title: const Center(child: Text('Registrar Evento')), // Centra el texto
                              onTap: () {
                                // Navegar a la página de registrar evento
                                Navigator.pushNamed(context, 'boleteria/RegistrarEvento');
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.calendar_today, size: 40), // Tamaño del ícono
                              title: const Center(child: Text('Ver Eventos Programados')), // Centra el texto
                              onTap: () {
                                // Navegar a la página de eventos programados
                                Navigator.pushNamed(context, 'boleteria/listaEvento');
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.event_busy, size: 40), // Tamaño del ícono
                              title: const Center(child: Text('Ver Eventos Expirados')), // Centra el texto
                              onTap: () {
                                // Navegar a la página de eventos expirados
                                Navigator.pushNamed(context, 'expired/events');
                              },
                            ),
                             ListTile(
                              leading: const Icon(Icons.person, size: 40), // Tamaño del ícono
                              title: const Center(child: Text('Usuarios Registrados')), // Centra el texto
                              onTap: () {
                                // Navegar a la página de eventos expirados
                                Navigator.pushNamed(context, 'boleteria/usuariosRegistrados');
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
                  'Hola, ${_con.user?.name ?? ''} ${_con.user?.lastname ?? ''}'), // Mostrar saludo con nombre y apellido
              accountEmail: Text(_con.user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _con.user?.image != null
                    ? NetworkImage(_con.user!.image!)
                    : const AssetImage('assets/img/default_user.png')
                        as ImageProvider,
              ),
              decoration: BoxDecoration(
                color: Colors.greenAccent, // Color de fondo para el encabezado
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text('Teléfono: ${_con.user?.phone ?? ''}'),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Perfil'),
              onTap: () {
                // Verifica que _con.user no sea nulo
                if (_con.user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClienteUpdatePage(
                          user: _con.user!), // Pasa el usuario aquí
                    ),
                  );
                } else {
                  // Maneja el caso en que el usuario es nulo, tal vez mostrando un mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo cargar el usuario')),
                  );
                }
              },
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
                _con.logout(); // Llama al método de cierre de sesión
              },
            ),
          ],
        ),
      ),
    );
  }
}
