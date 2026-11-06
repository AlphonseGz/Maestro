/// Modelo de datos de una tarea.
///
/// Una tarea pertenece a una unidad (y por tanto a una materia).
/// Se guarda dentro del JSON de su unidad, dentro de su materia,
/// así no necesitamos otro almacén.
class Tarea {
  Tarea({
    String? id,
    required this.titulo,
    required this.descripcion,
    required this.fechaLimite,
    this.completada = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Identificador único de la tarea.
  final String id;

  /// Título corto, ej. "Quiz 8".
  final String titulo;

  /// Descripción larga, ej. "Estudiar el capítulo 4".
  final String descripcion;

  /// Fecha y hora límite (DateTime incluye día y hora).
  final DateTime fechaLimite;

  /// true si ya está completada (check). Es mutable porque
  /// al pulsarlo lo cambiamos sin crear otra tarea.
  bool completada;

  /// Crea una copia con los campos cambiados.
  Tarea copyWith({
    String? titulo,
    String? descripcion,
    DateTime? fechaLimite,
    bool? completada,
  }) {
    return Tarea(
      id: id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      completada: completada ?? this.completada,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      // La fecha se guarda como texto ISO, ej. "2026-11-12T22:00:00.000"
      'fechaLimite': fechaLimite.toIso8601String(),
      'completada': completada,
    };
  }

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'] as String?,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      fechaLimite: DateTime.parse(json['fechaLimite'] as String),
      completada: json['completada'] as bool? ?? false,
    );
  }
}
