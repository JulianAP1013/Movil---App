import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/movimiento_provider.dart';
import 'providers/producto_provider.dart';
import 'providers/usuario_provider.dart';
import 'providers/stock_bajo_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/productos_screen.dart';
import 'screens/movimientos_screen.dart';
import 'screens/reportes_screen.dart';
import 'screens/stock_bajo_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductoProvider()),
        ChangeNotifierProvider(
          create: (_) => UsuarioProvider(),
        ), // UsuarioProvider restaurado
        ChangeNotifierProvider(
          create: (_) => MovimientoProvider(),
        ), // MovimientoProvider restaurado
        ChangeNotifierProxyProvider<ProductoProvider, StockBajoProvider>(
          create: (context) => StockBajoProvider(),
          update: (context, productoProvider, stockBajoProvider) {
            stockBajoProvider?.actualizarProductosConStockBajo();
            return stockBajoProvider!;
          },
        ),
      ],
      child: MaterialApp(
        title: 'AdminSTK',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/productos': (context) => ProductosScreen(),
          '/movimientos': (context) => MovimientosScreen(),
          '/reportes': (context) => ReportesScreen(),
          '/stock-bajo': (context) => StockBajoScreen(),
        },
      ),
    );
  }
}
