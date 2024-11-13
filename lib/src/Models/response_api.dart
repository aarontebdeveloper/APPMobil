import 'dart:convert';
import 'package:flutter/material.dart';

// Funciones para convertir JSON
ResponsiveApi responsiveApiFromJson(String str) => ResponsiveApi.fromJson(json.decode(str));
String responsiveApiToJson(ResponsiveApi data) => json.encode(data.toJson());

// Clase para manejar las respuestas de la API
class ResponsiveApi {
  String message; // Mensaje de la respuesta
  String error; // Mensaje de error, si hay
  bool success; // Indica si la respuesta fue exitosa
  dynamic data; // Campo opcional para datos de respuesta
  int? statusCode; // Código de estado de la respuesta
  String? id; // Campo para el ID de la factura, si aplica

  ResponsiveApi({
    required this.message,
    required this.error,
    required this.success,
    this.data,
    this.statusCode,
    this.id,
  });

  // Constructor para crear una instancia desde JSON
  factory ResponsiveApi.fromJson(Map<String, dynamic> json) {
    return ResponsiveApi(
      message: json["message"] ?? "",
      error: json["error"] ?? "",
      success: json["success"] ?? false,
      data: json["data"],
      statusCode: json["statusCode"],
      id: json["data"] != null ? json["data"]["id"] : null, // Extrae el ID de los datos
    );
  }

  // Método para convertir la instancia a JSON
  Map<String, dynamic> toJson() => {
        "message": message,
        "error": error,
        "success": success,
        "data": data,
        "statusCode": statusCode,
        "id": id,
      };

  // Método para verificar si la respuesta fue exitosa
  bool isSuccess() {
    return success && (statusCode == 200 || statusCode == 201);
  }

  // Método adicional para manejar errores (opcional)
  void handleError(BuildContext context) {
    if (!success) {
      // Aquí puedes mostrar un mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.isNotEmpty ? error : 'Error desconocido')),
      );
    }
  }
}
