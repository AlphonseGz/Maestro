import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'services/notificacion_service.dart';

/// Punto de entrada de la app.
///
/// Ahora es async porque inicializa las notificaciones locales
/// (y la zona horaria) antes de arrancar la interfaz.
/// WidgetsFlutterBinding asegura que los plugins estén listos.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacionService.inicializar();
  runApp(const MaestroApp());
}

/// Widget raíz de la aplicación Maestro🎶.
///
/// Es StatelessWidget porque solo sirve para configurar la app:
/// título, tema de colores y pantalla inicial. No guarda estado propio.
class MaestroApp extends StatelessWidget {
  const MaestroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maestro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1A0F2E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B3DFF),
          secondary: Color(0xFF2D5BFF),
          surface: Color(0xFF1A0F2E),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
