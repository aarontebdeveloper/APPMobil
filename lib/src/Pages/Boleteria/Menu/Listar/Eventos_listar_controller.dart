import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/evento.dart';
import 'package:flutter_demo/src/Models/response_api.dart';
import 'package:flutter_demo/src/Provider/eventos_provider.dart';

class ListarEventoController {
  final EventoProvider eventoProvider = EventoProvider();
  List<Evento> eventos = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> init(BuildContext context) async {
    await eventoProvider.init(context);
    await fetchEventos();
  }

  Future<void> fetchEventos() async {
    try {
      isLoading = true;
      eventos = await eventoProvider.getAllEventos() ?? [];
    } catch (e) {
      errorMessage = 'Error al cargar eventos: $e';
      print(errorMessage);
    } finally {
      isLoading = false;
    }
  }

  Future<ResponsiveApi?> deleteEvento(String id) async {
    ResponsiveApi? response = await eventoProvider.deleteEvento(id);
    if (response != null && response.success) {
      // Si la eliminación es exitosa, actualiza la lista de eventos
      eventos.removeWhere((evento) => evento.id == id);
    }
    return response;
  }
  Future<ResponsiveApi?> updateEvento(
      Evento evento, Uint8List? imageBytes) async {
    return await eventoProvider.updateEvento(evento, imageBytes);
  }
}
