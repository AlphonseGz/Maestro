import 'dart:io';

import 'package:flutter/material.dart';

import '../models/materia.dart';

/// Tarjeta rectangular de una materia, con bordes redondos.
///
/// Fondo con degradado moderno usando el color de la materia,
/// título arriba, "0/0 Tasks" debajo y barra de progreso fina.
/// A la derecha, arriba, un menú de 3 puntos (editar/eliminar)
/// y debajo la foto si existe, o un ícono de libro.
///
/// Tocar la tarjeta (fuera del menú) entra a la materia:
/// eso lo maneja [onTap], que pasa la pantalla principal.
///
/// Es StatelessWidget porque solo dibuja: no guarda estado propio.
class MateriaCard extends StatelessWidget {
  const MateriaCard({
    super.key,
    required this.materia,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Materia materia;

  /// Qué hacer al tocar la tarjeta: entrar a la materia.
  final VoidCallback? onTap;

  /// Qué hacer al elegir "Editar" en los 3 puntos.
  final VoidCallback? onEdit;

  /// Qué hacer al elegir "Eliminar" en los 3 puntos.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    // Porcentaje entero para mostrar, ej. 0% (0/0 -> 0%).
    final int porcentaje = (materia.progreso * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: materia.degradado,
        // Radio 20px: bordes bien redondos. Lo ajustaremos luego.
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Columna de textos: título, tareas y barra de progreso.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materia.titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${materia.tareasCompletadas}/${materia.tareasTotales} Tasks',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Barra de progreso fina y redondeada, como en la foto.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: materia.progreso,
                          minHeight: 8,
                          backgroundColor: Colors.white38,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$porcentaje%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Columna derecha: menú de 3 puntos arriba de la foto.
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: const Color(0xFF241340),
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
                              Text(
                                'Editar',
                                style: TextStyle(color: Colors.white),
                              ),
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
                    _FotoMateria(fotoPath: materia.fotoPath),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Foto de la materia en círculo redondeado. Privado porque solo
/// se usa dentro de este archivo, para no duplicar código.
class _FotoMateria extends StatelessWidget {
  const _FotoMateria({required this.fotoPath});

  final String? fotoPath;

  @override
  Widget build(BuildContext context) {
    if (fotoPath == null) {
      return const Icon(Icons.menu_book, color: Colors.white, size: 48);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(fotoPath!),
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        // Si la foto fue borrada del teléfono, no rompemos la app.
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.menu_book, color: Colors.white, size: 48);
        },
      ),
    );
  }
}
