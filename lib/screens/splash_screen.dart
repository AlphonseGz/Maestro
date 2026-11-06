import 'dart:async';

import 'package:flutter/material.dart';

import 'home_screen.dart';

/// Pantalla temporal de bienvenida (Splash Screen).
///
/// Se ve solo unos segundos al abrir la app: muestra la identidad de
/// Maestro y el mensaje Bienvenido "Concertante", y luego pasa
/// automáticamente a la pantalla principal.
///
/// Es StatefulWidget porque necesita esperar un tiempo y luego navegar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Temporizador que cuenta los segundos antes de cambiar de pantalla.
  /// Lo guardamos en una variable para poder cancelarlo en dispose()
  /// y evitar errores si la pantalla se cierra antes de tiempo.
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // initState se ejecuta una sola vez, justo al crear la pantalla.
    // Programamos el cambio de pantalla a los 4 segundos.
    _timer = Timer(const Duration(seconds: 4), _goToHome);
  }

  /// Método que navega a la pantalla principal.
  /// pushReplacement reemplaza la Splash, así el usuario no puede
  /// volver a ella con el botón atrás de Android.
  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    // dispose se ejecuta al salir de la pantalla.
    // Cancelamos el temporizador para que no intente navegar tarde.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo real de Maestro (barras morado/azul + texto MAESTRO).
            // width limita el tamaño para que no ocupe toda la pantalla.
            Image.asset(
              'assets/images/maestro_logo.png',
              width: 280,
            ),
            const SizedBox(height: 24),
            const Text(
              'Bienvenido "Concertante"',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFF8B3DFF),
            ),
          ],
        ),
      ),
    );
  }
}
