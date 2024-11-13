import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Pages/roles/roles_page.dart';
import 'package:flutter_demo/src/utils/shared_pref.dart';

class BoleteriaMenuController  {
  late BuildContext context;
  final SharedPref _sharedPref = SharedPref();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  User? user; // Cambiado a User? para manejar el caso donde aún no está cargado.

  Future<void> init(BuildContext context) async {
    this.context = context;
    await refresh(); // Llama a refresh en la inicialización
  }

  Future<void> refresh() async {
    // Leer los datos del usuario
    final userData = await _sharedPref.read("user");

    // Verifica si los datos leídos no son nulos
    if (userData != null) {
      if (userData is String) { // Asegúrate de que userData sea una cadena JSON
        user = User.fromJson(json.decode(userData)); // Decodifica la cadena JSON
      } else if (userData is Map) { // Si es un mapa, conviértelo a Map<String, dynamic>
        user = User.fromJson(Map<String, dynamic>.from(userData));
      }
    } else {
      user = null; // Si no hay datos, establece user en null
    }

    // Aquí podrías agregar cualquier otra lógica que necesites después de refrescar
    print("User refreshed: $user");
  }

  Future<void> logout() async {
    // Elimina los datos del usuario del almacenamiento compartido
    await _sharedPref.remove("user");
    
    // Opcional: Navegar a la pantalla de inicio de sesión
    // Esto asume que tienes un método de navegación configurado
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed('login'); 

    // Puedes mostrar un mensaje de confirmación
    print("Logout successful");
  }
  void openclean() {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const RolesPage()),
    (route) => false,
  );
}
}