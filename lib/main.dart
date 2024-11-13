import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_demo/src/Pages/Boleteria/UsuariosRegistrados/usuarios_registrados_page.dart';
import 'firebase_options.dart';
import 'package:flutter_demo/src/Pages/Splash/splash.dart';
import 'package:flutter_demo/src/Pages/Login/login_page.dart';
import 'package:flutter_demo/src/Pages/roles/roles_page.dart';
import 'package:flutter_demo/src/Pages/Cliente/Menu/cliente_menu_page.dart';
import 'package:flutter_demo/src/Pages/Boleteria/Menu/boleteria_menu_page.dart';
import 'package:flutter_demo/src/Pages/Boleteria/Menu/Listar/Eventos_listar_page.dart';
import 'package:flutter_demo/src/Pages/Cliente/ListaEventos/lista_evento_cliente.dart';
import 'package:flutter_demo/src/Pages/Facturacion/DetalleFactura/Detalle_Factura_page.dart';
import 'package:flutter_demo/src/Pages/Cliente/Registro/registro_page.dart';
import 'package:flutter_demo/src/Models/evento.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'src/Pages/Boleteria/Menu/Registrar Evento/Registrar_Evento_Page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase
  try {
    await Firebase.initializeApp(options: currentPlatform);
  } catch (e) {
    print("Error inicializando Firebase: $e");
    return; // Manejo de errores en la inicialización de Firebase
  }

  runApp(const MyApp());
}

User? currentUser; 
Evento? currentEvento;

class Routes {
  static const String splash = "splash";
  static const String login = "login";
  static const String registro = "registro";
  static const String roles = "roles";
  static const String clienteMenu = "cliente/menu";
  static const String boleteriaMenu = "boleteria/menu";
  static const String boleteriaListaEvento = "boleteria/listaEvento";
  static const String registroEvento = "boleteria/RegistrarEvento";
  static const String clienteListaEvento = "cliente/listarEvento";
  static const String clienteDetalleFactura = "cliente/DetalleFactura";
  static const String UsuariosRegistrados = "boleteria/usuariosRegistrados";
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Boleteria Gato Producciones",
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (context) => const SplashPage(),
        Routes.login: (context) => LoginPage(),
        Routes.registro: (context) => RegistroPage(),
        Routes.roles: (context) => const RolesPage(),
        Routes.clienteMenu: (context) => ClienteMenuPage(),
        Routes.boleteriaMenu: (context) => const BoleteriaMenuPage(),
        Routes.boleteriaListaEvento: (context) => ListarEventosPage(),
        Routes.registroEvento: (context) => RegistroEventoPage(),
        Routes.UsuariosRegistrados: (context) => UsuariosRegistradosPage (),
        Routes.clienteListaEvento: (context) => ListarEventosClientePage(user: currentUser ?? User()),
        Routes.clienteDetalleFactura: (context) => DetalleFacturacionPage(evento: currentEvento ?? Evento(tiposBoletos: []), cantidadBoletos: {}),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(builder: (context) =>  LoginPage()),
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
