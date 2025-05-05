import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/usuario.dart';

class UsuarioProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Usuario? _usuarioActual;
  int? _usuarioId;

  Usuario? get usuarioActual => _usuarioActual;
  int? get usuarioId => _usuarioId;

  Future<void> iniciarSesion(String correo, String contrasena) async {
    final usuario = await _dbHelper.getUsuario(correo, contrasena);
    if (usuario != null) {
      _usuarioActual = usuario;
      notifyListeners();
    } else {
      throw Exception('Usuario o contraseña incorrectos');
    }
  }

  Future<void> registrarUsuario(Usuario usuario) async {
    await _dbHelper.insertUsuario(usuario);
  }

  void cerrarSesion() {
    _usuarioActual = null;
    notifyListeners();
  }

  void setUsuarioId(int? id) {
    _usuarioId = id;
    notifyListeners();
  }
}
