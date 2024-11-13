class Evento {
  String? id;
  String? nombre;
  DateTime? fecha;
  String? ubicacion;
  String? descripcion;
  String? imageUrl; // URL de la imagen del evento
  DateTime? createdAt;
  DateTime? updatedAt;
  List<TipoBoleto> tiposBoletos;

  Evento({
    this.id,
    this.nombre,
    this.fecha,
    this.ubicacion,
    this.descripcion,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    required this.tiposBoletos,
  });

  // Método para crear un Evento desde JSON
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] ?? '', // Proporcionar un valor predeterminado
      nombre: json['nombre'] ??
          'Sin nombre', // Proporcionar un valor predeterminado
      fecha: DateTime.tryParse(json['fecha'] ?? '')
          ?.toLocal(), // Convierte a hora local
      ubicacion: json['ubicacion'] ??
          'Sin ubicación', // Proporcionar un valor predeterminado
      descripcion: json['descripcion'] ??
          'Sin descripción', // Proporcionar un valor predeterminado
      imageUrl: json['imagen'] ?? '', // Proporcionar un valor predeterminado
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      tiposBoletos: (json['tiposBoletos'] as List<dynamic>?)
              ?.map((tipo) => TipoBoleto.fromJson(tipo))
              .toList() ??
          [], // Manejar casos donde tiposBoletos pueda ser null
    );
  }

  // Método para convertir un Evento a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'fecha': fecha?.toIso8601String(),
      'ubicacion': ubicacion,
      'descripcion': descripcion,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tiposBoletos': tiposBoletos.map((tipo) => tipo.toJson()).toList(),
    };
  }

  // Métodos para obtener fecha y hora formateadas
  String get fechaFormateada =>
      "${fecha?.year}-${fecha?.month.toString().padLeft(2, '0')}-${fecha?.day.toString().padLeft(2, '0')}";
  String get horaFormateada =>
      "${fecha?.hour.toString().padLeft(2, '0')}:${fecha?.minute.toString().padLeft(2, '0')}";
}

// Clase TipoBoleto para representar el tipo de boleto asociado a un evento
class TipoBoleto {
  String? id;
  
  String nombre_tipo;
  double? precio; 
  int cantidad_disponible;

  TipoBoleto({
    this.id,
    required this.nombre_tipo,
    this.precio,
    required this.cantidad_disponible,
  });

  // Método para crear un TipoBoleto desde JSON
  factory TipoBoleto.fromJson(Map<String, dynamic> json) {
    // Convierte el precio a double si es una cadena
    double precio = (json['precio'] != null && json['precio'] is String)
        ? double.tryParse(json['precio']) ?? 0.0
        : (json['precio'] as num?)?.toDouble() ?? 0.0;

    return TipoBoleto(
      id: json['id'],
      nombre_tipo: json['nombre_tipo'] ?? 'Sin nombre',
      precio: precio,
      cantidad_disponible: json['cantidad_disponible'] ?? 0,
    );
  }

  // Método para convertir un TipoBoleto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_tipo': nombre_tipo,
      'precio': precio ?? 0.0,
      'cantidad_disponible': cantidad_disponible,
    };
  }

  toMap() {}
}
