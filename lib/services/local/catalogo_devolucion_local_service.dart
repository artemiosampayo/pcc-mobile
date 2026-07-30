/// ===========================================================
///
/// PCC Mobile Framework
///
/// Archivo:
/// catalogo_devolucion_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Descripción:
///
/// Administra el catálogo local de motivos de devolución.
///
/// Es el único responsable de acceder a la tabla:
///
/// catalogo_devoluciones_local
///
/// Todas las pantallas deben consumir este servicio y nunca
/// consultar SQLite directamente.
///
/// ===========================================================

import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';

class CatalogoDevolucionLocalService {

  CatalogoDevolucionLocalService._();

  static final instance =
      CatalogoDevolucionLocalService._();

  static const String table =
      'catalogo_devoluciones_local';

  Future<void> guardarCatalogo(
      List<dynamic> catalogo,
  ) async {

    final db = await DatabaseHelper.instance.database;

    await db.transaction((txn) async {

      //----------------------------------------------------------
      // Eliminar catálogo anterior
      //----------------------------------------------------------

      await txn.delete(table);

      //----------------------------------------------------------
      // Insertar catálogo
      //----------------------------------------------------------
      final fechaSincronizacion =
        DateTime.now().toIso8601String();
      for (final item in catalogo) {

        await txn.insert(
          table,
          {
            'id_devolucion':
                item['id_devolucion'],

            'codigo':
                item['codigo'],

            'descripcion':
                item['descripcion'],

            'orden_visual':
                item['orden_visual'],

            'fecha_sincronizacion':
                fechaSincronizacion,
          },
        );

      }

    });

  }

  Future<List<Map<String, dynamic>>> obtenerCatalogo() async {

    final db = await DatabaseHelper.instance.database;

    return await db.query(
      table,
      orderBy: 'orden_visual ASC',
    );

  }

  Future<Map<String, dynamic>?> obtenerPorId(
      int idDevolucion,
  ) async {

    final db =
        await DatabaseHelper.instance.database;

    final resultado =
        await db.query(
      table,
      where: 'id_devolucion = ?',
      whereArgs: [
        idDevolucion,
      ],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;

  }

  Future<bool> existeCatalogo() async {

    final db =
        await DatabaseHelper.instance.database;

    final resultado = await db.rawQuery(
      '''
      SELECT COUNT(*) 
      FROM $table
      ''',
    );

    final cantidad =
        Sqflite.firstIntValue(resultado) ?? 0;

    return cantidad > 0;

  }

  Future<void> eliminarTodo() async {

    final db =
        await DatabaseHelper.instance.database;

    await db.delete(table);

  }
}