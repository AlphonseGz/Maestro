import 'package:flutter/material.dart';

import '../widgets/maestro_bottom_nav.dart';
import '../widgets/maestro_header.dart';

/// Pantalla principal de Maestro.
///
/// Muestra el encabezado y la barra inferior. Según la pestaña
/// seleccionada, cambia el contenido central.
///
/// Es StatefulWidget porque el contenido cambia al pulsar la barra.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Qué pestaña está activa:
  /// 0 = To do, 1 = Profile, 2 = Materias.
  int _selectedIndex = 0;

  /// Títulos y mensajes temporales de cada pestaña.
  /// En pasos siguientes cada uno será su propia pantalla.
  final List<String> _pageTitles = ['To do', 'Profile', 'Materias'];

  /// Método que se ejecuta al pulsar un botón de la barra.
  /// [index] es el número de la pestaña pulsada.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F2E),
      body: SafeArea(
        child: Column(
          children: [
            const MaestroHeader(),
            // Expanded hace que el contenido ocupe todo el espacio
            // disponible entre el encabezado y la barra inferior.
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedIndex == 0
                          ? Icons.check_circle_outline
                          : _selectedIndex == 1
                              ? Icons.person_outline
                              : Icons.menu_book,
                      color: Colors.white54,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _pageTitles[_selectedIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pantalla en construcción',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MaestroBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
