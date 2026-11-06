import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../utils/fecha_formato.dart';

/// Diálogo para crear o editar una tarea.
///
/// Pide título, descripción y fecha límite (día + hora con los
/// selectores nativos de Android). Si [tareaExistente] no es null,
/// viene precargado para editar. Devuelve una Tarea o null.
class FormularioTarea extends StatefulWidget {
  const FormularioTarea({super.key, this.tareaExistente});

  final Tarea? tareaExistente;

  @override
  State<FormularioTarea> createState() => _FormularioTareaState();
}

class _FormularioTareaState extends State<FormularioTarea> {
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;

  /// Fecha y hora límite elegidas. Por defecto: mañana a las 22:00.
  late DateTime _fechaLimite;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.tareaExistente?.titulo ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.tareaExistente?.descripcion ?? '',
    );
    _fechaLimite =
        widget.tareaExistente?.fechaLimite ??
        DateTime.now().add(const Duration(days: 1, hours: 22));
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  /// Abre el selector de fecha de Android y luego el de hora.
  /// Al terminar, combina día y hora en una sola fecha límite.
  Future<void> _elegirFechaLimite() async {
    final DateTime? diaElegido = await showDatePicker(
      context: context,
      initialDate: _fechaLimite,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (diaElegido == null || !mounted) return;

    final TimeOfDay? horaElegida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaLimite),
    );
    if (horaElegida == null) return;

    setState(() {
      _fechaLimite = DateTime(
        diaElegido.year,
        diaElegido.month,
        diaElegido.day,
        horaElegida.hour,
        horaElegida.minute,
      );
    });
  }

  void _guardarTarea() {
    final String titulo = _tituloController.text.trim();
    final String descripcion = _descripcionController.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título para la tarea')),
      );
      return;
    }
    if (descripcion.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Escribe una descripción')));
      return;
    }
    final Tarea? existente = widget.tareaExistente;
    Navigator.pop(
      context,
      existente != null
          ? existente.copyWith(
              titulo: titulo,
              descripcion: descripcion,
              fechaLimite: _fechaLimite,
            )
          : Tarea(
              titulo: titulo,
              descripcion: descripcion,
              fechaLimite: _fechaLimite,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esEdicion = widget.tareaExistente != null;
    return AlertDialog(
      title: Text(esEdicion ? 'Editar tarea' : 'Nueva tarea'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej. Quiz 8',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej. Estudiar el capítulo 4',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha límite'),
              subtitle: Text(
                '${formatearFechaLarga(_fechaLimite)} · ${formatearHora(_fechaLimite)}',
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _elegirFechaLimite,
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
          onPressed: _guardarTarea,
          child: Text(esEdicion ? 'Guardar' : 'Añadir'),
        ),
      ],
    );
  }
}
