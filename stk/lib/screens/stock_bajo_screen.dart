import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/producto_provider.dart';

class StockBajoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos con Stock Bajo'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Consumer<ProductoProvider>(
        builder: (context, productoProvider, child) {
          final productosConStockBajo =
              productoProvider.productos
                  .where(
                    (producto) => producto.cantidad <= producto.umbralStockBajo,
                  )
                  .toList();

          if (productosConStockBajo.isEmpty) {
            return Center(
              child: Text(
                'No hay productos con stock bajo.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: productosConStockBajo.length,
            itemBuilder: (context, index) {
              final producto = productosConStockBajo[index];
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
                            backgroundColor: Colors.redAccent.withOpacity(0.2),
                            child: Icon(Icons.warning, color: Colors.redAccent),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              producto.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: const Color.fromARGB(255, 247, 33, 33),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStockDetail(
                            label: 'Cantidad',
                            value: '${producto.cantidad}',
                            valueColor: Colors.blue,
                          ),
                          _buildStockDetail(
                            label: 'Umbral',
                            value: '${producto.umbralStockBajo}',
                            valueColor: Colors.black,
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
    );
  }

  Widget _buildStockDetail({
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
}
