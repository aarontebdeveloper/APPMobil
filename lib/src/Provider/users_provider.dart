import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/response_api.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/api/environment.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsersProvider {
  final String _url = Environment.API_APP;
  final String _api = '/api/users';
  late BuildContext context;

  Future<void> init(BuildContext context) async {
    this.context = context;
  }

 Future<List<User>?> getAllUsers() async {
    try {
      Uri url = Uri.http(_url, '$_api/getAll');
      Map<String, String> headers = {'Content-type': 'application/json'};
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);

      // Verificamos si la solicitud fue exitosa
      if (res.statusCode == 200 || res.statusCode == 201) {
        // Convertimos la lista de usuarios en objetos User
        List<User> users = List<User>.from(data.map((userData) => User.fromJson(userData)));
        return users;
      } else {
        print('Error al obtener usuarios: ${data['message']}');
        return null;
      }
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return null;
    }
  }

  Future<ResponsiveApi?> createWithImage(User user, Uint8List uint8list) async {
    try {
      Uri url = Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(user.toJson());
      Map<String, String> headers = {'Content-type': 'application/json'};

      final res = await http.post(url, headers: headers, body: bodyParams);
      print('Datos enviados: $bodyParams'); // <-- Añade esta línea para depurar
      final data = json.decode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ResponsiveApi.fromJson(data);
      } else {
        return ResponsiveApi(
            success: false,
            message: data['message'] ?? 'Error desconocido',
            error: '');
      }
    } catch (e) {
      print('Error al crear usuario: $e');
      return null;
    }
  }

  Future<ResponsiveApi?> create(User user, String name) async {
    try {
      // Primero, verifica si el correo electrónico ya existe
      Uri checkEmailUrl = Uri.http(_url, '$_api/checkEmail');
      String emailBodyParams = json.encode({'email': user.email});
      Map<String, String> headers = {'Content-type': 'application/json'};

      final emailCheckResponse = await http.post(checkEmailUrl,
          headers: headers, body: emailBodyParams);
      final emailCheckData = json.decode(emailCheckResponse.body);

      // Verifica si el correo electrónico ya está en uso
      if (emailCheckData['exists']) {
        print('El correo electrónico ya está en uso.');
        return null; // O lanza una excepción o retorna un mensaje específico
      }

      // Si el correo no existe, procede a crear el usuario
      Uri url = Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(user.toJson());
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponsiveApi responseApi = ResponsiveApi.fromJson(data);
      return responseApi;
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
      return null;
    }
  }

  Future<ResponsiveApi?> login(String email, String password) async {
    return await _sendRequest('$_api/login', {
      "email": email,
      "password": password,
    });
  }

  Future<ResponsiveApi?> _sendRequest(
      String endpoint, Map<String, dynamic> body) async {
    try {
      Uri url = Uri.http(_url, endpoint);
      String bodyParams = json.encode(body);
      Map<String, String> headers = {'Content-type': 'application/json'};

      final res = await http.post(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ResponsiveApi.fromJson(data);
      } else {
        return ResponsiveApi(
          success: false,
          message: data['message'] ?? 'Error en la solicitud',
          error: '',
        );
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<ResponsiveApi?> update(User user, Uint8List? imageBytes) async {
    try {
      Uri url = Uri.http(
          _url, '$_api/update/${user.id}'); // Incluye el ID del usuario
      Map<String, dynamic> userUpdates = user.toJson();

      // Manejo de la imagen si se proporciona
      if (imageBytes != null) {
        // Aquí se obtiene la URL real de Firebase
        String imageUrl = await uploadImageToFirebase(imageBytes, user.id!);
        userUpdates['image'] = imageUrl; // Solo se agrega si hay imagen
      }

      String bodyParams = json.encode(userUpdates);
      Map<String, String> headers = {
        'Content-type': 'application/json',
      };

      final res = await http.put(url, headers: headers, body: bodyParams);
      final data = json.decode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return ResponsiveApi.fromJson(data);
      } else {
        return ResponsiveApi(
          success: false,
          message: data['message'] ?? 'Error desconocido',
          error: '',
        );
      }
    } catch (e) {
      print('Error al actualizar usuario: $e');
      return ResponsiveApi(
        success: false,
        message: 'Error en la conexión',
        error: e.toString(),
      );
    }
  }

  Future<String> uploadImageToFirebase(
      Uint8List imageBytes, String userId) async {
    try {
      // Crear una referencia en Firebase Storage utilizando el ID del usuario
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/$userId.png');

      // Subir la imagen
      UploadTask uploadTask = storageRef.putData(imageBytes);

      // Esperar a que la tarea de subida finalice
      TaskSnapshot snapshot = await uploadTask;

      // Obtener la URL de descarga de la imagen
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl; // Retorna la URL que Firebase proporciona
    } catch (e) {
      print('Error al subir la imagen: $e');
      throw Exception('Error al subir la imagen');
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Elimina el token de sesión y la información del usuario
    await prefs.remove('user'); // Elimina el usuario almacenado
    Navigator.of(context).pushReplacementNamed('login');
  }

  // Método para obtener el correo electrónico actual del usuario
 Future<User?> getCurrentUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');  // Obtén el JSON del usuario almacenado

  if (userJson != null) {
    User user = User.fromJson(json.decode(userJson));  // Deserializa el JSON a un objeto User
    return user;  // Retorna el objeto completo de usuario
  }
  return null;  // Si no hay un usuario guardado, retorna null
}
}
