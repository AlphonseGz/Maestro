import 'package:flutter/material.dart';

import '../models/materia.dart';
import '../models/unidad.dart';
import '../widgets/unidad_top_nav.dart';

/// Pantalla de detalle de una materia.
///
/// Muestra el encabezado con el degradado de la materia, la NavBar
/// superior con sus unidades y, si no hay unidades, un mensaje
/// indicando que hay que crear una para dividir la materia.
///
/// - [materia]: la materia seleccionada (sus unidades se editan aquí).
/// - [onChanged]: avisa a la pantalla de lista para guardar en el
///   teléfono y redibujar cuando se añade una unidad.
class MateriaDetalleScreen extends StatefulWidget {
  const MateriaDetalleScreen({
    super.key,
    required this.materia,
    required this.onChanged,
  });

  final Materia materia;
  final VoidCallback onChanged;

  @override
  State<MateriaDetalleScreen> createState() => _MateriaDetalleScreenState();
}

class _MateriaDetalleScreenState extends State<MateriaDetalleScreen> {
  /// Qué unidad está seleccionada en la NavBar superior.
  int _selectedUnitIndex = 0;

  void _onUnitTapped(int index) {
    setState(() {
      _selectedUnitIndex = index;
    });
  }

  /// Abre el diálogo para crear una unidad nueva en esta materia.
  Future<void> _abrirFormularioNuevaUnidad() async {
    final Unidad? nuevaUnidad = await showDialog<Unidad>(
      context: context,
      builder: (context) => const _FormularioUnidad(),
    );
    if (nuevaUnidad == null) return;
    setState(() {
      widget.materia.unidades.add(nuevaUnidad);
      // Al crear, seleccionamos automáticamente la nueva unidad.
      _selectedUnitIndex = widget.materia.unidades.length - 1;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        // Degradado del color de la materia detrás de la barra.
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: widget.materia.degradado),
        ),
        title: Text(
          widget.materia.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: widget.materia.unidades.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_tree_outlined,
                    color: Colors.white54,
                    size: 72,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Necesitas crear una unidad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'para dividir esta materia',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                UnidadTopNav(
                  unidades: widget.materia.unidades,
                  selectedIndex: _selectedUnitIndex,
                  onItemTapped: _onUnitTapped,
                ),
                const Divider(color: Colors.white12, height: 1),
                Expanded(
                  child: _ContenidoUnidad(
                    unidad: widget.materia.unidades[_selectedUnitIndex],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioNuevaUnidad,
        backgroundColor: const Color(0xFF8B3DFF),
        foregroundColor: Colors.white,
        tooltip: 'Añadir unidad',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Contenido temporal de la unidad seleccionada.
/// Por ahora solo muestra su ícono y nombre; el contenido
/// real (tareas, etc.) se desarrollará en pasos siguientes.
class _ContenidoUnidad extends StatelessWidget {
  const _ContenidoUnidad({required this.unidad});

  final Unidad unidad;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Unidad.iconoPorClave(unidad.iconoClave),
            color: Colors.white54,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            unidad.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contenido en construcción',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

/// Diálogo para crear una unidad: pide nombre e ícono.
/// Devuelve una Unidad, o null si se cancela.
class _FormularioUnidad extends StatefulWidget {
  const _FormularioUnidad();

  @override
  State<_FormularioUnidad> createState() => _FormularioUnidadState();
}

class _FormularioUnidadState extends State<_FormularioUnidad> {
  final TextEditingController _nombreController = TextEditingController();

  /// Clave del ícono elegido. Por defecto 'punto'.
  String _iconoClaveElegida = 'punto';

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _guardarUnidad() {
    final String nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un nombre para la unidad')),
      );
      return;
    }
    Navigator.pop(
      context,
      Unidad(nombre: nombre, iconoClave: _iconoClaveElegida),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva unidad'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej. Unidad 1: Álgebra',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Ícono', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            // Pool de 8 íconos: el elegido se encierra en un círculo.
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final IconoUnidad item in Unidad.poolIconos)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _iconoClaveElegida = item.clave;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _iconoClaveElegida == item.clave
                            ? const Color(0xFF8B3DFF)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icono,
                        color: _iconoClaveElegida == item.clave
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _guardarUnidad, child: const Text('Añadir')),
      ],
    );
  }
}
