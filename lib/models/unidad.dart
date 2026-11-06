import 'package:flutter/material.dart';

/// Un ícono disponible para las unidades: una clave de texto
/// (para guardarla en el teléfono) y el ícono de Flutter.
class IconoUnidad {
  const IconoUnidad({
    required this.clave,
    required this.icono,
    required this.etiqueta,
  });

  /// Texto que se guarda, ej. 'punto'. No guardamos el IconData
  /// porque no se puede convertir a JSON fácilmente.
  final String clave;
  final IconData icono;
  final String etiqueta;
}

/// Modelo de una unidad: subconjunto que divide una materia.
/// Ej. Materia "Mathematics" -> Unidades "Álgebra", "Geometría".
class Unidad {
  Unidad({required this.nombre, this.iconoClave = 'punto'});

  /// Nombre de la unidad, ej. "Unidad 1".
  final String nombre;

  /// Clave del ícono elegido, ej. 'libro'. Por defecto 'punto'.
  final String iconoClave;

  /// Pool de 8 íconos académicos seleccionables.
  /// El primero ('punto') es el que se usa por defecto.
  static const List<IconoUnidad> poolIconos = [
    IconoUnidad(clave: 'punto', icono: Icons.circle, etiqueta: 'Punto'),
    IconoUnidad(clave: 'libro', icono: Icons.menu_book, etiqueta: 'Libro'),
    IconoUnidad(
      clave: 'calculadora',
      icono: Icons.calculate,
      etiqueta: 'Calculadora',
    ),
    IconoUnidad(clave: 'flor', icono: Icons.local_florist, etiqueta: 'Flor'),
    IconoUnidad(clave: 'globo', icono: Icons.public, etiqueta: 'Globo'),
    IconoUnidad(clave: 'codigo', icono: Icons.code, etiqueta: 'Código'),
    IconoUnidad(clave: 'musica', icono: Icons.music_note, etiqueta: 'Música'),
    IconoUnidad(clave: 'estrella', icono: Icons.star, etiqueta: 'Estrella'),
  ];

  /// Busca el ícono por su clave. Si no existe, devuelve el punto.
  static IconData iconoPorClave(String clave) {
    for (final IconoUnidad item in poolIconos) {
      if (item.clave == clave) return item.icono;
    }
    return Icons.circle;
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'iconoClave': iconoClave};
  }

  factory Unidad.fromJson(Map<String, dynamic> json) {
    return Unidad(
      nombre: json['nombre'] as String,
      iconoClave: json['iconoClave'] as String? ?? 'punto',
    );
  }
}
