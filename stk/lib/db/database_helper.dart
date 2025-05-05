import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/usuario.dart';
import '../models/producto.dart';
import '../models/movimiento.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'AdminSTK.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    //Crear tabla de usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        correo TEXT NOT NULL UNIQUE,
        contrasena TEXT NOT NULL)''');

    //Crear tabla de productos
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        cantidad INTEGER NOT NULL,
        precio REAL NOT NULL,
        categoria TEXT NOT NULL,
        umbralStockBajo INTEGER NOT NULL,
        imagen TEXT
      )
    ''');

    // Crear tabla Movimiento
    await db.execute('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productoId INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        observacion TEXT,
        FOREIGN KEY (productoId) REFERENCES productos (id) ON DELETE CASCADE
      )
    ''');
  }

  // Métodos para usuarios
  Future<int> insertUsuario(Usuario usuario) async {
    final db = await database;
    return await db.insert('usuarios', usuario.toMap());
  }

  Future<Usuario?> getUsuario(String correo, String contrasena) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'correo = ? AND contrasena = ?',
      whereArgs: [correo, contrasena],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUsuario(Usuario usuario) async {
    final db = await database;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> deleteUsuario(int id) async {
    final db = await database;
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para productos
  Future<int> insertProducto(Producto producto) async {
    final db = await database;
    return await db.insert('productos', producto.toMap());
  }

  Future<List<Producto>> getProductos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('productos');

    return List.generate(maps.length, (i) {
      return Producto.fromMap(maps[i]);
    });
  }

  Future<List<Producto>> getProductosConStockBajo() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'productos',
      where: 'cantidad <= umbralStockBajo',
    );

    return List.generate(maps.length, (i) {
      return Producto.fromMap(maps[i]);
    });
  }

  Future<Producto> getProductoById(int id) async {
    final db = await database;
    final maps = await db.query('productos', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Producto.fromMap(maps.first);
    } else {
      throw Exception('Producto no encontrado');
    }
  }

  Future<int> updateProducto(Producto producto) async {
    final db = await database;
    return await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  Future<int> deleteProducto(int id) async {
    final db = await database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos para movimientos
  Future<int> insertMovimiento(Movimiento movimiento) async {
    final db = await database;
    return await db.insert(
      'movimientos',
      movimiento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Movimiento>> getMovimientos({int? productoId}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (productoId != null) {
      maps = await db.query(
        'movimientos',
        where: 'productoId = ?',
        whereArgs: [productoId],
      );
    } else {
      maps = await db.query('movimientos');
    }

    return List.generate(maps.length, (i) {
      return Movimiento.fromMap(maps[i]);
    });
  }

  Future<void> updateMovimiento(Movimiento movimiento) async {
    final db = await database;
    await db.update(
      'movimientos',
      movimiento.toMap(),
      where: 'id = ?',
      whereArgs: [movimiento.id],
    );
  }

  Future<int> deleteMovimiento(int id) async {
    final db = await database;
    return await db.delete('movimientos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eliminarBaseDeDatos() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'AdminSTK.db');
    await deleteDatabase(path);
    print('Base de datos eliminada');
  }
}
