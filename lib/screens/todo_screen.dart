import 'package:flutter/material.dart';

import '../models/materia.dart';
import '../models/tarea.dart';
import '../models/unidad.dart';
import '../services/materia_storage.dart';
import '../utils/fecha_formato.dart';
import '../widgets/formulario_tarea_dialog.dart';
import '../widgets/tarea_card.dart';

/// Una tarea junto con su materia y su unidad, para poder dibujar
/// la tarjeta con el color de la materia y el ícono de la unidad
/// sin buscarlos de nuevo.
class _TareaCompleta {
  _TareaCompleta({
    required this.tarea,
    required this.materia,
    required this.unidad,
  });

  final Tarea tarea;
  final Materia materia;
  final Unidad unidad;
}

/// Pantalla To do: todas las tareas de todas las materias/unidades,
/// ordenadas por fecha límite (la que vence antes, primera)
/// y agrupadas por día con un encabezado de fecha.
///
/// Es StatefulWidget porque la lista cambia al completar,
/// editar o eliminar tareas. Se recarga al entrar a la pestaña
/// llamando [recargarTareas] desde HomeScreen.
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> {
  /// Todas las materias cargadas, para poder guardar cambios
  /// (completar/editar/eliminar) en el teléfono.
  List<Materia> _materias = [];

  /// Todas las tareas aplanadas y ordenadas por fecha.
  List<_TareaCompleta> _tareasOrdenadas = [];

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    recargarTareas();
  }

  /// Carga las materias desde el teléfono, aplana sus tareas,
  /// las ordena por fecha límite y redibuja.
  /// La llama HomeScreen cada vez que entras a la pestaña To do,
  /// así siempre ves lo último creado en las unidades.
  Future<void> recargarTareas() async {
    final List<Materia> guardadas = await MateriaStorage.cargarMaterias();
    if (!mounted) return;
    setState(() {
      _materias = guardadas;
      _tareasOrdenadas = _aplanarYOrdenar(guardadas);
      _cargando = false;
    });
  }

  /// Convierte la lista de materias en una sola lista de tareas
  /// ordenada de la fecha más cercana (antes) a la más lejana.
  List<_TareaCompleta> _aplanarYOrdenar(List<Materia> materias) {
    final List<_TareaCompleta> todas = [];
    for (final Materia materia in materias) {
      for (final Unidad unidad in materia.unidades) {
        for (final Tarea tarea in unidad.tareas) {
          todas.add(
            _TareaCompleta(tarea: tarea, materia: materia, unidad: unidad),
          );
        }
      }
    }
    todas.sort((a, b) => a.tarea.fechaLimite.compareTo(b.tarea.fechaLimite));
    return todas;
  }

  /// Agrupa las tareas ordenadas por día: devuelve una lista de
  /// días (solo fecha) en orden, cada uno con sus tareas.
  Map<DateTime, List<_TareaCompleta>> _agruparPorDia() {
    final Map<DateTime, List<_TareaCompleta>> grupos = {};
    for (final _TareaCompleta item in _tareasOrdenadas) {
      final DateTime dia = soloDia(item.tarea.fechaLimite);
      // putIfAbsent crea la lista del día si aún no existe.
      grupos.putIfAbsent(dia, () => []).add(item);
    }
    return grupos;
  }

  Future<void> _alternarCompletada(_TareaCompleta item) async {
    setState(() {
      item.tarea.completada = !item.tarea.completada;
    });
    await MateriaStorage.guardarMaterias(_materias);
  }

  Future<void> _editarTarea(_TareaCompleta item) async {
    final Tarea? editada = await showDialog<Tarea>(
      context: context,
      builder: (context) => FormularioTarea(tareaExistente: item.tarea),
    );
    if (editada == null) return;
    setState(() {
      final int indice = item.unidad.tareas.indexWhere(
        (t) => t.id == item.tarea.id,
      );
      if (indice != -1) item.unidad.tareas[indice] = editada;
      // Al cambiar la fecha, el orden puede cambiar: reordenamos.
      _tareasOrdenadas = _aplanarYOrdenar(_materias);
    });
    await MateriaStorage.guardarMaterias(_materias);
  }

  Future<void> _eliminarTarea(_TareaCompleta item) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${item.tarea.titulo}"?'),
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
      item.unidad.tareas.removeWhere((t) => t.id == item.tarea.id);
      _tareasOrdenadas = _aplanarYOrdenar(_materias);
    });
    await MateriaStorage.guardarMaterias(_materias);
  }

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, List<_TareaCompleta>> grupos = _agruparPorDia();
    final List<DateTime> diasOrdenados = grupos.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0F2E),
        foregroundColor: Colors.white,
        title: const Text(
          'To do',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B3DFF)),
            )
          : _tareasOrdenadas.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white54,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tienes tareas',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crea una tarea desde una unidad',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: diasOrdenados.length,
              itemBuilder: (context, indexDia) {
                final DateTime dia = diasOrdenados[indexDia];
                final List<_TareaCompleta> tareasDelDia = grupos[dia]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado del día, como en la foto.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        formatearFechaLarga(dia),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    for (final _TareaCompleta item in tareasDelDia)
                      TareaCard(
                        tarea: item.tarea,
                        colorMateria: item.materia.color,
                        nombreMateria: item.materia.titulo,
                        iconoUnidad: Unidad.iconoPorClave(
                          item.unidad.iconoClave,
                        ),
                        onToggleCompletada: () => _alternarCompletada(item),
                        onEdit: () => _editarTarea(item),
                        onDelete: () => _eliminarTarea(item),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
