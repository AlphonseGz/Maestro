import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../utils/fecha_formato.dart';

/// Diálogo grande con el detalle completo de una tarea.
///
/// Se abre al tocar la tarjeta en To do, para leer la descripción
/// completa sin tener que entrar a editar. Solo lectura + Cerrar.
class DetalleTareaDialog extends StatelessWidget {
  const DetalleTareaDialog({
    super.key,
    required this.tarea,
    required this.nombreMateria,
    required this.nombreUnidad,
  });

  final Tarea tarea;
  final String nombreMateria;
  final String nombreUnidad;

  @override
  Widget build(BuildContext context) {
    final bool venceHoy = soloDia(tarea.fechaLimite) == soloDia(DateTime.now());
    return AlertDialog(
      backgroundColor: const Color(0xFF241340),
      title: Text(
        tarea.titulo,
        style: const TextStyle(color: Colors.white, fontSize: 22),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (venceHoy)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '¡Vence hoy!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (venceHoy) const SizedBox(height: 12),
            const Text(
              'Descripción',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 4),
            // Descripción completa, sin recortar, en texto grande.
            Text(
              tarea.descripcion,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _FilaDetalle(
              icono: Icons.calendar_today,
              etiqueta: 'Fecha límite',
              valor:
                  '${formatearFechaLarga(tarea.fechaLimite)} · ${formatearHora(tarea.fechaLimite)}',
            ),
            _FilaDetalle(
              icono: Icons.menu_book,
              etiqueta: 'Materia',
              valor: nombreMateria,
            ),
            _FilaDetalle(
              icono: Icons.account_tree,
              etiqueta: 'Unidad',
              valor: nombreUnidad,
            ),
            _FilaDetalle(
              icono: Icons.check_circle,
              etiqueta: 'Estado',
              valor: tarea.completada ? 'Completada' : 'Pendiente',
            ),
            _FilaDetalle(
              icono: Icons.timer_off,
              etiqueta: 'Auto-delete',
              valor: tarea.autoDelete ? 'Activado' : 'Desactivado',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

/// Fila etiqueta-valor del detalle. Privada para no duplicar código.
class _FilaDetalle extends StatelessWidget {
  const _FilaDetalle({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.white54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  valor,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
