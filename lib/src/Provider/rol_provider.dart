import 'package:flutter_demo/src/api/environment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoleProvider {
  final String baseUrl = 'http://${Environment.API_APP}'; // Utiliza la URL de la clase Environment

  // Método para agregar o eliminar un rol
  Future<void> addOrRemoveRole(int userId, int roleId, String action) async {
    final url = Uri.parse('$baseUrl/users/roles');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_user': userId,
          'id_rol': roleId,
          'action': action,
        }),
      );

      // Verificar el estado de la respuesta
      if (response.statusCode == 200) {
        // Si la respuesta es exitosa
        print('Rol actualizado exitosamente');
      } else {
        // Si hay un error con la solicitud
        print('Error al actualizar el rol: ${response.statusCode} - ${response.body}');
        throw Exception('Error al actualizar el rol: ${response.body}');
      }
    } catch (e) {
      // Si ocurre un error con la solicitud
      print('Error al hacer la solicitud: $e');
      throw Exception('Error al hacer la solicitud: $e');
    }
  }
}
