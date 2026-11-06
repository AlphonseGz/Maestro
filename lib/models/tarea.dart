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
    DateTime? creadaEn,
    this.completada = false,
    this.autoDelete = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       // Si no nos dan cuándo se creó, usamos ahora.
       creadaEn = creadaEn ?? DateTime.now();

  /// Identificador único de la tarea.
  final String id;

  /// Título corto, ej. "Quiz 8".
  final String titulo;

  /// Descripción larga, ej. "Estudiar el capítulo 4".
  final String descripcion;

  /// Fecha y hora límite (DateTime incluye día y hora).
  final DateTime fechaLimite;

  /// Cuándo se creó la tarea. Sirve para saber si la notificación
  /// de "llegó el día" debe saltar (si se creó el mismo día que vence).
  final DateTime creadaEn;

  /// true si ya está completada (check). Es mutable porque
  /// al pulsarlo lo cambiamos sin crear otra tarea.
  bool completada;

  /// true si, al pasar 2 minutos de la hora límite, la tarea
  /// se borra sola al abrir la app. Apagado por defecto.
  final bool autoDelete;

  /// Crea una copia con los campos cambiados.
  Tarea copyWith({
    String? titulo,
    String? descripcion,
    DateTime? fechaLimite,
    bool? completada,
    bool? autoDelete,
  }) {
    return Tarea(
      id: id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      creadaEn: creadaEn,
      completada: completada ?? this.completada,
      autoDelete: autoDelete ?? this.autoDelete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      // La fecha se guarda como texto ISO, ej. "2026-11-12T22:00:00.000"
      'fechaLimite': fechaLimite.toIso8601String(),
      'creadaEn': creadaEn.toIso8601String(),
      'completada': completada,
      'autoDelete': autoDelete,
    };
  }

  factory Tarea.fromJson(Map<String, dynamic> json) {
    final String fechaTexto = json['fechaLimite'] as String;
    return Tarea(
      id: json['id'] as String?,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      fechaLimite: DateTime.parse(fechaTexto),
      // Tareas viejas sin creadaEn: usamos su fecha límite,
      // así la notificación de "llegó el día" no se programa.
      creadaEn: json['creadaEn'] != null
          ? DateTime.parse(json['creadaEn'] as String)
          : DateTime.parse(fechaTexto),
      completada: json['completada'] as bool? ?? false,
      autoDelete: json['autoDelete'] as bool? ?? false,
    );
  }
}
