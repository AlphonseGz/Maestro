import 'package:flutter/material.dart';

import 'unidad.dart';

/// Modelo de datos de una materia.
///
/// Una materia guarda su título, el color elegido (que servirá como
/// identificador visual de sus futuras tareas), una foto opcional,
/// contadores de tareas (por ahora siempre 0/0) y sus unidades,
/// que la dividen en subconjuntos (ej. "Unidad 1", "Unidad 2").
class Materia {
  Materia({
    String? id,
    required this.titulo,
    required this.colorValue,
    this.fotoPath,
    this.tareasTotales = 0,
    this.tareasCompletadas = 0,
    List<Unidad>? unidades,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       // Lista creable (no const) para poder añadir unidades.
       unidades = unidades ?? [];

  /// Identificador único: sirve para saber qué materia es
  /// cada unidad y para editar/borrar la correcta.
  final String id;

  /// Nombre de la materia, ej. "Mathematics". No puede estar vacío.
  final String titulo;

  /// El color elegido, guardado como número (Color.value) porque
  /// en shared_preferences no podemos guardar un objeto Color.
  final int colorValue;

  /// Ruta de la foto elegida de la galería. null = sin foto.
  final String? fotoPath;

  /// Para el futuro módulo de tareas. Por ahora 0.
  final int tareasTotales;
  final int tareasCompletadas;

  /// Unidades que dividen esta materia. Empieza vacía.
  final List<Unidad> unidades;

  /// El color como objeto Color de Flutter, listo para dibujar.
  Color get color => Color(colorValue);

  /// Porcentaje de progreso de 0.0 a 1.0.
  /// Si no hay tareas, es 0 para no dividir entre cero.
  double get progreso {
    if (tareasTotales == 0) return 0;
    return tareasCompletadas / tareasTotales;
  }

  /// Degradado moderno a partir del color elegido:
  /// del color tal cual a una versión más clara del mismo tono.
  /// HSLColor permite aclarar un color subiendo su "lightness".
  LinearGradient get degradado {
    final HSLColor base = HSLColor.fromColor(color);
    final Color claro = base
        .withLightness((base.lightness + 0.30).clamp(0.0, 0.85))
        .toColor();
    return LinearGradient(
      colors: [claro, color],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  /// Crea una copia con los campos cambiados, conservando id y unidades.
  /// Útil para editar el título/color/foto sin perder las unidades.
  Materia copyWith({String? titulo, int? colorValue, String? fotoPath}) {
    return Materia(
      id: id,
      titulo: titulo ?? this.titulo,
      colorValue: colorValue ?? this.colorValue,
      fotoPath: fotoPath ?? this.fotoPath,
      tareasTotales: tareasTotales,
      tareasCompletadas: tareasCompletadas,
      unidades: unidades,
    );
  }

  /// Convierte la materia a un Map para guardarla como JSON.
  /// Las unidades se guardan anidadas dentro de la materia.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'colorValue': colorValue,
      'fotoPath': fotoPath,
      'tareasTotales': tareasTotales,
      'tareasCompletadas': tareasCompletadas,
      'unidades': unidades.map((unidad) => unidad.toJson()).toList(),
    };
  }

  /// Reconstruye una materia desde el JSON guardado.
  /// Si el JSON es viejo (sin id ni unidades), usa valores por defecto.
  factory Materia.fromJson(Map<String, dynamic> json) {
    final List<dynamic> unidadesJson = json['unidades'] as List<dynamic>? ?? [];
    return Materia(
      id: json['id'] as String?,
      titulo: json['titulo'] as String,
      colorValue: json['colorValue'] as int,
      fotoPath: json['fotoPath'] as String?,
      tareasTotales: json['tareasTotales'] as int? ?? 0,
      tareasCompletadas: json['tareasCompletadas'] as int? ?? 0,
      unidades: unidadesJson
          .map((item) => Unidad.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
