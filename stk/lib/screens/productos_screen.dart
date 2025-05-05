import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/producto_provider.dart';
import '../providers/stock_bajo_provider.dart';
import '../models/producto.dart';

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los productos y actualizar el stock bajo al iniciar la pantalla
    Future.microtask(() {
      Provider.of<ProductoProvider>(context, listen: false).cargarProductos();
      Provider.of<StockBajoProvider>(
        context,
        listen: false,
      ).actualizarProductosConStockBajo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Productos'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ProductoProvider>(
              builder: (context, productoProvider, child) {
                final productos = productoProvider.productos;

                if (productos.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay productos registrados',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blueAccent
                                      .withOpacity(0.2),
                                  child: Icon(
                                    Icons.inventory,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    producto.nombre,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.cyan,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        _mostrarFormularioProducto(
                                          context,
                                          producto: producto,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        if (producto.id == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'El producto no tiene un ID válido',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        try {
                                          await Provider.of<ProductoProvider>(
                                            context,
                                            listen: false,
                                          ).eliminarProducto(producto.id!);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Producto eliminado',
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildProductDetail(
                                  label: 'Descripción',
                                  value:
                                      producto.descripcion.isNotEmpty
                                          ? producto.descripcion
                                          : 'N/A',
                                  valueColor: Colors.grey[800],
                                ),
                                _buildProductDetail(
                                  label: 'Precio',
                                  value:
                                      '\$${producto.precio.toStringAsFixed(2)}',
                                  valueColor: Colors.green,
                                ),
                                _buildProductDetail(
                                  label: 'Categoría',
                                  value: producto.categoria,
                                  valueColor: Colors.teal,
                                ),
                                _buildProductDetail(
                                  label: 'Cantidad',
                                  value: '${producto.cantidad}',
                                  valueColor: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Tarjeta de Alertas de Stock Bajo
          Consumer<StockBajoProvider>(
            builder: (context, stockBajoProvider, child) {
              final alertasStockBajo =
                  stockBajoProvider.totalProductosConStockBajo;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.warning, size: 40, color: Colors.red),
                  title: Text(
                    'Alertas de Stock Bajo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$alertasStockBajo productos con stock bajo',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/stock-bajo');
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para agregar un nuevo producto
          _mostrarFormularioProducto(context);
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductDetail({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  void _mostrarFormularioProducto(BuildContext context, {Producto? producto}) {
    final _nombreController = TextEditingController(
      text: producto != null ? producto.nombre : '',
    );
    final _descripcionController = TextEditingController(
      text: producto != null ? producto.descripcion : '',
    );
    final _cantidadController = TextEditingController(
      text: producto != null ? producto.cantidad.toString() : '',
    );
    final _precioController = TextEditingController(
      text: producto != null ? producto.precio.toString() : '',
    );
    final _categoriaController = TextEditingController(
      text: producto != null ? producto.categoria : '',
    );
    final _umbralController = TextEditingController(
      text: producto != null ? producto.umbralStockBajo.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            producto == null ? 'Agregar Producto' : 'Editar Producto',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _descripcionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: _cantidadController,
                  decoration: InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _precioController,
                  decoration: InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _categoriaController,
                  decoration: InputDecoration(labelText: 'Categoría'),
                ),
                TextField(
                  controller: _umbralController,
                  decoration: InputDecoration(
                    labelText: 'Umbral de Stock Bajo',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final productoProvider = Provider.of<ProductoProvider>(
                  context,
                  listen: false,
                );

                // Validar entradas
                if (_nombreController.text.isEmpty ||
                    _cantidadController.text.isEmpty ||
                    _precioController.text.isEmpty ||
                    _umbralController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, completa todos los campos'),
                    ),
                  );
                  return;
                }

                final nuevoProducto = Producto(
                  id: producto?.id,
                  nombre: _nombreController.text,
                  descripcion: _descripcionController.text,
                  cantidad: int.parse(_cantidadController.text),
                  precio: double.parse(_precioController.text),
                  categoria: _categoriaController.text,
                  umbralStockBajo: int.parse(_umbralController.text),
                );

                try {
                  if (producto == null) {
                    await productoProvider.agregarProducto(nuevoProducto);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Producto agregado')),
                    );
                  } else {
                    await productoProvider.actualizarProducto(nuevoProducto);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Producto actualizado')),
                    );
                  }
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text(producto == null ? 'Agregar' : 'Actualizar'),
            ),
          ],
        );
      },
    );
  }
}
