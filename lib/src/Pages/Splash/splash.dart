import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Animación para la rotación 3D
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.repeat(); // Hace que la animación se repita en un loop

    // Redirige después de 4 segundos
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacementNamed('eventos');
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera el controlador al cerrar la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent, // Fondo verde
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculamos los tamaños basados en el tamaño de la pantalla
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono animado con efecto 3D de rotación
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform(
                      transform: Matrix4.rotationY(_rotateAnimation.value)
                        ..setEntry(3, 2, 0.002), // Le da profundidad al objeto
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.music_note, // Ícono de música
                    size: screenWidth * 0.3, // Tamaño dinámico basado en el ancho de la pantalla
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05), // Espaciado responsivo
                Text(
                  'APP DE BOLETERÍA',
                  style: TextStyle(
                    fontSize: screenWidth * 0.1, // Tamaño de fuente dinámico
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05), // Espaciado responsivo
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
