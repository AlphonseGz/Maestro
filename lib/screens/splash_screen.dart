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
    // Programamos el cambio de pantalla a los 2 segundos.
    _timer = Timer(const Duration(seconds: 2), _goToHome);
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
            const Icon(
              Icons.music_note,
              size: 72,
              color: Color(0xFF8B3DFF),
            ),
            const SizedBox(height: 16),
            const Text(
              'MAESTRO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
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
