import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Pages/Boleteria/Menu/boleteria_menu_page.dart';
import 'package:flutter_demo/src/Pages/Cliente/Menu/cliente_menu_page.dart';

class RolesController extends StatelessWidget {
  final String role;

  const RolesController({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Navegar según el rol seleccionado
    if (role == 'cliente') {
      return ClienteMenuPage();
    } else if (role == 'boleteria') {
      return const BoleteriaMenuPage();
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Rol no reconocido')),
      );
    }
  }
}
