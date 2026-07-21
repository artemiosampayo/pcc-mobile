/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// catalogo_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Descripción:
///
/// Administra el catálogo local de devoluciones almacenado
/// en SQLite.
///
/// Responsabilidades:
///
/// • Guardar catálogo.
/// • Obtener catálogo.
/// • Buscar devoluciones por código.
/// • Eliminar catálogo previo.
/// • Validar existencia del catálogo.
///
/// No realiza sincronización con PCC API.
///
/// ===========================================================

import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../../models/catalogo_devolucion.dart';

class CatalogoLocalService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final CatalogoLocalService instance =
      CatalogoLocalService._();

  CatalogoLocalService._();

  //----------------------------------------------------------
  // Obtener Base de Datos
  //----------------------------------------------------------

  Future<Database> _db() async {

    return await DatabaseHelper.instance.database;

  }

  //----------------------------------------------------------
  // Eliminar catálogo
  //----------------------------------------------------------

  Future<void> limpiarCatalogo() async {

    final db = await _db();

    await db.delete(
      'catalogo_devoluciones_local',
    );

  }

  //----------------------------------------------------------
  // Guardar catálogo completo
  //----------------------------------------------------------

  Future<void> guardarCatalogo(
    List<CatalogoDevolucion> catalogo,
  ) async {

    final db = await _db();

    await db.transaction(
      (txn) async {

        await txn.delete(
          'catalogo_devoluciones_local',
        );

        for (final item in catalogo) {

          await txn.insert(

            'catalogo_devoluciones_local',

            item.toMap(),

            conflictAlgorithm:
                ConflictAlgorithm.replace,

          );

        }

      },
    );

  }

  //----------------------------------------------------------
  // Obtener catálogo
  //----------------------------------------------------------

  Future<List<CatalogoDevolucion>>
      obtenerCatalogo() async {

    final db = await _db();

    final result = await db.query(

      'catalogo_devoluciones_local',

      orderBy: 'orden_visual ASC',

    );

    return result

        .map(
          CatalogoDevolucion.fromMap,
        )

        .toList();

  }

  //----------------------------------------------------------
  // Buscar por código
  //----------------------------------------------------------

  Future<CatalogoDevolucion?>
      buscarPorCodigo(
    String codigo,
  ) async {

    final db = await _db();

    final result = await db.query(

      'catalogo_devoluciones_local',

      where: 'codigo = ?',

      whereArgs: [
        codigo,
      ],

      limit: 1,

    );

    if (result.isEmpty) {

      return null;

    }

    return CatalogoDevolucion.fromMap(

      result.first,

    );

  }

  //----------------------------------------------------------
  // Existe catálogo
  //----------------------------------------------------------

  Future<bool> existeCatalogo() async {

    final db = await _db();

    final result = await db.rawQuery(

      '''
      SELECT COUNT(*) total
      FROM catalogo_devoluciones_local
      '''
    );

    return (result.first['total'] as int) > 0;

  }

}