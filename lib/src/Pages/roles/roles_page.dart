import 'package:flutter/material.dart';
import 'roles_controller.dart'; // Asegúrate de importar el controlador

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo azul marino
      appBar: AppBar(
        title: const Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 30,
            color: Color.fromARGB(255, 4, 72, 127),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 239, 242),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Título
                const Text(
                  'Selecciona un Rol',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 5, 76, 135),
                  ),
                ),
                const SizedBox(height: 40),

                // Tarjeta de selección de rol
                Card(
                  color: Colors.blue, // Color de la tarjeta
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Rol de Cliente
                        RoleCard(
                          roleName: 'Cliente',
                          imageUrl:
                              'https://cdn-icons-png.flaticon.com/512/4814/4814852.png',
                          onTap: () {
                            // Navegar al controlador con rol de 'cliente'
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RolesController(role: 'cliente'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Rol de Boletería
                        RoleCard(
                          roleName: 'Boletería',
                          imageUrl:
                              'https://static.vecteezy.com/system/resources/thumbnails/012/027/723/small_2x/admit-one-ticket-icon-black-and-white-isolated-wite-free-vector.jpg',
                          onTap: () {
                            // Navegar al controlador con rol de 'boleteria'
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RolesController(role: 'boleteria'),
                              ),
                            );
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
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String roleName;
  final String imageUrl;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.roleName,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              imageUrl,
              width: 100,
              height: 100,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return const Icon(Icons.error);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                roleName,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
