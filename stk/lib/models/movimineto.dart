class Movimiento {
  final int? id;
  final int productoId;
  final String tipo; // "entrada" o "salida"
  final int cantidad;
  final DateTime fecha;
  final String observacion;

  Movimiento({
    this.id,
    required this.productoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    required this.observacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productoId': productoId,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
      'observacion': observacion,
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'],
      productoId: map['productoId'],
      tipo: map['tipo'],
      cantidad: map['cantidad'],
      fecha: DateTime.parse(map['fecha']),
      observacion: map['observacion'],
    );
  }
}
