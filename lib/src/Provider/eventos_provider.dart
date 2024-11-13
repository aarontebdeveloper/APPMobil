import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/response_api.dart';
import 'package:flutter_demo/src/Models/evento.dart'; // Asegúrate de tener este modelo
import 'package:flutter_demo/src/api/environment.dart';
import 'package:http/http.dart' as http;

class EventoProvider {
  final String _url = Environment.API_APP;
  final String _api = '/api/eventos';
  late BuildContext context;

  Future<void> init(BuildContext context) async {
    this.context = context;
  }

  Future<ResponsiveApi?> createEvento(Evento evento, Uint8List? imageBytes) async {
  try {
    Uri url = Uri.http(_url, '$_api/create');
    Map<String, dynamic> eventoData = evento.toJson();

    // Manejo de la imagen si se proporciona
    if (imageBytes != null) {
      String? imageUrl = await subirImagen(imageBytes); // Cambiado a subirImagen
      eventoData['imagen'] = imageUrl; // Solo se agrega si hay imagen
    }

    // Asegúrate de agregar tipos de boletos al evento
    if (evento.tiposBoletos.isNotEmpty) {
      eventoData['tiposBoletos'] = evento.tiposBoletos.map((tipo) => tipo.toJson()).toList();
    }

    // Imprimir los datos del evento en la consola
    print('Datos del evento enviados al backend: $eventoData');

    String bodyParams = json.encode(eventoData);
    Map<String, String> headers = {'Content-type': 'application/json'};
    final res = await http.post(url, headers: headers, body: bodyParams);
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
    print('Error al crear evento: $e');
    return null;
  }
}


 Future<ResponsiveApi?> updateEvento(
  Evento evento, Uint8List? imageBytes) async {
  try {
    Uri url = Uri.http(
        _url, '$_api/update/${evento.id}'); // Incluye el ID del evento
    Map<String, dynamic> eventoUpdates = evento.toJson();

    // Manejo de la imagen si se proporciona
    if (imageBytes != null && imageBytes.isNotEmpty) {
      String? imageUrl = await subirImagen(imageBytes); // Cambiado a subirImagen
      if (imageUrl != null) {
        eventoUpdates['imagen'] = imageUrl; // Solo se agrega si la imagen se sube correctamente
      } else {
        return ResponsiveApi(
          success: false,
          message: 'Error al subir la imagen',
          error: '',
        );
      }
    }

    // Actualiza la lista de tipos de boletos
    if (evento.tiposBoletos.isNotEmpty) {
      eventoUpdates['tiposBoletos'] =
          evento.tiposBoletos.map((tipo) => tipo.toJson()).toList();
    }

    String bodyParams = json.encode(eventoUpdates);
    Map<String, String> headers = {'Content-type': 'application/json'};

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
    print('Error al actualizar evento: $e');
    return null;
  }
}

  Future<List<Evento>?> getAllEventos() async {
    try {
      Uri url = Uri.http(_url, '$_api/getAll'); // Obtén todos los eventos
      final res = await http.get(url);

      if (res.statusCode == 200) {
        List<dynamic> data = json.decode(res.body);
        return data.map((evento) => Evento.fromJson(evento)).toList();
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener eventos: $e');
      return null;
    }
  }

  Future<ResponsiveApi?> deleteEvento(String id) async {
    try {
      Uri url = Uri.http(_url, '$_api/delete/$id'); // Reemplaza con tu endpoint
      final res = await http.delete(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return ResponsiveApi.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al eliminar evento: $e');
      return null;
    }
  }

  Future<String?> subirImagen(Uint8List imageBytes) async {
    if (imageBytes.isEmpty) {
      print("No se proporcionaron bytes de imagen.");
      return null; // No se puede subir una imagen vacía
    }

    try {
      String fileName =
          'eventos/${DateTime.now().millisecondsSinceEpoch}.png'; // Cambia la extensión según el tipo de imagen

      UploadTask uploadTask =
          FirebaseStorage.instance.ref(fileName).putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask;

      // Obtener la URL de descarga
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl; // Devolver la URL de la imagen
    } catch (e) {
      print('Error al subir la imagen: $e'); // Mensaje de error en consola
      return null; // Devolver null en caso de error
    }
  }
}
