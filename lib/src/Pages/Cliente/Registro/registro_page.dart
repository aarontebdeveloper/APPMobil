import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/src/Pages/Cliente/Registro/registro_controller.dart';
import 'package:flutter_demo/src/Pages/login/login_page.dart';

class RegistroPage extends StatefulWidget {
  final RegistroController _controller = RegistroController();

  RegistroPage({super.key});

  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget._controller.init(context, refresh);
  }

  // Método para refrescar la UI después de seleccionar la imagen
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00695C), // Fondo verde marino
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Hacer el AppBar transparente
        elevation: 0, // Quitar la sombra del AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Icono de "Atrás" en blanco
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()), // Navegar a la página de login
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Seleccionar Foto de Perfil',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Cambiar a blanco
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Botón para seleccionar la imagen
                  GestureDetector(
                    onTap: () {
                      widget._controller.showAlertDialog(context);
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: widget._controller.imageBytes != null
                            ? DecorationImage(
                                image:
                                    MemoryImage(widget._controller.imageBytes!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget._controller.imageBytes == null
                          ? const Icon(Icons.camera_alt,
                              color: Colors.white, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Reutilizando _buildTextField para mantener los estilos
                  _buildTextField(
                    context,
                    controller: widget._controller.emailController,
                    label: 'Correo Electrónico',
                    icon: Icons.email,
                    isEmail: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    controller: widget._controller.nameController,
                    label: 'Nombre',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    controller: widget._controller.lastNameController,
                    label: 'Apellido',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    controller: widget._controller.cedulaController,
                    label: 'Cedula o Ruc',
                    icon: Icons.person,
                    isCedulaRuc: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    controller: widget._controller.direccionController,
                    label: 'Direccion',
                    icon: Icons.maps_home_work,
                  ),
                  const SizedBox(height: 16),
                  _buildPhoneNumberField(context),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    controller: widget._controller.passwordController,
                    label: 'Contraseña',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    controller: widget._controller.confirmPasswordController,
                    label: 'Confirmar Contraseña',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 4, 108, 68), // Azul brillante como en LoginPage
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          widget._controller.register();
                        }
                      },
                      child: const Text("Crear Cuenta",
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Método reutilizado para los campos de texto
  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool isEmail = false,
    bool isCedulaRuc = false,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 2, 79, 39)),
          labelStyle: const TextStyle(color: Color.fromARGB(255, 5, 131, 101)),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Color.fromARGB(255, 3, 90, 68), width: 2),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Color.fromARGB(255, 3, 90, 68), width: 2),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Color.fromARGB(255, 246, 249, 248), width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa $label';
          }
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Por favor ingresa un correo válido';
          }
          if (obscureText && value.length < 8) {
            return 'La contraseña debe tener al menos 8 caracteres';
          }
          if (label == 'Confirmar Contraseña' &&
              value != widget._controller.passwordController.text) {
            return 'Las contraseñas no coinciden';
          }
          if (isCedulaRuc && !validarCedulaOCedula(value)) {
            return 'El número de cédula o RUC no es válido';
          }
          return null;
        },
      ),
    );
  }

 // Validar cédula o RUC
bool validarCedulaOCedula(String value) {
  if (value.length == 10) {
    return _validarCedula(value);
  } else if (value.length == 13) {
    return _validarRuc(value);
  }
  return false; // Retorna false si la longitud no es válida
}

// Validar cédula
bool _validarCedula(String cedula) {
  int suma = 0;
  List<int> cedulaArray = cedula.split('').map((e) => int.parse(e)).toList();

  // Validar el primer dígito
  if (cedula.length != 10) return false;

  for (int i = 0; i < 9; i++) {
    if (i % 2 == 0) {
      cedulaArray[i] *= 2;
      if (cedulaArray[i] > 9) cedulaArray[i] -= 9;
    }
    suma += cedulaArray[i];
  }
  int digitoVerificador = (suma % 10 == 0) ? 0 : 10 - (suma % 10);

  return digitoVerificador == cedulaArray[9];
}

// Validar RUC
bool _validarRuc(String ruc) {
  // El primer dígito puede ser '1' (persona natural) o '2' (persona jurídica) o '0' (otros casos)
  if (ruc.length == 13 && (ruc[0] == '1' || ruc[0] == '2' || ruc[0] == '0')) {
    return true; // RUC válido
  }
  return false; // RUC inválido
}

  // Método para el campo de teléfono
  Widget _buildPhoneNumberField(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        controller: widget._controller.cellPhoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: 'Teléfono',
          prefixText: '+593 ',
          prefixStyle: const TextStyle(color: Color.fromARGB(255, 2, 95, 67)),
          labelStyle: const TextStyle(color: Color.fromARGB(255, 7, 92, 74)),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Color.fromARGB(255, 3, 90, 68), width: 2),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Color.fromARGB(255, 3, 90, 68), width: 2),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Color.fromARGB(255, 3, 90, 68), width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa un teléfono';
          }
          if (!RegExp(r'^[9]{1}[8-9]{1}[0-9]{7}$').hasMatch(value)) {
            return 'Por favor ingresa un número válido de teléfono';
          }
          return null;
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9), // Permitimos solo 9 dígitos
        ],
      ),
    );
  }
}
