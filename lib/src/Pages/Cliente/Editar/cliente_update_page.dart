import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Pages/Cliente/Editar/cliente_update_controller.dart';

class ClienteUpdatePage extends StatefulWidget {
  final ClienteUpdateController _controller = ClienteUpdateController();
  final User user;

  // ignore: use_super_parameters
  ClienteUpdatePage({Key? key, required this.user})
      : super(key: key); // Modifica el constructor

  @override
  _ClienteUpdatePageState createState() => _ClienteUpdatePageState();
}

class _ClienteUpdatePageState extends State<ClienteUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget._controller.init(context, widget.user, refresh);
    widget._controller.loadUserData(widget.user); // Cargar datos del usuario
  }

  void refresh() {
  setState(() {
    // Actualiza el estado aquí si es necesario, por ejemplo:
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.greenAccent,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Botón para seleccionar imagen
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        widget._controller.showAlertDialog(
                            context); // Mostrar el diálogo para seleccionar imagen
                      },
                      child: const Text("Seleccionar Imagen",
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mostrar imagen seleccionada (si existe)
                  if (widget._controller.imageBytes != null) ...[
                    Image.memory(
                      widget._controller.imageBytes!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                  ],

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
                    label: 'Nueva Contraseña',
                    icon: Icons.lock,
                    obscureText: true,
                    isOptional: true, // Campo opcional
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    controller: widget._controller.confirmPasswordController,
                    label: 'Confirmar Nueva Contraseña',
                    icon: Icons.lock,
                    obscureText: true,
                    isOptional: true, // Campo opcional
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await widget._controller.updateUser();
                        }
                      },
                      child: const Text("Actualizar Datos",
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

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool isEmail = false,
    bool isOptional = false,
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
          prefixIcon: Icon(icon, color: Colors.greenAccent),
          labelStyle: const TextStyle(color: Colors.green),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Colors.greenAccent, width: 2),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Colors.greenAccent, width: 2),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Colors.greenAccent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        controller: widget._controller.cellPhoneController,
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: 'Número de Celular',
          prefixText: '+593 ',
          prefixIcon: Icon(Icons.phone, color: Colors.greenAccent),
          labelStyle: TextStyle(color: Colors.greenAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Colors.greenAccent, width: 2),
          ),
        ),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        onChanged: (value) {
          if (value.startsWith('0')) {
            widget._controller.cellPhoneController.text = value.substring(1);
            widget._controller.cellPhoneController.selection =
                TextSelection.fromPosition(TextPosition(
                    offset:
                        widget._controller.cellPhoneController.text.length));
          }
        },
      ),
    );
  }
}
