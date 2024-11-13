import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PagomediosButton extends StatefulWidget {
  final String nombreEvento;
  final String correo;
  final String phone;
  final String idEvento;
  final String idUser;
  final List<String> idTipoBoletos;
  final String direccion;
  final String cedula;
  final String nombre;
  final String apellido;
  final Map<String, int> tipoBoletos;
  final Map<String, int> cantidades;
  final Map<String, double> precioPorBoleto;
  final double subtotalSinIva;
  final double iva;

  const PagomediosButton({
    required this.idEvento,
    required this.nombreEvento,
    required this.idTipoBoletos,
    required this.correo,
    required this.phone,
    required this.idUser,
    required this.direccion,
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.tipoBoletos,
    required this.cantidades,
    required this.precioPorBoleto,
    required this.subtotalSinIva,
    required this.iva,
    Key? key,
  }) : super(key: key);

  @override
  _PagomediosButtonState createState() => _PagomediosButtonState();
}

class _PagomediosButtonState extends State<PagomediosButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : procesarPago,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.monetization_on, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Pagar con Pagomedios',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 6, 56, 95),
          ),
        ),
      ],
    );
  }

  Future<void> procesarPago() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://api.abitmedia.cloud/pagomedios/v2/payment-requests');

    // Calculo correcto de los montos.
    double totalSinIva = widget.subtotalSinIva + 0.40; // Total sin IVA
    double totalIva = widget.iva; // IVA

    // Construir el cuerpo de la solicitud para la API de Pagomedios
    final body = jsonEncode({
      'integration': true,
      'third': {
        'document': widget.cedula,
        'document_type': '05',
        'name': '${widget.nombre} ${widget.apellido}',
        'email': widget.correo,
        'phones': widget.phone,
        'address': widget.direccion,
        'type': 'Individual',
      },
      'generate_invoice': 0,
      'description': 'Pago del evento ${widget.nombreEvento}',
      'amount': totalSinIva + totalIva,
      'amount_with_tax': 0,
      'amount_without_tax': totalSinIva,
      'tax_value': totalIva,
      'settings': [],
      'notify_url': null,
      'custom_value': null,
      'has_cards': 1,
      'has_de_una': 0,
      'has_paypal': 0,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer  3wv1x3b0eyc5zj8vxnqaiqaeiutgi7pphk4p0nbtrekg-gcpdrzsnlxihqhxgb7vszqlo',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final urlPago = data['data']['url'];

        if (await canLaunch(urlPago)) {
          await launch(urlPago);

          // Crear factura después de la aprobación
          await _crearFactura(data);
        } else {
          _mostrarDialogo('No se pudo abrir el enlace de pago.', false);
        }
      } else {
        _mostrarDialogo('Error en el pago: ${response.body}', false);
      }
    } catch (e) {
      _mostrarDialogo('Error de red: $e', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _crearFactura(Map<String, dynamic> data) async {
    // Crear la lista de boletos con el ID correcto para cada tipo de boleto
    final listaBoletos = widget.tipoBoletos.keys.map((tipo) {
      int index = widget.tipoBoletos.keys.toList().indexOf(tipo);
      var idTipoBoleto = widget.idTipoBoletos.isNotEmpty ? widget.idTipoBoletos[index] : '';

      // Verifica si el idTipoBoleto es un número
      if (idTipoBoleto == '' || int.tryParse(idTipoBoleto) == null) {
        print('ID de tipo de boleto inválido para el tipo $tipo: $idTipoBoleto');
      }

      return {
        'id_tipo_boleto': int.tryParse(idTipoBoleto) ?? 0,
        'cantidad_boletos_comprados': widget.cantidades[tipo] ?? 0,
        'precio_unitario': widget.precioPorBoleto[tipo] ?? 0.0,
        'subtotal': (widget.precioPorBoleto[tipo] ?? 0) * (widget.cantidades[tipo] ?? 0),
      };
    }).toList();

    // Crear el cuerpo de la solicitud de la factura
    final facturaData = {
      'id_user': widget.idUser,
      'id_evento': widget.idEvento,
      'nombre': widget.nombre,
      'apellido': widget.apellido,
      'correo': widget.correo,
      'direccion': widget.direccion,
      'cedula': widget.cedula,
      'telefono': widget.phone,
      'total': widget.subtotalSinIva + widget.iva + 0.40,
      'boletos': listaBoletos,
      'detalles_pago': {
        'concepto': 'Pago del evento ${widget.nombreEvento}',
        'tarjeta': data['data']['tarjeta'] ?? 'No disponible',
        'tarjetahabiente': data['data']['tarjetahabiente'] ?? 'No disponible',
        'autorizacion': data['data']['autorizacion'] ?? 'No disponible',
        'modo_pago': data['data']['modo_pago'] ?? 'En linea',
        'cuotas': data['data']['cuotas'] ?? 0,
        'lote': data['data']['lote'] ?? 'No disponible',
        'id_user': data['data']['id_cliente'] ?? 'No disponible',
      },
    };

    final url = Uri.parse('http://192.168.3.36:3000/api/facturas/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(facturaData),
      );

      if (response.statusCode == 201) {
        print('Factura creada con éxito');
      } else {
        _mostrarDialogo('Error al crear la factura: ${response.body}', false);
      }
    } catch (e) {
      _mostrarDialogo('Error al crear la factura: $e', false);
    }
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
                color: esExito ? Colors.greenAccent : Colors.red,
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(mensaje)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
