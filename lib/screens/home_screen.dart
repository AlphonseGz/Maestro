import 'package:flutter/material.dart';

import '../models/materia.dart';
import '../services/materia_storage.dart';
import '../widgets/maestro_bottom_nav.dart';
import '../widgets/maestro_header.dart';
import 'materias_screen.dart';
import 'todo_screen.dart';

/// Pantalla principal de Maestro.
///
/// Es la ÚNICA dueña de la lista de materias: la carga una vez
/// desde el teléfono y la pasa a To do y a Materias. Así ambas
/// pantallas comparten los mismos objetos en memoria y nunca
/// se pisan con copias desactualizadas (ese era el bug de las
/// fechas que volvían a cambiar al añadir una tarea).
///
/// Muestra el encabezado y la barra inferior. Según la pestaña
/// seleccionada, cambia el contenido central con IndexedStack:
/// mantiene vivas las pantallas y solo muestra la activa.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Qué pestaña está activa:
  /// 0 = To do, 1 = Profile, 2 = Materias.
  int _selectedIndex = 0;

  /// La lista compartida de materias (fuente única de verdad).
  List<Materia> _materias = [];

  /// true mientras cargamos desde el teléfono la primera vez.
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  Future<void> _cargarMaterias() async {
    final List<Materia> guardadas = await MateriaStorage.cargarMaterias();
    if (!mounted) return;
    setState(() {
      _materias = guardadas;
      _cargando = false;
    });
  }

  /// Guarda la lista compartida en el teléfono y redibuja.
  /// La llaman To do y Materias cuando cambian algo.
  Future<void> _guardarMaterias() async {
    await MateriaStorage.guardarMaterias(_materias);
    if (mounted) setState(() {});
  }

  /// Método que se ejecuta al pulsar un botón de la barra.
  /// [index] es el número de la pestaña pulsada.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Pantalla temporal para Profile hasta que la desarrollemos.
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
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B3DFF),
                      ),
                    )
                  : IndexedStack(
                      index: _selectedIndex,
                      children: [
                        TodoScreen(
                          materias: _materias,
                          onChanged: _guardarMaterias,
                        ),
                        _pantallaEnConstruccion(
                          Icons.person_outline,
                          'Profile',
                        ),
                        MateriasScreen(
                          materias: _materias,
                          onChanged: _guardarMaterias,
                        ),
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
