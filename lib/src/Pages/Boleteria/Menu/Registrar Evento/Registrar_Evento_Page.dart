import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/evento.dart';
import 'package:flutter_demo/src/Pages/Boleteria/Menu/Registrar%20Evento/Registrar_Evento_Controller.dart';
import 'package:flutter_demo/src/Pages/Boleteria/Menu/boleteria_menu_page.dart';
import 'package:image_picker/image_picker.dart';

class RegistroEventoPage extends StatefulWidget {
  const RegistroEventoPage({super.key});

  @override
  _RegistroEventoPageState createState() => _RegistroEventoPageState();
}

class _RegistroEventoPageState extends State<RegistroEventoPage> {
  final RegistroEventoController _controller = RegistroEventoController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _boletoFormKey = GlobalKey<FormState>();

  String _nombreTipo = '';
  double _precio = 0.0;
  int _cantidad = 0;

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text(
          'Registrar Evento',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BoleteriaMenuPage(),
              ),
            );
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextFormField(
                        label: 'Nombre del Evento',
                        icon: Icons.event,
                        onSaved: (value) {
                          _controller.evento.nombre = value ?? '';
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextFormField(
                        label: 'Ubicación',
                        icon: Icons.location_on,
                        onSaved: (value) {
                          _controller.evento.ubicacion = value ?? '';
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextFormField(
                        label: 'Descripción',
                        icon: Icons.description,
                        onSaved: (value) {
                          _controller.evento.descripcion = value ?? '';
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _selectDate,
                        child: Text('Seleccionar Fecha'),
                      ),
                      SizedBox(height: 8),
                      if (_fechaSeleccionada != null)
                        Text(
                          'Fecha seleccionada: ${_fechaSeleccionada?.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(color: Color.fromARGB(255, 16, 16, 16)),
                        ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _selectTime,
                        child: Text('Seleccionar Hora'),
                      ),
                      SizedBox(height: 8),
                      if (_horaSeleccionada != null)
                        Text(
                          'Hora seleccionada: ${_horaSeleccionada!.hour}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: Color.fromARGB(255, 8, 8, 8)),
                        ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: _selectImage,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color.fromARGB(255, 109, 223, 124)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _imageBytes != null
                              ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                              : Center(
                                  child: Text(
                                    'Seleccionar Imagen',
                                    style: TextStyle(color: const Color.fromARGB(255, 12, 12, 12)),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tipos de Boletos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 104, 240, 161),
                        ),
                      ),
                      _buildTicketList(),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _agregarTipoBoleto,
                        child: Text('Agregar Tipo de Boleto'),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _submit,
                        child: Text('Registrar Evento'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required IconData icon,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color.fromARGB(255, 92, 234, 135)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 90, 223, 132)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 86, 213, 131)),
        ),
        prefixIcon: Icon(
          icon,
          color: Color.fromARGB(255, 80, 228, 152),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildTicketList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _controller.evento.tiposBoletos.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_controller.evento.tiposBoletos[index].nombre_tipo),
          subtitle: Text(
            'Precio: ${_controller.evento.tiposBoletos[index].precio}, Cantidad: ${_controller.evento.tiposBoletos[index].cantidad_disponible}',
            style: TextStyle(color: Colors.grey),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                _controller.evento.tiposBoletos.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
    }
  }
   
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _fechaSeleccionada = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _horaSeleccionada = pickedTime;
      });
    }
  }

  void _agregarTipoBoleto() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Tipo de Boleto'),
          content: Form(
            key: _boletoFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField(
                  label: 'Nombre del Tipo',
                  icon: Icons.confirmation_number,
                  onSaved: (value) {
                    _nombreTipo = value ?? '';
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  label: 'Precio',
                  icon: Icons.attach_money,
                  onSaved: (value) {
                    _precio = double.tryParse(value ?? '') ?? 0.0;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (double.tryParse(value) == null || double.tryParse(value)! <= 0) {
                      return 'Ingrese un número válido mayor a 0';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  label: 'Cantidad',
                  icon: Icons.confirmation_number,
                  onSaved: (value) {
                    _cantidad = int.tryParse(value ?? '') ?? 1;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (int.tryParse(value) == null || int.tryParse(value)! <= 0) {
                      return 'Ingrese un número válido mayor a 0';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_boletoFormKey.currentState!.validate()) {
                  _boletoFormKey.currentState!.save();
                  setState(() {
                    _controller.evento.tiposBoletos.add(TipoBoleto(
                      nombre_tipo: _nombreTipo,
                      precio: _precio,
                      cantidad_disponible: _cantidad,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

void _submit() async {
  if (_formKey.currentState!.validate() &&
      _fechaSeleccionada != null &&
      _horaSeleccionada != null &&
      _imageBytes != null) {
    _formKey.currentState!.save();

    try {
      await _controller.crearEvento(_imageBytes);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Evento registrado exitosamente!'),
        backgroundColor: Colors.greenAccent,
      ));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BoleteriaMenuPage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al registrar el evento: $e'),
        backgroundColor: Colors.red,
      ));
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Completa todos los campos.'),
      backgroundColor: Colors.red,
    ));
  }
}
}
