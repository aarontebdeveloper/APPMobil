import 'dart:convert'; // Asegúrate de que esta línea esté presente
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Pages/roles/roles_page.dart';
import 'package:flutter_demo/src/utils/shared_pref.dart';

class ClienteMenuController {
  late BuildContext context;
  final SharedPref _sharedPref = SharedPref();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  
  User? user; 

  Future<void> init(BuildContext context) async {
    this.context = context;
    await refresh(); // Llama a refresh en la inicialización
  }

Future<void> refresh() async {
  try {
    final userData = await _sharedPref.read("user");

    if (userData != null) {
      if (userData is String) {
        // Si userData es un String, decodifícalo
        user = User.fromJson(json.decode(userData));
      } else if (userData is Map<String, dynamic>) {
        // Si userData es un Map, conviértelo directamente
        user = User.fromJson(userData);
      }
    } else {
      user = null; // Si no hay datos, establece user como nulo
    }

    print("User refreshed: $user");
  } catch (e) {
    print("Error al refrescar usuario: $e");
  }
}
  Future<void> logout() async {
    // Elimina los datos del usuario del almacenamiento compartido
    await _sharedPref.remove("user");
    
    // Navegar a la pantalla de inicio de sesión sin poder volver atrás
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed('login'); 

    // Puedes mostrar un mensaje de confirmación
    print("La sesión se cerró con éxito");
  }

  void openclean() {
    // Redirige a RolesPage y elimina todas las rutas anteriores
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RolesPage()),
      (route) => false,
    );
  }
}
