import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/movimiento.dart';

class MovimientoProvider with ChangeNotifier {
  final List<Movimiento> _movimientos = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Movimiento> get movimientos => _movimientos;

  /// Cargar todos los movimientos desde la base de datos
  Future<void> cargarMovimientos() async {
    try {
      final movimientos = await _dbHelper.getMovimientos();
      _movimientos.clear();
      _movimientos.addAll(movimientos);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al cargar movimientos: $e');
    }
  }

  /// Agregar un nuevo movimiento
  Future<void> agregarMovimiento(Movimiento movimiento) async {
    try {
      await _dbHelper.insertMovimiento(movimiento);
      _movimientos.add(movimiento);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al agregar movimiento: $e');
    }
  }

  /// Actualizar un movimiento existente
  Future<void> actualizarMovimiento(Movimiento movimiento) async {
    try {
      await _dbHelper.updateMovimiento(movimiento);
      final index = _movimientos.indexWhere((m) => m.id == movimiento.id);
      if (index != -1) {
        _movimientos[index] = movimiento;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error al actualizar movimiento: $e');
    }
  }

  /// Eliminar un movimiento
  Future<void> eliminarMovimiento(int id) async {
    try {
      await _dbHelper.deleteMovimiento(id);
      _movimientos.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al eliminar movimiento: $e');
    }
  }

  /// Filtrar movimientos por producto
  Future<void> filtrarMovimientosPorProducto(int productoId) async {
    try {
      final movimientos = await _dbHelper.getMovimientos(
        productoId: productoId,
      );
      _movimientos.clear();
      _movimientos.addAll(movimientos);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al filtrar movimientos: $e');
    }
  }

  /// Registrar un movimiento y actualizar el stock del producto
  Future<void> registrarMovimiento(Movimiento movimiento) async {
    try {
      // Insertar el movimiento en la base de datos
      await _dbHelper.insertMovimiento(movimiento);

      // Actualizar el stock del producto
      final producto = await _dbHelper.getProductoById(movimiento.productoId);
      if (movimiento.tipo == 'entrada') {
        producto.cantidad += movimiento.cantidad;
      } else if (movimiento.tipo == 'salida') {
        producto.cantidad -= movimiento.cantidad;
        if (producto.cantidad < 0) {
          throw Exception('El stock no puede ser negativo.');
        }
      }
      await _dbHelper.updateProducto(producto);

      // Actualizar la lista de movimientos
      _movimientos.add(movimiento);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al registrar movimiento: $e');
    }
  }
}
