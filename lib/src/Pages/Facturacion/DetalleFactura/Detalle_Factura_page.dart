import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/evento.dart';
import 'package:flutter_demo/src/Pages/Facturacion/DetalleFactura/Detalle_Factura_Controller.dart';
import 'package:flutter_demo/src/Pages/Facturacion/DetalleFactura/Pagos/PagoDeunaButton.dart';

class DetalleFacturacionPage extends StatefulWidget {
  final Evento evento;
  final Map<String, int> cantidadBoletos;

  const DetalleFacturacionPage({
    super.key,
    required this.evento,
    required this.cantidadBoletos,
  });

  @override
  _DetalleFacturacionPageState createState() => _DetalleFacturacionPageState();
}

class _DetalleFacturacionPageState extends State<DetalleFacturacionPage> {
  final DetalleFacturacionController _controller =
      DetalleFacturacionController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.init(context, widget.evento).then((_) {
      setState(() {});
    });
  }

  Future<void> _mostrarDialogo(String mensaje, bool esExito) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              Icon(
                esExito ? Icons.check_circle : Icons.error,
                color: esExito ? Colors.green : Colors.red,
                size: 40,
              ),
              SizedBox(width: 10),
              Expanded(child: Text(mensaje)),
            ],
          ),
        );
      },
    );

    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    double subtotalSinIva = 0.0;

    // Calcular el subtotal sin IVA basado en los boletos seleccionados
    widget.cantidadBoletos.forEach((tipoBoleto, cantidad) {
      final precioConIva = widget.evento.tiposBoletos
          .firstWhere((tb) => tb.nombre_tipo == tipoBoleto)
          .precio!;
      subtotalSinIva += precioConIva * cantidad;
    });

    double iva = subtotalSinIva * 0.15;
    double total = subtotalSinIva + iva + 0.40; // Incluye costo de servicio

    // Crear una lista con la información de todos los boletos seleccionados
    List<Map<String, dynamic>> boletosSeleccionados = [];

    widget.cantidadBoletos.forEach((tipoBoleto, cantidad) {
      final tipoBoletoDetails = widget.evento.tiposBoletos
          .firstWhere((tb) => tb.nombre_tipo == tipoBoleto);
      boletosSeleccionados.add({
        'id': tipoBoletoDetails.id!,
        'nombre': tipoBoleto,
        'cantidad': cantidad,
        'precio': tipoBoletoDetails.precio!,
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Detalle de Facturación',
              style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 33, 59),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _controller.user == null
                ? Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTicketSection(
                          'Detalles de Compra',
                          _buildPurchaseDetails(subtotalSinIva, iva, total),
                        ),
                        SizedBox(height: 20),
                        if (_isLoading) CircularProgressIndicator(),
                        if (!_isLoading)
                          PagomediosButton(
                            idEvento: widget.evento.id!,
                            nombreEvento: widget.evento.nombre!,
                            idTipoBoletos: boletosSeleccionados
                                .map((e) => e['id'].toString())
                                .toList(), // Aquí se pasan los IDs de boletos
                            correo: _controller.user!.email!,
                            phone: _controller.user!.phone!,
                            idUser: _controller.user!.id!,
                            direccion: _controller.user!.direccion!,
                            cedula: _controller.user!.cedula!,
                            nombre: _controller.user!.name!,
                            apellido: _controller.user!.lastname!,
                            tipoBoletos: widget.cantidadBoletos, // Mapa de boletos y cantidades
                            cantidades: widget.cantidadBoletos, // Mapa de cantiCVdades de boletos
                            precioPorBoleto: boletosSeleccionados
                                .asMap()
                                .map((index, e) => MapEntry(e['nombre'], e['precio'])),
                            subtotalSinIva: subtotalSinIva,
                            iva: iva,
                            key: Key('boton-pago'),
                          ),
                        SizedBox(height: 20),
                        _buildCancelButton(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketSection(String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 2, 54, 96),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildPurchaseDetails(
      double subtotalSinIva, double iva, double total) {
    return Container(
      constraints: BoxConstraints(maxWidth: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              'Nombre: ${_controller.user?.name} ${_controller.user?.lastname}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Correo: ${_controller.user?.email}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Teléfono: ${_controller.user?.phone}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Cédula o RUC: ${_controller.user?.cedula}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Dirección: ${_controller.user?.direccion}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Evento: ${widget.evento.nombre}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Fecha: ${widget.evento.fechaFormateada}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Hora: ${widget.evento.horaFormateada}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Ubicación: ${widget.evento.ubicacion}',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              widget.evento.imageUrl ?? '',
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.image_not_supported, size: 100);
              },
            ),
          ),
          SizedBox(height: 10),
          Text('Tickets Adquiridos',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...widget.cantidadBoletos.entries.map((entry) {
            final tipoBoleto = widget.evento.tiposBoletos
                .firstWhere((tb) => tb.nombre_tipo == entry.key);
            return Text(
              '${entry.key}: ${entry.value} x \$${tipoBoleto.precio}',
              style: TextStyle(fontWeight: FontWeight.bold),
            );
          }).toList(),
          SizedBox(height: 10),
          Text('Subtotal sin IVA: \$${subtotalSinIva.toStringAsFixed(2)}'),
          Text('IVA: \$${iva.toStringAsFixed(2)}'),
          Text('Costo de Servicio: \$${0.40.toStringAsFixed(2)}'),
          Text('Total: \$${total.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.redAccent,
      ),
      child: Text('Cancelar'),
    );
  }
}
