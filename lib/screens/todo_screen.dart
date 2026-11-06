import 'package:flutter/material.dart';

import '../models/materia.dart';
import '../models/tarea.dart';
import '../models/unidad.dart';
import '../utils/fecha_formato.dart';
import '../widgets/detalle_tarea_dialog.dart';
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
/// NO carga ni guarda por su cuenta: recibe la lista compartida
/// [materias] de HomeScreen y avisa con [onChanged] al cambiar algo.
/// Así no existen copias desactualizadas que se pisen entre pantallas.
class TodoScreen extends StatefulWidget {
  const TodoScreen({
    super.key,
    required this.materias,
    required this.onChanged,
  });

  /// Lista compartida de materias (la misma que usa Materias).
  final List<Materia> materias;

  /// Avisa a HomeScreen para guardar en el teléfono y redibujar.
  final Future<void> Function() onChanged;

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
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
  Map<DateTime, List<_TareaCompleta>> _agruparPorDia(
    List<_TareaCompleta> tareasOrdenadas,
  ) {
    final Map<DateTime, List<_TareaCompleta>> grupos = {};
    for (final _TareaCompleta item in tareasOrdenadas) {
      final DateTime dia = soloDia(item.tarea.fechaLimite);
      // putIfAbsent crea la lista del día si aún no existe.
      grupos.putIfAbsent(dia, () => []).add(item);
    }
    return grupos;
  }

  Future<void> _mostrarDetalle(_TareaCompleta item) async {
    await showDialog<void>(
      context: context,
      builder: (context) => DetalleTareaDialog(
        tarea: item.tarea,
        nombreMateria: item.materia.titulo,
        nombreUnidad: item.unidad.nombre,
      ),
    );
  }

  Future<void> _alternarCompletada(_TareaCompleta item) async {
    item.tarea.completada = !item.tarea.completada;
    // Guarda la lista compartida (HomeScreen redibuja todo).
    await widget.onChanged();
  }

  Future<void> _editarTarea(_TareaCompleta item) async {
    final Tarea? editada = await showDialog<Tarea>(
      context: context,
      builder: (context) => FormularioTarea(tareaExistente: item.tarea),
    );
    if (editada == null) return;
    final int indice = item.unidad.tareas.indexWhere(
      (t) => t.id == item.tarea.id,
    );
    if (indice != -1) item.unidad.tareas[indice] = editada;
    await widget.onChanged();
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
    item.unidad.tareas.removeWhere((t) => t.id == item.tarea.id);
    await widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    // Se calcula en cada build desde la lista compartida,
    // así siempre refleja lo último sin recargar del teléfono.
    final List<_TareaCompleta> tareasOrdenadas = _aplanarYOrdenar(
      widget.materias,
    );
    final Map<DateTime, List<_TareaCompleta>> grupos = _agruparPorDia(
      tareasOrdenadas,
    );
    final List<DateTime> diasOrdenados = grupos.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0F2E),
        foregroundColor: Colors.white,
        title: const Text(
          'To Do list',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: tareasOrdenadas.isEmpty
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
                        onTap: () => _mostrarDetalle(item),
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
