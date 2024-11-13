import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Provider/rol_provider.dart';
import 'package:flutter_demo/src/Provider/users_provider.dart';

class UsuariosRegistradosController {
  final UsersProvider _usersProvider = UsersProvider();
  final RoleProvider _roleProvider = RoleProvider();
  late BuildContext context;

  // Inicialización del controlador
  Future<void> init(BuildContext context) async {
    this.context = context;
    try {
      await _usersProvider.init(context); // Inicialización del provider de usuarios
    } catch (e) {
      print('Error al inicializar los proveedores: $e');
    }
  }

  // Método para obtener todos los usuarios registrados
  Future<List<User>?> obtenerUsuariosRegistrados() async {
    try {
      // Llamar al método del provider para obtener la lista de usuarios
      List<User>? usuarios = await _usersProvider.getAllUsers();

      if (usuarios != null) {
        print("Usuarios obtenidos: ${usuarios.length}");
        return usuarios;
      } else {
        print("No se encontraron usuarios.");
        return null;
      }
    } catch (e) {
      print("Error al obtener los usuarios: $e");
      return null; // Retorna null si ocurre un error
    }
  }

  // Método para agregar o eliminar un rol a un usuario
  Future<void> agregarOEliminarRol(String userId, int roleId, String action) async {
    try {
      // Verificar que el userId sea numérico antes de convertirlo
      int userIdParsed = int.tryParse(userId) ?? -1;
      if (userIdParsed == -1) {
        print('Error: el ID de usuario no es válido.');
        return;
      }

      // Llamar al provider para agregar o eliminar el rol
      await _roleProvider.addOrRemoveRole(userIdParsed, roleId, action);
    } catch (e) {
      print('Error al modificar el rol: $e');
    }
  }
}
