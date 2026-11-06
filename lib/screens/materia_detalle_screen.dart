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

  /// Edita la unidad seleccionada reutilizando el mismo formulario,
  /// precargado con su nombre e ícono actuales.
  Future<void> _editarUnidad() async {
    final Unidad unidadActual = widget.materia.unidades[_selectedUnitIndex];
    final Unidad? editada = await showDialog<Unidad>(
      context: context,
      builder: (context) => _FormularioUnidad(unidadExistente: unidadActual),
    );
    if (editada == null) return;
    setState(() {
      widget.materia.unidades[_selectedUnitIndex] = editada;
    });
    widget.onChanged();
  }

  /// Elimina la unidad seleccionada tras pedir confirmación.
  Future<void> _eliminarUnidad() async {
    final Unidad unidadActual = widget.materia.unidades[_selectedUnitIndex];
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar unidad'),
        content: Text('¿Eliminar "${unidadActual.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    setState(() {
      widget.materia.unidades.removeAt(_selectedUnitIndex);
      // Si borramos la última, seleccionamos la anterior (o 0 si vacía).
      if (_selectedUnitIndex >= widget.materia.unidades.length) {
        _selectedUnitIndex = widget.materia.unidades.isEmpty
            ? 0
            : widget.materia.unidades.length - 1;
      }
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
                    onEdit: _editarUnidad,
                    onDelete: _eliminarUnidad,
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
  const _ContenidoUnidad({required this.unidad, this.onEdit, this.onDelete});

  final Unidad unidad;

  /// Qué hacer al elegir Editar en los 3 puntos de la unidad.
  final VoidCallback? onEdit;

  /// Qué hacer al elegir Eliminar en los 3 puntos de la unidad.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
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
        ),
        // Menú de 3 puntos en la esquina superior derecha del contenido.
        Positioned(
          top: 4,
          right: 4,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF241340),
            onSelected: (value) {
              if (value == 'editar') onEdit?.call();
              if (value == 'eliminar') onDelete?.call();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Editar', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Diálogo para crear o editar una unidad: pide nombre e ícono.
/// Si [unidadExistente] no es null, viene precargado para editar.
/// Devuelve una Unidad, o null si se cancela.
class _FormularioUnidad extends StatefulWidget {
  const _FormularioUnidad({this.unidadExistente});

  final Unidad? unidadExistente;

  @override
  State<_FormularioUnidad> createState() => _FormularioUnidadState();
}

class _FormularioUnidadState extends State<_FormularioUnidad> {
  late final TextEditingController _nombreController;

  /// Clave del ícono elegido. Por defecto 'punto',
  /// o el ícono actual si estamos editando.
  late String _iconoClaveElegida;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.unidadExistente?.nombre ?? '',
    );
    _iconoClaveElegida = widget.unidadExistente?.iconoClave ?? 'punto';
  }

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
    final bool esEdicion = widget.unidadExistente != null;
    return AlertDialog(
      title: Text(esEdicion ? 'Editar unidad' : 'Nueva unidad'),
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
        ElevatedButton(
          onPressed: _guardarUnidad,
          child: Text(esEdicion ? 'Guardar' : 'Añadir'),
        ),
      ],
    );
  }
}
