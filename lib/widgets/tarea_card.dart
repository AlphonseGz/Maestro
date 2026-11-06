import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../utils/fecha_formato.dart';

/// Tarjeta rectangular de una tarea en la lista To do.
///
/// - Barra lateral izquierda con el color de la materia.
/// - Ícono de la unidad en un círculo suave de ese color.
/// - Hora, título, descripción visible (1 línea) y materia.
/// - Check para marcar completada (tachado) y menú 3 puntos
///   para editar/eliminar.
///
/// Es StatelessWidget porque solo dibuja: no guarda estado propio.
/// Recibe todo lo que necesita por parámetros (materia, unidad, tarea).
class TareaCard extends StatelessWidget {
  const TareaCard({
    super.key,
    required this.tarea,
    required this.colorMateria,
    required this.nombreMateria,
    required this.iconoUnidad,
    this.onToggleCompletada,
    this.onEdit,
    this.onDelete,
  });

  final Tarea tarea;

  /// Color de la materia de la que cuelga la tarea.
  final Color colorMateria;

  /// Nombre de esa materia, para mostrarlo en la tarjeta.
  final String nombreMateria;

  /// Ícono de la unidad de la que cuelga la tarea.
  final IconData iconoUnidad;

  /// Qué hacer al pulsar el check: completar/descompletar.
  final VoidCallback? onToggleCompletada;

  /// Qué hacer al elegir Editar en los 3 puntos.
  final VoidCallback? onEdit;

  /// Qué hacer al elegir Eliminar en los 3 puntos.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF241340),
        borderRadius: BorderRadius.circular(16),
      ),
      // IntrinsicHeight hace que la barra lateral ocupe todo
      // el alto de la tarjeta, aunque el texto sea corto o largo.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra lateral con el color de la materia.
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: colorMateria,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorMateria.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconoUnidad, color: colorMateria, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            // Textos: hora, título, descripción y materia.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatearHora(tarea.fechaLimite),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      tarea.titulo,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: tarea.completada
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    Text(
                      tarea.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        decoration: tarea.completada
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    Text(
                      nombreMateria,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Check de completada + menú de 3 puntos.
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  color: const Color(0xFF1A0F2E),
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
                          Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    tarea.completada
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: tarea.completada ? colorMateria : Colors.white54,
                  ),
                  tooltip: tarea.completada
                      ? 'Marcar como pendiente'
                      : 'Marcar como completada',
                  onPressed: onToggleCompletada,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
