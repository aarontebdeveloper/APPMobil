import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Models/evento.dart';
import 'package:flutter_demo/src/Provider/facturacion_provider.dart';
import 'package:flutter_demo/src/utils/shared_pref.dart';

class DetalleFacturacionController {
  late BuildContext context;
  late SharedPref _sharedPref;
  User? user; 
  Evento? evento;
  final FacturaProvider _facturaProvider = FacturaProvider();

  Future<void> init(BuildContext context, Evento evento) async {
    this.context = context;
    this.evento = evento;
    _sharedPref = SharedPref();
    await getUserData(); 
    await _facturaProvider.init(context, user!, evento); 
  }
  
  Future<void> getUserData() async {
    final userData = await _sharedPref.read('user');
    if (userData != null) {
      user = User.fromJson(userData);
    } else {
      print('No se encontró información del usuario en SharedPreferences');
    }
  }
  Future<void> _mostrarDialogo(String mensaje, bool esExito) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              Icon(
                esExito ? Icons.check_circle : Icons.error,
                color: esExito ? Colors.greenAccent : Colors.red,
                size: 40,
              ),
              SizedBox(width: 10),
              Expanded(child: Text(mensaje)),
            ],
          ),
        );
      },
    );

    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
  }
}
