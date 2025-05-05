class Producto {
  final int? id;
  final String nombre;
  final String descripcion;
  int cantidad;
  final double precio;
  final String categoria;
  final int umbralStockBajo;
  final String? imagen; // Opcional

  Producto({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantidad,
    required this.precio,
    required this.categoria,
    required this.umbralStockBajo,
    this.imagen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'precio': precio,
      'categoria': categoria,
      'umbralStockBajo': umbralStockBajo,
      'imagen': imagen,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      cantidad: map['cantidad'],
      precio: map['precio'],
      categoria: map['categoria'],
      umbralStockBajo: map['umbralStockBajo'],
      imagen: map['imagen'],
    );
  }
}
