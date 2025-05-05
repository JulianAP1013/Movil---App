import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movimiento_provider.dart';
import '../providers/producto_provider.dart';
import '../models/movimiento.dart';
import '../models/producto.dart';

class MovimientosScreen extends StatefulWidget {
  @override
  _MovimientosScreenState createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los movimientos al iniciar la pantalla
    Future.microtask(
      () =>
          Provider.of<MovimientoProvider>(
            context,
            listen: false,
          ).cargarMovimientos(),
    );
  }

  void _mostrarFormularioMovimiento(BuildContext context) {
    final _cantidadController = TextEditingController();
    final _observacionController = TextEditingController();
    String tipoMovimiento = 'entrada';
    Producto? productoSeleccionado;

    showDialog(
      context: context,
      builder: (context) {
        final productoProvider = Provider.of<ProductoProvider>(context);
        final productos = productoProvider.productos;

        return AlertDialog(
          title: Text('Registrar Movimiento'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<Producto>(
                  value: productoSeleccionado,
                  items:
                      productos.map((producto) {
                        return DropdownMenuItem(
                          value: producto,
                          child: Text(producto.nombre),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      productoSeleccionado = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Producto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tipoMovimiento,
                  items:
                      ['entrada', 'salida'].map((tipo) {
                        return DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.toUpperCase()),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      tipoMovimiento = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Tipo de Movimiento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _cantidadController,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _observacionController,
                  decoration: InputDecoration(
                    labelText: 'Observación',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                if (productoSeleccionado == null ||
                    _cantidadController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, completa todos los campos'),
                    ),
                  );
                  return;
                }

                final movimiento = Movimiento(
                  productoId: productoSeleccionado!.id!,
                  tipo: tipoMovimiento,
                  cantidad: int.parse(_cantidadController.text),
                  fecha: DateTime.now(),
                  observacion: _observacionController.text,
                );

                try {
                  await Provider.of<MovimientoProvider>(
                    context,
                    listen: false,
                  ).registrarMovimiento(movimiento);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Movimiento registrado con éxito')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Movimientos'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Consumer<MovimientoProvider>(
        builder: (context, movimientoProvider, child) {
          if (movimientoProvider.movimientos.isEmpty) {
            return Center(
              child: Text(
                'No hay movimientos registrados.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: movimientoProvider.movimientos.length,
            itemBuilder: (context, index) {
              final movimiento = movimientoProvider.movimientos[index];
              final productoProvider = Provider.of<ProductoProvider>(
                context,
                listen: false,
              );
              final producto = productoProvider.productos.firstWhere(
                (p) => p.id == movimiento.productoId,
                orElse:
                    () => Producto(
                      id: 0,
                      nombre: 'Producto no encontrado',
                      descripcion: '',
                      cantidad: 0,
                      precio: 0.0,
                      categoria: '',
                      umbralStockBajo: 0,
                    ),
              );

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        movimiento.tipo == 'entrada'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    child: Icon(
                      movimiento.tipo == 'entrada'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color:
                          movimiento.tipo == 'entrada'
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  title: Text(
                    movimiento.tipo == 'entrada' ? 'Entrada' : 'Salida',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Producto: ${producto.nombre}'),
                      Text('Cantidad: ${movimiento.cantidad}'),
                      if (movimiento.observacion.isNotEmpty)
                        Text('Observación: ${movimiento.observacion}'),
                    ],
                  ),
                  trailing: Text(
                    '${movimiento.fecha.day}/${movimiento.fecha.month}/${movimiento.fecha.year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarFormularioMovimiento(context);
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}
