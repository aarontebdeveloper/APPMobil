import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/evento.dart';
import 'package:flutter_demo/src/Pages/Boleteria/Menu/Listar/Eventos_listar_controller.dart';
import 'package:flutter_demo/src/Pages/Boleteria/Menu/boleteria_menu_page.dart';
import 'package:flutter_demo/src/Provider/eventos_provider.dart';
import 'package:image_picker/image_picker.dart';

class ListarEventosPage extends StatefulWidget {
  const ListarEventosPage({super.key});

  @override
  _ListarEventosPageState createState() => _ListarEventosPageState();
}

class _ListarEventosPageState extends State<ListarEventosPage> {
  late Future<List<Evento>?> eventosFuture;
  final EventoProvider eventoProvider = EventoProvider();
  late final ListarEventoController
      controller; // Suponiendo que el controlador maneja la lógica
// Crear instancia del proveedor

  @override
  void initState() {
    super.initState();
    eventosFuture = eventoProvider.getAllEventos(); // Cargar eventos
  }

  Future<void> _refreshEventos() async {
    setState(() {
      eventosFuture = eventoProvider.getAllEventos(); // Actualizar eventos
    });
  }

  // Función para sumar las cantidades disponibles de los tipos de boletos
  int _calcularCantidadTotal(List<TipoBoleto> tiposBoletos) {
    return tiposBoletos.fold(
        0, (total, tipo) => total + tipo.cantidad_disponible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Eventos Programados',
              style: TextStyle(color: Colors.white)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BoleteriaMenuPage()),
            );
          },
        ),

        backgroundColor: Colors.greenAccent, // Fondo blanco para el AppBar
      ),
      body: FutureBuilder<List<Evento>?>(
        future: eventosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay eventos disponibles.'));
          }

          final eventos = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshEventos,
            child: ListView.builder(
              itemCount: eventos.length,
              itemBuilder: (context, index) {
                final evento = eventos[index];
                final cantidadTotal = _calcularCantidadTotal(
                    evento.tiposBoletos); // Sumar cantidades

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 4,
                  child: ListTile(
                    leading:
                        (evento.imageUrl != null && evento.imageUrl!.isNotEmpty)
                            ? Image.network(
                                evento.imageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    width: 50,
                                    height: 50,
                                    child: Center(
                                        child: Text('Error al cargar imagen')),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                width: 50,
                                height: 50,
                                child: Center(child: Text('Sin imagen')),
                              ),
                    title: Text(  evento.nombre != null ? evento.nombre! : 'Nombre no disponible',
                        style: TextStyle(color: Colors.black)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ubicacion: ${evento.ubicacion}',
                            style: TextStyle(color: Colors.black54)),
                        Text('Fecha: ${evento.fechaFormateada}',
                            style: TextStyle(color: Colors.black54)),
                        Text('Hora: ${evento.horaFormateada}',
                            style: TextStyle(color: Colors.black54)),
                        Text(
                            'Total Boletos Disponibles: $cantidadTotal', // Mostrar total
                            style: TextStyle(color: Colors.greenAccent)),
                      ],
                    ),
                    trailing:
                        Icon(Icons.arrow_forward, color: Colors.greenAccent),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalleEventoPage(evento: evento),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetalleEventoPage extends StatelessWidget {
  final Evento evento;
  final EventoProvider eventoProvider = EventoProvider();
  DetalleEventoPage({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(  evento.nombre != null ? evento.nombre! : 'Nombre no disponible', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mostrar imagen del evento
            Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: evento.imageUrl != null && evento.imageUrl!.isNotEmpty
                  ? Image.network(evento.imageUrl!, fit: BoxFit.cover)
                  : Center(child: Text('Sin imagen disponible')),
            ),
            SizedBox(height: 16.0),

            // Detalles del evento
            Text(
                evento.nombre != null ? evento.nombre! : 'Nombre no disponible',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Text('Fecha: ${evento.fechaFormateada}', style: TextStyle(fontSize: 16)),
            Text('Hora: ${evento.horaFormateada}', style: TextStyle(fontSize: 16)), 
            Text('Ubicación: ${evento.ubicacion}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8.0),
            Text('Descripción: ${evento.descripcion}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16.0),

            // Mostrar tipos de boletos
            Text(
              'Tipos de boletos:',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),

            if (evento.tiposBoletos.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: evento.tiposBoletos.length,
                itemBuilder: (context, index) {
                  final tipoBoleto = evento.tiposBoletos[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Center(child: Text(tipoBoleto.nombre_tipo)),
                      subtitle: Center(
                          child: Text(
                              'Precio: \$${tipoBoleto.precio} - Cantidad: ${tipoBoleto.cantidad_disponible}')),
                    ),
                  );
                },
              )
            else
              Center(child: Text('No hay tipos de boletos disponibles.')),
            SizedBox(height: 20),

            // Botones separados
            _buildActionButton(context, 'Actualizar Evento', Colors.greenAccent,
                () => _mostrarDialogoActualizarEvento(context)),
            SizedBox(height: 10), // Separación entre botones
            _buildActionButton(context, 'Eliminar Evento', Colors.red,
                () => _eliminarEvento(context)),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildActionButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Future<void> _mostrarDialogoActualizarEvento(BuildContext context) async {
    final TextEditingController nombreController =
        TextEditingController(text: evento.nombre);
    final TextEditingController fechaController =
        TextEditingController(text: evento.fecha?.toIso8601String());
    final TextEditingController ubicacionController =
        TextEditingController(text: evento.ubicacion);
    final TextEditingController descripcionController =
        TextEditingController(text: evento.descripcion);

    Uint8List? imageBytes; // Para almacenar los bytes de la nueva imagen
    List<TipoBoleto> tiposBoletoActualizados = List.from(
        evento.tiposBoletos); // Copia de los tipos de boletos existentes
    List<TextEditingController> nombreBoletoControllers = [];
    List<TextEditingController> precioControllers = [];
    List<TextEditingController> cantidadControllers = [];

    // Inicializar controladores para los tipos de boletos
    for (var tipo in tiposBoletoActualizados) {
      nombreBoletoControllers
          .add(TextEditingController(text: tipo.nombre_tipo));
      precioControllers
          .add(TextEditingController(text: tipo.precio.toString()));
      cantidadControllers.add(
          TextEditingController(text: tipo.cantidad_disponible.toString()));
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Actualizar Evento'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: fechaController,
                  decoration: InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: evento.fecha,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      fechaController.text = selectedDate.toIso8601String();
                    }
                  },
                ),
                TextField(
                  controller: ubicacionController,
                  decoration: InputDecoration(labelText: 'Ubicación'),
                ),
                TextField(
                  controller: descripcionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                SizedBox(height: 10),
                // Mostrar la imagen seleccionada o existente
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: 140,
                  height: 180,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: imageBytes != null
                      ? Image.memory(imageBytes!,
                          fit: BoxFit.cover) // Muestra la imagen seleccionada
                      : (evento.imageUrl != null
                          ? Image.network(evento.imageUrl!,
                              fit: BoxFit.cover) // Muestra la imagen existente
                          : Container()), // Si no hay imagen, muestra un contenedor vacío
                ),
                // Botón para seleccionar nueva imagen
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? imageFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (imageFile != null) {
                      imageBytes = await imageFile
                          .readAsBytes(); // Obtener los bytes de la nueva imagen
                      (context as Element)
                          .markNeedsBuild(); // Usar setState del StatefulBuilder
                    }
                  },
                  child: Text('Seleccionar Nueva Imagen'),
                ),

                // Sección para actualizar los tipos de boletos
                SizedBox(height: 16),
                Text(
                  'Actualizar Tipos de Boletos:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...tiposBoletoActualizados.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: nombreBoletoControllers[index],
                            decoration:
                                InputDecoration(labelText: 'Nombre del Boleto'),
                          ),
                          TextField(
                            controller: precioControllers[index],
                            decoration: InputDecoration(labelText: 'Precio'),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: cantidadControllers[index],
                            decoration: InputDecoration(
                                labelText: 'Cantidad Disponible'),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Actualizar'),
              onPressed: () async {
                // Mantener la URL existente si no se selecciona nueva imagen.
                String? imageUrl;
                // Actualiza los tipos de boletos
                for (var i = 0; i < tiposBoletoActualizados.length; i++) {
                  tiposBoletoActualizados[i].nombre_tipo =
                      nombreBoletoControllers[i]
                          .text; // Utiliza el controlador correcto
                  tiposBoletoActualizados[i].precio =
                      double.tryParse(precioControllers[i].text) ??
                          tiposBoletoActualizados[i].precio;
                  tiposBoletoActualizados[i].cantidad_disponible =
                      int.tryParse(cantidadControllers[i].text) ??
                          tiposBoletoActualizados[i].cantidad_disponible;
                }

                // Crear un nuevo objeto Evento con los datos actualizados
                final updatedEvento = Evento(
                  id: evento.id,
                  nombre: nombreController.text,
                  fecha: DateTime.parse(fechaController.text),
                  ubicacion: ubicacionController.text,
                  descripcion: descripcionController.text,
                  imageUrl: imageUrl, // Usar la URL de la imagen
                  tiposBoletos:
                      tiposBoletoActualizados, // Usar los tipos de boletos actualizados
                );

                // Llama al método updateEvento con el objeto actualizado
                final response = await eventoProvider.updateEvento(
                    updatedEvento, imageBytes);

                // Manejo de la respuesta
                if (response != null && response.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Evento actualizado exitosamente.')),
                  );
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context,
                      "boleteria/listaEvento"); // Regresar a la lista de eventos
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Error al actualizar el evento: ${response?.message ?? 'Error desconocido'}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarEvento(BuildContext context) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este evento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancelar
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirmar
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmacion == true) {
      if (evento.id != null) {
        final response = await eventoProvider.deleteEvento(evento.id!);

        if (response != null && response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Evento eliminado exitosamente.')),
          );
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context,
              "boleteria/listaEvento"); // Regresar a la lista de eventos
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error al eliminar el evento: ${response?.message ?? 'Error desconocido'}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ID de evento no disponible.')),
        );
      }
    }
  }
}
