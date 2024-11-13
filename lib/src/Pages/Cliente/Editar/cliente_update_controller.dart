import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Pages/Cliente/Menu/cliente_menu_page.dart';
import 'package:flutter_demo/src/Pages/login/login_page.dart';
import 'package:flutter_demo/src/Provider/users_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClienteUpdateController {
  late BuildContext context;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController cedulaController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController cellPhoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final UsersProvider usersProvider = UsersProvider();
  Uint8List? imageBytes;
  late Function refresh;
  late String userId;

  Future<void> init(BuildContext context, User user, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    userId = user.id!;
    await usersProvider.init(context);
    loadUserData(user);
  }

  Future<void> updateUser() async {
    _showLoading("Actualizando datos...");

    User updatedUser = User(
      id: userId,
      email: emailController.text,
      name: nameController.text,
      lastname: lastNameController.text,
      cedula: cedulaController.text,
      direccion: direccionController.text,
      phone: cellPhoneController.text,
      password: passwordController.text.isNotEmpty ? passwordController.text : null,
    );

    bool userDataChanged = await _hasUserDataChanged(updatedUser);

    if (imageBytes != null) {
      updatedUser.image = await uploadImageToFirebase(imageBytes!);
    }

    final response = await usersProvider.update(updatedUser, imageBytes);

    Navigator.pop(context); // Cierra el diálogo de carga

    if (response?.success ?? false) {
      await _handleSuccessfulUpdate(userDataChanged, updatedUser);
    } else {
      _showMessage(response?.message ?? 'Error desconocido');
    }
  }

  Future<bool> _hasUserDataChanged(User updatedUser) async {
    User? currentUser = await usersProvider.getCurrentUserData();
    return updatedUser.email != currentUser?.email ||
           updatedUser.name != currentUser?.name ||
           updatedUser.lastname != currentUser?.lastname ||
           updatedUser.cedula != currentUser?.cedula ||
           updatedUser.direccion != currentUser?.direccion ||
           updatedUser.phone != currentUser?.phone ||
           passwordController.text.isNotEmpty ||
           imageBytes != null;
  }

  Future<void> _handleSuccessfulUpdate(bool userDataChanged, User updatedUser) async {
    String successMessage = 'Datos actualizados con éxito. Vuelva a iniciar sesión';
    _showMessage(successMessage, isSuccess: true);

    await Future.delayed(Duration(seconds: 3)); // Muestra el mensaje por 3 segundos

    if (userDataChanged) {
      await usersProvider.logout();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
    } else {
      await _updateLocalUser(updatedUser);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ClienteMenuPage()));
    }
  }

  Future<void> _updateLocalUser(User updatedUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(updatedUser.toJson()));
    refresh();
  }

  Future<String?> uploadImageToFirebase(Uint8List imageBytes) async {
    try {
      String fileName = 'profile_images/${DateTime.now().millisecondsSinceEpoch}.png';
      TaskSnapshot taskSnapshot = await FirebaseStorage.instance.ref(fileName).putData(imageBytes);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  void _showLoading(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            isSuccess ? Icon(Icons.check_circle, color: Colors.greenAccent) : Icon(Icons.error, color: Colors.red),
            SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void loadUserData(User user) {
    emailController.text = user.email ?? '';
    nameController.text = user.name ?? '';
    lastNameController.text = user.lastname ?? '';
    cellPhoneController.text = user.phone ?? '';
    cedulaController.text = user.cedula ?? '';
    direccionController.text = user.direccion ?? '';
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
      style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 243, 244, 244)),
      onPressed: () => selectedImage(ImageSource.gallery),
      child: Text("Galeria", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
    );

    Widget cameraButton = ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 245, 246, 245)),
      onPressed: () => selectedImage(ImageSource.camera),
      child: Text("Camara", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Selecciona una imagen", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        actions: [galleryButton, cameraButton],
      ),
    );
  }
}
