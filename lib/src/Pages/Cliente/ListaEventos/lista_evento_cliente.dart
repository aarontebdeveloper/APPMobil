import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/evento.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:flutter_demo/src/Pages/Cliente/Menu/cliente_menu_page.dart';
import 'package:flutter_demo/src/Pages/Facturacion/DetalleFactura/Detalle_Factura_page.dart';
import 'package:flutter_demo/src/Provider/eventos_provider.dart';

class ListarEventosClientePage extends StatefulWidget {
  final User user; // Suponiendo que tienes el modelo User para el usuario actual

  const ListarEventosClientePage({super.key, required this.user}); // Constructor que recibe el usuario

  @override
  _ListarEventosClientePageState createState() =>
      _ListarEventosClientePageState();
}

class _ListarEventosClientePageState extends State<ListarEventosClientePage> {
  final EventoProvider eventoProvider = EventoProvider();
  List<Evento> eventos = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchEventos();
  }

  Future<void> fetchEventos() async {
    try {
      setState(() {
        isLoading = true;
      });
      eventos = await eventoProvider.getAllEventos() ?? [];
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar eventos: $e';
      });
      print(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showEventDetail(Evento evento) {
    Map<String, Map<String, dynamic>> cantidadBoletos = {};
    for (var tipoBoleto in evento.tiposBoletos) {
      cantidadBoletos[tipoBoleto.nombre_tipo] = {
        'cantidad': 0, // Inicializamos en 0
        'id_tipo_boleto': tipoBoleto.id, // ID del tipo de boleto
      };
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              evento.nombre ?? 'Nombre no disponible', // Valor por defecto
              style: TextStyle(color: const Color.fromARGB(255, 2, 51, 91), fontWeight: FontWeight.bold),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(evento.imageUrl ?? '', height: 150, fit: BoxFit.cover),
                    SizedBox(height: 10),
                    Text('Descripción: ${evento.descripcion}', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Ubicación: ${evento.ubicacion}', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Fecha: ${evento.fechaFormateada}', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Hora: ${evento.horaFormateada}', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Card(
                      margin: EdgeInsets.only(top: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.confirmation_number, color: const Color.fromARGB(255, 4, 52, 91)),
                                SizedBox(width: 8),
                                Text('Tipos de Boletos:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 10),
                            ...evento.tiposBoletos.map((tipoBoleto) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(tipoBoleto.nombre_tipo, style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text('Precio: \$${tipoBoleto.precio}', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            if (cantidadBoletos[tipoBoleto.nombre_tipo]!['cantidad'] > 0) {
                                              cantidadBoletos[tipoBoleto.nombre_tipo]!['cantidad'] -= 1;
                                            }
                                          });
                                        },
                                      ),
                                      Text(cantidadBoletos[tipoBoleto.nombre_tipo]!['cantidad'].toString(),
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            cantidadBoletos[tipoBoleto.nombre_tipo]!['cantidad'] += 1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 5, 67, 118)),
              child: Text('Comprar'),
              onPressed: () {
                // Filtrar boletos seleccionados y convertir a Map<String, int>
                Map<String, int> boletosSeleccionados = {}; // Cambio en la declaración
                cantidadBoletos.forEach((key, value) {
                  if (value['cantidad'] > 0) {
                    boletosSeleccionados[key] = value['cantidad']; // Solo guardamos la cantidad
                  }
                });

                // Validar si se ha seleccionado al menos un boleto
                if (boletosSeleccionados.isEmpty) {
                  // Mostrar un mensaje si no hay boletos seleccionados
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡Por favor, selecciona al menos un boleto!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  // Navegar a DetalleFacturacionPage con la información necesaria
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetalleFacturacionPage(
                        evento: evento, // Evento seleccionado
                        cantidadBoletos: boletosSeleccionados, // Aquí pasas el mapa modificado
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 2, 31, 54),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ClienteMenuPage()),
            );
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: eventos.length,
                  itemBuilder: (context, index) {
                    final evento = eventos[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () => showEventDetail(evento),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                evento.nombre ?? 'Nombre no disponible', // Valor por defecto
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Image.network(evento.imageUrl ?? '', height: 150, fit: BoxFit.cover),
                              SizedBox(height: 10),
                              Text('Fecha: ${evento.fechaFormateada}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text('Hora: ${evento.horaFormateada}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              SizedBox(height: 10),
                              Text('Ubicación: ${evento.ubicacion}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromARGB(255, 3, 54, 95),
                                ),
                                child: Text('Ver Detalles'),
                                onPressed: () => showEventDetail(evento),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
