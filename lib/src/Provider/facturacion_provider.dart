import 'dart:convert'; // Para convertir a JSON
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/evento.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Models/factura.dart'; // Importa tu modelo de Factura
import 'package:flutter_demo/src/api/environment.dart';
import 'package:http/http.dart' as http;

class FacturaProvider {
  final String _url = Environment.API_APP;
  final String _api = '/api/facturas';
  late BuildContext context;
  late User user; 
  late Evento evento; 

  Future<void> init(BuildContext context, User user, Evento evento) async {
    this.context = context;
    this.user = user;
    this.evento = evento;
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-type': 'application/json',
      // Agrega aquí cualquier otro encabezado que necesites
    };
  }

  Future<bool> crearFactura(Factura factura) async {
    final response = await http.post(
      Uri.parse('$_url$_api'),
      headers: _getHeaders(),
      body: json.encode(factura.toJson()), // Convierte la factura a JSON
    );

    if (response.statusCode == 201) {
      // Factura creada exitosamente
      return true;
    } else {
      // Manejo de errores
      print('Error al crear la factura: ${response.body}');
      return false;
    }
  }
}
