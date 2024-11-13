import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/response_api.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Provider/users_provider.dart';
import 'package:flutter_demo/src/utils/shared_pref.dart';
import 'package:flutter_demo/src/utils/messages.dart'; // Importa el archivo de mensajes
import 'package:connectivity_plus/connectivity_plus.dart'; // Asegúrate de tener esta dependencia

class LoginController {
  late BuildContext context;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UsersProvider usersProvider = UsersProvider();

  final SharedPref _sharedPref = SharedPref();

  Future<void> init(BuildContext context) async {
    this.context = context;
    await usersProvider.init(context);
  }

  void goToRegistroPage() {
    Navigator.pushNamed(context, 'registro');
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Verificar la conexión a Internet
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showMessageDialog(Messages.noInternetConnection); // Mensaje si no hay conexión
      return;
    }

    // Mostrar el diálogo de carga
    // ignore: unused_local_variable
    var loadingDialog = _showLoadingDialog();

    // Llamar al método de inicio de sesión
    ResponsiveApi? responsiveApi = await usersProvider.login(email, password);

    // Cerrar el diálogo de carga
    Navigator.of(context).pop();

    if (responsiveApi == null) {
      _showMessageDialog(Messages.genericError); // Mensaje genérico si no hay respuesta
    } else if (responsiveApi.success) {
      User user = User.fromJson(responsiveApi.data);
      _sharedPref.save('user', user.toJson());

      print('Usuario Logueado: ${user.toJson()}');
      if (user.roles.length > 1) {
        Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, user.roles[0].route, (route) => false);
      }
    } else {
      String errorMessage = _mapErrorMessage(responsiveApi.message);
      _showMessageDialog(errorMessage); // Muestra el mensaje de error mapeado
    }
  }

  Future<void> _showMessageDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(color: Colors.red), // Solo color rojo para los errores
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLoadingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Iniciando sesión...')),
            ],
          ),
        );
      },
    );
  }

  String _mapErrorMessage(String message) {
    switch (message) {
      case 'El email no fue encontrado, registrese':
        return Messages.userNotFound;
      case 'Contraseña incorrecta':
        return Messages.incorrectPassword;
      default:
        return Messages.genericError;
    }
  }
}
