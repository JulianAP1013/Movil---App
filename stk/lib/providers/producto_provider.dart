import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/producto.dart';
import 'stock_bajo_provider.dart';
import 'package:provider/provider.dart';

class ProductoProvider with ChangeNotifier {
  final List<Producto> _productos = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  ProductoProvider() {
    cargarProductos(); // Carga los productos automáticamente al crear el provider
  }

  List<Producto> get productos => _productos;

  List<Producto> get productosConStockBajo {
    return _productos
        .where((producto) => producto.cantidad <= producto.umbralStockBajo)
        .toList();
  }

  Future<void> cargarProductos() async {
    try {
      final productos = await _dbHelper.getProductos();
      _productos.clear();
      _productos.addAll(productos);
      notifyListeners(); // Notifica a los listeners después de cargar los productos
    } catch (e) {
      print('Error al cargar productos: $e');
    }
  }

  Future<void> agregarProducto(Producto producto) async {
    try {
      await _dbHelper.insertProducto(producto);
      _productos.add(producto);
      notifyListeners(); // Notifica a los listeners después de agregar un producto
    } catch (e) {
      print('Error al agregar producto: $e');
    }
  }

  Future<void> actualizarProducto(Producto producto) async {
    try {
      await _dbHelper.updateProducto(producto);
      final index = _productos.indexWhere((p) => p.id == producto.id);
      if (index != -1) {
        _productos[index] = producto;
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar producto: $e');
    }
  }

  Future<void> eliminarProducto(int id) async {
    try {
      await _dbHelper.deleteProducto(id);
      _productos.removeWhere((producto) => producto.id == id);
      notifyListeners(); // Notifica a los listeners después de eliminar un producto
    } catch (e) {
      print('Error al eliminar producto: $e');
    }
  }
}
