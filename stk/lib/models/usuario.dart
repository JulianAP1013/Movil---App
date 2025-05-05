class Usuario {
  final int? id; // Será null para nuevos usuarios
  final String nombre;
  final String correo;
  final String contrasena;

  Usuario({
    this.id,
    required this.nombre,
    required this.correo,
    required this.contrasena,
  });

  // Convertir un Usuario a un Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
    };
  }

  // Crear un Usuario desde un Map de SQLite
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      correo: map['correo'],
      contrasena: map['contrasena'],
    );
  }
}
