import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Pages/Login/login_page.dart';
import 'package:flutter_demo/src/Provider/users_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RegistroController {
  late BuildContext context;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController cellPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final UsersProvider usersProvider = UsersProvider();
  Uint8List? imageBytes; 
  late Function refresh;

  Future<void> init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    await usersProvider.init(context);
  }

  Future<String?> uploadImageToFirebase(Uint8List imageBytes) async {
    try {
      String fileName = 'profile_images/${DateTime.now().millisecondsSinceEpoch}.png';
      TaskSnapshot taskSnapshot = await FirebaseStorage.instance
          .ref(fileName)
          .putData(imageBytes);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  // Método para mostrar el diálogo de carga con un mensaje inicial
  void _showLoading(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  // Método para actualizar el mensaje del diálogo
  void _updateLoadingMessage(String message, {bool isSuccess = false}) {
    Navigator.pop(context); // Cierra el diálogo anterior
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              isSuccess
                  ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                  : const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  // Método para manejar el registro
  Future<void> register() async {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String lastname = lastNameController.text.trim();
    String cedula = cedulaController.text.trim();
    String direccion = direccionController.text.trim();
    String phone = cellPhoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (imageBytes == null) {
      _updateLoadingMessage("Por favor, seleccione una imagen", isSuccess: false);
      return;
    }

    String? validationMessage = _validateInput(email, name, lastname, cedula, direccion, phone, password, confirmPassword);
    if (validationMessage != null) {
      _updateLoadingMessage(validationMessage, isSuccess: false);
      return;
    }

    _showLoading("Registrando...");

    String? imageUrl = await uploadImageToFirebase(imageBytes!);
    if (imageUrl == null) {
      _updateLoadingMessage("Error al subir la imagen a Firebase", isSuccess: false);
      return;
    }

    User user = User(
      email: email,
      name: name,
      lastname: lastname,
      cedula: cedula,
      direccion: direccion,
      phone: "+593$phone",
      password: password,
      image: imageUrl,
    );

    try {
      final Map<String, dynamic> requestBody = {'user': json.encode(user.toJson())};
      final response = await http.post(
        Uri.parse('http://192.168.3.36:3000/api/users/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _updateLoadingMessage("Registro exitoso", isSuccess: true);
        await Future.delayed(const Duration(seconds: 4));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        _clearControllers();
      } else if (response.statusCode == 409) {
        _updateLoadingMessage("El correo ya está registrado, por favor inicie sesión.", isSuccess: false);
      } else {
        _updateLoadingMessage("El correo ya está registrado, por favor inicie sesión", isSuccess: false);
      }
       await Future.delayed(const Duration(seconds: 4));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        _updateLoadingMessage("Error: No hay conexión a internet", isSuccess: false);
      } else {
        _updateLoadingMessage(" No hay conexión a internet", isSuccess: false);
      }
      await Future.delayed(const Duration(seconds: 4));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
    }
  }
  

  String? _validateInput(String email, String name, String lastname,
      String cedula,String direccion, String phone, String password, String confirmPassword) {
    if (email.isEmpty ||
        name.isEmpty ||
        lastname.isEmpty ||
        phone.isEmpty ||
        cedula.isEmpty ||
        direccion.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return "Todos los campos son obligatorios";
    }

    // Validación de correo electrónico con una expresión regular
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(email) ||
        !_isValidDomain(email)) {
      return "Correo electrónico no válido";
    }

    if (password != confirmPassword) {
      return "Las contraseñas no coinciden";
    }

    return null;
  }

  // Función para verificar el dominio
  bool _isValidDomain(String email) {
    final domain = email.split('@').last;

    const validDomains = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
    ];

    return validDomains.contains(domain);
  }

  void _clearControllers() {
    emailController.clear();
    nameController.clear();
    lastNameController.clear();
    cellPhoneController.clear();
    cedulaController.clear();
    direccionController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    imageBytes = null;
  }

  Future<void> selectedImage(ImageSource imageSource) async {
    final ImagePicker imagePicker = ImagePicker();
    try {
      final XFile? pickedFile = await imagePicker.pickImage(source: imageSource);
      if (pickedFile != null) {
        imageBytes = await pickedFile.readAsBytes();
        debugPrint('Imagen seleccionada: ${pickedFile.path}');
      } else {
        debugPrint('No se seleccionó ninguna imagen');
      }
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
    } finally {
      Navigator.pop(context);
      refresh();
    }
  }

  void showAlertDialog(BuildContext context) {
    Widget galleryButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 243, 244, 244),
      ),
      onPressed: () {
        selectedImage(ImageSource.gallery);
      },
      child: const Text(
        "GALERÍA",
        style: TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    Widget cameraButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 245, 246, 245),
      ),
      onPressed: () {
        selectedImage(ImageSource.camera);
      },
      child: const Text(
        "CÁMARA",
        style: TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    AlertDialog alertDialog = AlertDialog(
      title: const Text(
        "Selecciona una imagen",
        style: TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      actions: [
        galleryButton,
        cameraButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }
}
