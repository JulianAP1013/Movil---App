import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/producto_provider.dart';
import '../providers/stock_bajo_provider.dart';
import '../providers/usuario_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen del Inventario'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Limpiar el usuarioId en UsuarioProvider
              Provider.of<UsuarioProvider>(
                context,
                listen: false,
              ).setUsuarioId(null);

              // Redirigir al usuario a la pantalla de inicio de sesión
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer2<ProductoProvider, StockBajoProvider>(
            builder: (context, productoProvider, stockBajoProvider, child) {
              final totalProductos = productoProvider.productos.length;
              final alertasStockBajo =
                  stockBajoProvider.totalProductosConStockBajo;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    context,
                    icon: Icons.inventory,
                    iconColor: Colors.blue,
                    title: 'Total de Productos',
                    subtitle: '$totalProductos productos registrados',
                    buttonLabel: 'Ver Productos',
                    onTap: () {
                      Navigator.pushNamed(context, '/productos');
                    },
                  ),
                  SizedBox(height: 16),
                  _buildCard(
                    context,
                    icon: Icons.bar_chart,
                    iconColor: Colors.blue,
                    title: 'Reportes Mensuales',
                    subtitle:
                        'Consulta el balance mensual de entradas y salidas',
                    buttonLabel: 'Ver Reportes',
                    onTap: () {
                      Navigator.pushNamed(context, '/reportes');
                    },
                  ),
                  SizedBox(height: 16),
                  _buildCard(
                    context,
                    icon: Icons.history,
                    iconColor: Colors.green,
                    title: 'Historial de Movimientos',
                    subtitle: 'Consulta los movimientos de inventario',
                    buttonLabel: 'Ver Historial',
                    onTap: () {
                      Navigator.pushNamed(context, '/movimientos');
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
