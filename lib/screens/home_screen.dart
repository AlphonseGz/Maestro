import 'package:flutter/material.dart';

import '../widgets/maestro_bottom_nav.dart';
import '../widgets/maestro_header.dart';
import 'materias_screen.dart';

/// Pantalla principal de Maestro.
///
/// Muestra el encabezado y la barra inferior. Según la pestaña
/// seleccionada, cambia el contenido central con IndexedStack:
/// mantiene vivas las 3 pantallas y solo muestra la activa,
/// así la lista de Materias no se pierde al cambiar de pestaña.
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

  /// Método que se ejecuta al pulsar un botón de la barra.
  /// [index] es el número de la pestaña pulsada.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Pantalla temporal para To do y Profile hasta que las desarrollemos.
  Widget _pantallaEnConstruccion(IconData icono, String titulo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(
            titulo,
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
    );
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
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _pantallaEnConstruccion(Icons.check_circle_outline, 'To do'),
                  _pantallaEnConstruccion(Icons.person_outline, 'Profile'),
                  const MateriasScreen(),
                ],
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
