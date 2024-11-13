
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/evento.dart';
import 'package:flutter_demo/src/Provider/eventos_provider.dart';

class ListarEventoClienteController {
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
}
