import 'dart:typed_data';
import 'package:flutter_demo/src/Models/evento.dart';
import 'package:flutter_demo/src/Models/response_api.dart';
import 'package:flutter_demo/src/Provider/eventos_provider.dart';

class RegistroEventoController {
  Evento evento = Evento(
    tiposBoletos: [],
    nombre: '',
    fecha: DateTime.now(),
    ubicacion: '',
    descripcion: ''
  );

  final EventoProvider _eventoProvider = EventoProvider();

  void agregarTipoBoleto(String nombreTipo, double precio, int cantidad) {
    if (nombreTipo.isNotEmpty && cantidad > 0) {
      evento.tiposBoletos.add(TipoBoleto(
        nombre_tipo: nombreTipo,
        precio: precio,
        cantidad_disponible: cantidad,
      ));
    } else {
      throw Exception('El nombre y la cantidad deben ser válidos.');
    }
  }
  

  Future<ResponsiveApi?> crearEvento(Uint8List? imageBytes) async {
  // Verifica que tiposBoletos no sea nulo y no esté vacío
  if (evento.tiposBoletos.isEmpty) {
    throw Exception('Debe agregar al menos un tipo de boleto.');
  }

  // Itera sobre los tipos de boletos y verifica la cantidad disponible
  for (var tipo in evento.tiposBoletos) { // Asegúrate de que tiposBoletos no sea nulo al iterar
    if (tipo.cantidad_disponible <= 0) {
      throw Exception('La cantidad debe ser mayor que cero para el tipo: ${tipo.nombre_tipo}'); // Manejo de nulos
    }
  }
    // Loguear los datos antes de enviar
    print('Datos del evento antes de enviar: ${evento.toJson()}');
    
    return await _eventoProvider.createEvento(evento, imageBytes);
  }

  void reset() {
    evento = Evento(
      tiposBoletos: [],
      nombre: '',
      fecha: DateTime.now(),
      ubicacion: '',
      descripcion: ''
    );
  }
}
