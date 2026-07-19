/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// movimiento_remoto_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Descripción:
///
/// Administra la relación entre el UUID del movimiento local
/// y el identificador generado por PCC API.
///
/// Responsabilidades:
///
/// • Registrar la relación UUID → ID remoto.
/// • Consultar el ID remoto.
/// • Eliminar relaciones cuando sea necesario.
///
/// ===========================================================

import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';

class MovimientoRemotoLocalService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final MovimientoRemotoLocalService instance =
      MovimientoRemotoLocalService._();

  MovimientoRemotoLocalService._();

  //----------------------------------------------------------
  // Obtener Base de Datos
  //----------------------------------------------------------

  Future<Database> _db() async 
  {

    return await DatabaseHelper
        .instance
        .database;

  }
  //----------------------------------------------------------
  // Guardar relación UUID -> ID remoto
  //----------------------------------------------------------

  Future<void> guardarRelacion(String uuidMovimiento,int idMovimientoRemoto,) async 
  {

    final db =
        await _db();

    await db.insert(

      'movimientos_remotos',

      {

        'uuid_movimiento': uuidMovimiento,

        'id_movimiento_remoto': idMovimientoRemoto,

        'fecha_registro':
            DateTime.now().toIso8601String(),

      },

      conflictAlgorithm:
          ConflictAlgorithm.replace,

    );

  }

  //----------------------------------------------------------
  // Obtener ID remoto
  //----------------------------------------------------------

  Future<int?> obtenerIdMovimientoRemoto(String uuidMovimiento,) async 
  {

    final db =
        await _db();

    final resultado =
        await db.query(

      'movimientos_remotos',

      columns: [

        'id_movimiento_remoto',

      ],

      where:
          'uuid_movimiento = ?',

      whereArgs: [

        uuidMovimiento,

      ],

      limit: 1,

    );

    if (resultado.isEmpty) {

      return null;

    }

    return resultado.first[
        'id_movimiento_remoto'] as int;

  }
  //----------------------------------------------------------
  // Eliminar relación
  //----------------------------------------------------------

  Future<void> eliminarRelacion(String uuidMovimiento,)async 
  {

    final db =
        await _db();

    await db.delete(

      'movimientos_remotos',

      where:
          'uuid_movimiento = ?',

      whereArgs: [

        uuidMovimiento,

      ],

    );

  }
}