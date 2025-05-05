import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../db/database_helper.dart';

class StockBajoProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Producto> _productosConStockBajo = [];

  List<Producto> get productosConStockBajo => _productosConStockBajo;

  int get totalProductosConStockBajo => _productosConStockBajo.length;

  Future<void> cargarProductosConStockBajo() async {
    try {
      _productosConStockBajo = await _dbHelper.getProductosConStockBajo();
      notifyListeners(); // Notifica a los listeners después de cargar los datos
    } catch (e) {
      print('Error al cargar productos con stock bajo: $e');
    }
  }

  // Método para actualizar los productos con stock bajo
  void actualizarProductosConStockBajo() {
    cargarProductosConStockBajo(); // Reutiliza el método existente
  }
}
