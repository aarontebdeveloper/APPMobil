import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Pages/login/login_controller.dart';

class LoginPage extends StatefulWidget {
  final String? successMessage;

  const LoginPage({super.key, this.successMessage});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? emailError;

  late LoginController _loginController;

  late AnimationController _animationController;
  late Animation<Offset> _textAnimation;

  @override
  void initState() {
    super.initState();
    _loginController = LoginController();
    _loginController.init(context);

    // Inicializando la animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Animación de desplazamiento hacia la izquierda
    _textAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Empieza fuera de la pantalla a la derecha
      end: Offset.zero, // Termina en su posición original
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Iniciar la animación
    _animationController.forward();

    if (widget.successMessage != null) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.successMessage!),
          backgroundColor: Colors.greenAccent,
        ));
      });
    }
  }

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Por favor ingresa un correo electrónico';
    }
    const String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value)) {
      return 'Por favor ingresa un correo electrónico válido';
    }
    return null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 248, 250, 250), // Fondo verde marino
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),

                  // Logo 3D con perspectiva
                  Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.003) // Perspectiva 3D
                      ..rotateX(0.2) // Rotación para efecto 3D
                      ..rotateY(0.3), // Rotación para efecto 3D
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.event,
                      size: 120,
                      color: Color.fromARGB(255, 7, 165, 239), // Logo en verde marino oscuro
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Texto 'BOLETERIA' con animación de barrido hacia la izquierda
                  SlideTransition(
                    position: _textAnimation,
                    child: Text(
                      'BOLETERIA',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 10, 140, 226), // Color blanco
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Campo de correo electrónico
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextFormField(
                      controller: _loginController.emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Correo Electrónico',
                        prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 29, 148, 227)), // Icono en verde marino
                        labelStyle: const TextStyle(color: Color(0xFF004D40)), // Etiqueta en verde marino
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 7, 193, 239), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 7, 193, 239), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 7, 193, 239), width: 2),
                        ),
                        errorText: emailError,
                      ),
                      onChanged: (value) {
                        setState(() {
                          emailError = validateEmail(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo de contraseña
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: TextFormField(
                      controller: _loginController.passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock, color: Color.fromARGB(255, 29, 148, 227)), // Icono en verde marino
                        labelStyle: TextStyle(color: Color(0xFF004D40)), // Etiqueta en verde marino
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 7, 193, 239), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 7, 193, 239), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 7, 193, 239), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón de inicio de sesión
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 6, 205, 240), // Botón en verde marino oscuro
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate() && emailError == null) {
                          _loginController.login();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor corrige los errores.')),
                          );
                        }
                      },
                      child: const Text(
                        "Iniciar Sesión",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'registro');
                    },
                    child: const Text(
                      '¿No tienes cuenta? Regístrate aquí',
                      style: TextStyle(color: Color.fromARGB(255, 14, 157, 239)), // Enlace en verde brillante
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
