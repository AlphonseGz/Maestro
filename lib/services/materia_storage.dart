import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/materia.dart';

/// Servicio que guarda y carga las materias en el teléfono.
///
/// Usa shared_preferences: un almacén simple de clave-valor.
/// Guardamos toda la lista como un solo texto JSON en la clave
/// 'materias'. Así, si la app se cierra, las materias se conservan.
class MateriaStorage {
  static const String _claveMaterias = 'materias';

  /// Carga las materias guardadas. Si nunca se guardó nada,
  /// devuelve una lista vacía.
  static Future<List<Materia>> cargarMaterias() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? textoGuardado = prefs.getString(_claveMaterias);
    if (textoGuardado == null || textoGuardado.isEmpty) {
      return [];
    }
    final List<dynamic> listaJson = jsonDecode(textoGuardado) as List<dynamic>;
    return listaJson
        .map((item) => Materia.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Guarda la lista completa de materias, reemplazando lo anterior.
  static Future<void> guardarMaterias(List<Materia> materias) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String textoJson = jsonEncode(
      materias.map((materia) => materia.toJson()).toList(),
    );
    await prefs.setString(_claveMaterias, textoJson);
  }
}
