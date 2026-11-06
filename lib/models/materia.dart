import 'package:flutter/material.dart';

/// Modelo de datos de una materia.
///
/// Una materia guarda su título, el color elegido (que servirá como
/// identificador visual de sus futuras tareas), una foto opcional
/// y contadores de tareas (por ahora siempre 0/0).
class Materia {
  Materia({
    required this.titulo,
    required this.colorValue,
    this.fotoPath,
    this.tareasTotales = 0,
    this.tareasCompletadas = 0,
  });

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

  /// Convierte la materia a un Map para guardarla como JSON.
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'colorValue': colorValue,
      'fotoPath': fotoPath,
      'tareasTotales': tareasTotales,
      'tareasCompletadas': tareasCompletadas,
    };
  }

  /// Reconstruye una materia desde el JSON guardado.
  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      titulo: json['titulo'] as String,
      colorValue: json['colorValue'] as int,
      fotoPath: json['fotoPath'] as String?,
      tareasTotales: json['tareasTotales'] as int? ?? 0,
      tareasCompletadas: json['tareasCompletadas'] as int? ?? 0,
    );
  }
}
