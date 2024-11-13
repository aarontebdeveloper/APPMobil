class Factura {
  static const String idKey = 'id';
  static const String idUserKey = 'id_user';
  static const String idEventoKey = 'id_evento';
  static const String nombreKey = 'nombre';
  static const String apellidoKey = 'apellido';
  static const String correoKey = 'correo';
  static const String direccionKey = 'direccion';
  static const String cedulaKey = 'cedula';
  static const String telefonoKey = 'telefono';
  static const String totalKey = 'total';
  static const String createdAtKey = 'created_at';
  static const String updatedAtKey = 'updated_at';
  static const String detallesKey = 'detalles';
  static const String detallesPagoKey = 'detalles_pago'; // Nuevo campo

  String? id; 
  String? idUser; 
  String? idEvento; 
  String? nombre;
  String? apellido;
  String? correo;
  String? direccion;
  String? cedula;
  String? telefono;
  double? total; 
  List<DetalleFactura> detalles; 
  DateTime? createdAt; 
  DateTime? updatedAt; 
  DetallePago? detallesPago; // Campo para la información del pago

  Factura({
    this.id,
    this.idUser,
    this.idEvento,
    this.nombre,
    this.apellido,
    this.correo,
    this.direccion,
    this.cedula,
    this.telefono,
    this.total,
    required this.detalles,
    required this.createdAt,
    this.updatedAt,
    this.detallesPago, // Inicialización
  });

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      id: json[idKey],
      idUser: json[idUserKey],
      idEvento: json[idEventoKey],
      nombre: json[nombreKey],
      apellido: json[apellidoKey],
      correo: json[correoKey],
      direccion: json[direccionKey],
      cedula: json[cedulaKey],
      telefono: json[telefonoKey],
      total: json[totalKey]?.toDouble(),
      detalles: (json[detallesKey] as List)
          .map((detalle) => DetalleFactura.fromJson(detalle))
          .toList(),
      createdAt: DateTime.tryParse(json[createdAtKey]) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json[updatedAtKey]), 
      detallesPago: json[detallesPagoKey] != null 
          ? DetallePago.fromJson(json[detallesPagoKey]) 
          : null, // Mapeo del objeto de pago
    );
  }

  Map<String, dynamic> toJson() {
    return {
      idKey: id,
      idUserKey: idUser,
      idEventoKey: idEvento,
      nombreKey: nombre,
      apellidoKey: apellido,
      correoKey: correo,
      direccionKey: direccion,
      cedulaKey: cedula,
      telefonoKey: telefono,
      totalKey: total,
      detallesKey: detalles.map((detalle) => detalle.toJson()).toList(),
      createdAtKey: createdAt?.toIso8601String(),
      updatedAtKey: updatedAt?.toIso8601String(),
      detallesPagoKey: detallesPago?.toJson(), // Serialización del objeto de pago
    };
  }
}

class DetalleFactura {
  String? id; 
  String idFactura; 
  String idTipoBoleto; 
  double precio; 
  int cantidad; 
  double subtotal;

  DetalleFactura({
    this.id,
    required this.idFactura,
    required this.idTipoBoleto,
    required this.precio,
    required this.cantidad,
    required this.subtotal,
  });

  factory DetalleFactura.fromJson(Map<String, dynamic> json) {
    return DetalleFactura(
      id: json['id'],
      idFactura: json['id_factura'],
      idTipoBoleto: json['id_tipo_boleto'], // Debe ser un ID
      precio: json['precio_unitario'].toDouble(),
      cantidad: json['cantidad_boletos_comprados'], 
      subtotal: json['subtotal'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_factura': idFactura,
      'id_tipo_boleto': idTipoBoleto, // Debe ser un ID
      'precio_unitario': precio,
      'cantidad_boletos_comprados': cantidad, 
      'subtotal': subtotal, 
    };
  }
}

class DetallePago {
  String? id;
  String idFactura;              // ID de la factura asociada
  String concepto;              // Concepto del pago
  String tarjeta;               // Número de tarjeta (puedes enmascarar si es necesario)
  String tarjetahabiente;       // Nombre del tarjetahabiente
  String autorizacion;          // Número de autorización
  String modoPago;              // Modo de pago (ej. "CORRIENTE")
  int cuotas;                   // Cuotas
  String lote;                  // Número de lote
  String idCliente;             // ID del cliente
  DateTime createdAt;           // Fecha de creación
  DateTime updatedAt;           // Fecha de actualización

  DetallePago({
    this.id,
    required this.idFactura,
    required this.concepto,
    required this.tarjeta,
    required this.tarjetahabiente,
    required this.autorizacion,
    required this.modoPago,
    required this.cuotas,
    required this.lote,
    required this.idCliente,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DetallePago.fromJson(Map<String, dynamic> json) {
    return DetallePago(
      id: json['id'],
      idFactura: json['id_factura'],
      concepto: json['concepto'],
      tarjeta: json['tarjeta'],
      tarjetahabiente: json['tarjetahabiente'],
      autorizacion: json['autorizacion'],
      modoPago: json['modo_pago'],
      cuotas: json['cuotas'],
      lote: json['lote'],
      idCliente: json['id_cliente'],
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_factura': idFactura,
      'concepto': concepto,
      'tarjeta': tarjeta,
      'tarjetahabiente': tarjetahabiente,
      'autorizacion': autorizacion,
      'modo_pago': modoPago,
      'cuotas': cuotas,
      'lote': lote,
      'id_cliente': idCliente,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
