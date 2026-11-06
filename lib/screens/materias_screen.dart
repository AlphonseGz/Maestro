import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

import '../models/materia.dart';
import '../widgets/materia_card.dart';
import 'materia_detalle_screen.dart';

/// Pantalla de Materias: lista de tarjetas y botón + para crear.
///
/// NO carga ni guarda por su cuenta: recibe la lista compartida
/// [materias] de HomeScreen y avisa con [onChanged] al cambiar algo.
/// Así no existen copias desactualizadas que se pisen entre pantallas.
class MateriasScreen extends StatefulWidget {
  const MateriasScreen({
    super.key,
    required this.materias,
    required this.onChanged,
  });

  /// Lista compartida de materias (la misma que usa To do).
  final List<Materia> materias;

  /// Avisa a HomeScreen para guardar en el teléfono y redibujar.
  final Future<void> Function() onChanged;

  @override
  State<MateriasScreen> createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  /// Método que se ejecuta al pulsar el botón +.
  /// Abre el diálogo para crear una materia nueva.
  Future<void> _abrirFormularioNuevaMateria() async {
    final Materia? nuevaMateria = await showDialog<Materia>(
      context: context,
      builder: (context) => const _FormularioMateria(),
    );
    // Si el usuario canceló, nuevaMateria es null y no hacemos nada.
    if (nuevaMateria == null) return;
    widget.materias.add(nuevaMateria);
    // Guardamos la lista compartida en el teléfono.
    await widget.onChanged();
  }

  /// Al tocar una tarjeta, entramos a su pantalla de detalle.
  /// Al volver, guardamos (por si añadió unidades o tareas).
  Future<void> _entrarAMateria(Materia materia) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            MateriaDetalleScreen(materia: materia, onChanged: widget.onChanged),
      ),
    );
  }

  /// Edita una materia reutilizando el mismo formulario,
  /// pero precargado con sus datos actuales.
  Future<void> _editarMateria(Materia materia) async {
    final Materia? editada = await showDialog<Materia>(
      context: context,
      builder: (context) => _FormularioMateria(materiaExistente: materia),
    );
    if (editada == null) return;
    final int indice = widget.materias.indexWhere((m) => m.id == materia.id);
    if (indice != -1) widget.materias[indice] = editada;
    await widget.onChanged();
  }

  /// Elimina una materia tras pedir confirmación.
  Future<void> _eliminarMateria(Materia materia) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar materia'),
        content: Text('¿Eliminar "${materia.titulo}" y sus unidades?'),
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
    widget.materias.removeWhere((m) => m.id == materia.id);
    await widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0F2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0F2E),
        foregroundColor: Colors.white,
        title: const Text(
          'Subjects',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: widget.materias.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, color: Colors.white54, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No tienes materias todavía',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pulsa + para añadir tu primera materia',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              // ListView.builder solo dibuja las tarjetas que se ven,
              // ideal si hay muchas materias.
              itemCount: widget.materias.length,
              itemBuilder: (context, index) {
                final Materia materia = widget.materias[index];
                return MateriaCard(
                  materia: materia,
                  onTap: () => _entrarAMateria(materia),
                  onEdit: () => _editarMateria(materia),
                  onDelete: () => _eliminarMateria(materia),
                );
              },
            ),
      // Botón flotante tipo contador: abre el formulario.
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioNuevaMateria,
        backgroundColor: const Color(0xFF8B3DFF),
        foregroundColor: Colors.white,
        tooltip: 'Añadir materia',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Diálogo con el formulario para crear o editar una materia.
/// Si [materiaExistente] no es null, viene precargado para editar.
/// Devuelve una Materia con Navigator.pop, o null si se cancela.
class _FormularioMateria extends StatefulWidget {
  const _FormularioMateria({this.materiaExistente});

  final Materia? materiaExistente;

  @override
  State<_FormularioMateria> createState() => _FormularioMateriaState();
}

class _FormularioMateriaState extends State<_FormularioMateria> {
  /// Controlador del campo de texto del título.
  late final TextEditingController _tituloController;

  /// Color elegido en el selector. Empieza en morado de Maestro,
  /// o en el color actual si estamos editando.
  late Color _colorElegido;

  /// Ruta de la foto elegida de la galería. null = sin foto.
  String? _fotoPath;

  /// Instancia de image_picker para abrir la galería.
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.materiaExistente?.titulo ?? '',
    );
    _colorElegido = widget.materiaExistente?.color ?? const Color(0xFF8B3DFF);
    _fotoPath = widget.materiaExistente?.fotoPath;
  }

  @override
  void dispose() {
    // Liberamos el controlador al cerrar el diálogo.
    _tituloController.dispose();
    super.dispose();
  }

  /// Abre la galería de Android y guarda la ruta de la foto elegida.
  Future<void> _elegirFotoDeGaleria() async {
    final XFile? fotoElegida = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (fotoElegida == null) return;
    setState(() {
      _fotoPath = fotoElegida.path;
    });
  }

  /// Abre el selector de color libre y guarda el color elegido.
  Future<void> _abrirSelectorDeColor() async {
    Color colorTemporal = _colorElegido;
    final Color? resultado = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Elige un color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _colorElegido,
              onColorChanged: (color) {
                colorTemporal = color;
              },
              enableAlpha: false,
              displayThumbColor: true,
              portraitOnly: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, colorTemporal),
              child: const Text('Elegir'),
            ),
          ],
        );
      },
    );
    if (resultado != null) {
      setState(() {
        _colorElegido = resultado;
      });
    }
  }

  /// Valida el formulario y devuelve la materia.
  /// Si el título está vacío, no permite guardar.
  /// Al editar, conserva el id y las unidades de la original.
  void _guardarMateria() {
    final String titulo = _tituloController.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título para la materia')),
      );
      return;
    }
    final Materia? existente = widget.materiaExistente;
    Navigator.pop(
      context,
      // Construimos la materia a mano (no copyWith) para poder
      // quitar la foto: si _fotoPath es null, la materia queda sin foto,
      // conservando el id y las unidades de la original.
      Materia(
        id: existente?.id,
        titulo: titulo,
        colorValue: _colorElegido.toARGB32(),
        fotoPath: _fotoPath,
        tareasTotales: existente?.tareasTotales ?? 0,
        tareasCompletadas: existente?.tareasCompletadas ?? 0,
        unidades: existente?.unidades,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esEdicion = widget.materiaExistente != null;
    return AlertDialog(
      title: Text(esEdicion ? 'Editar materia' : 'Nueva materia'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej. Mathematics',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Fila del color: vista previa + botón para cambiarlo.
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _colorElegido,
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Color'),
              trailing: const Icon(Icons.palette),
              onTap: _abrirSelectorDeColor,
            ),
            // Fila de la foto: vista previa o botón para elegirla.
            // Si ya hay foto, un botón de papelera la quita
            // (solo la foto, la materia se conserva).
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _fotoPath == null
                  ? const Icon(Icons.photo_library_outlined)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_fotoPath!),
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
              title: const Text('Foto (opcional)'),
              trailing: _fotoPath == null
                  ? const Icon(Icons.photo)
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Quitar foto',
                      onPressed: () {
                        setState(() {
                          _fotoPath = null;
                        });
                      },
                    ),
              onTap: _elegirFotoDeGaleria,
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
          onPressed: _guardarMateria,
          child: Text(esEdicion ? 'Guardar' : 'Añadir'),
        ),
      ],
    );
  }
}
