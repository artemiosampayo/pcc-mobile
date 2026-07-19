/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// evidencia_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Descripción:
///
/// Administra la cola local de evidencias.
///
/// Responsabilidades:
///
/// • Obtener evidencias pendientes.
/// • Marcar evidencias sincronizadas.
/// • Registrar errores.
/// • Preparar información para EvidenciaSyncService.
///
/// ===========================================================

import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';

class EvidenciaLocalService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final EvidenciaLocalService instance =
      EvidenciaLocalService._();

  EvidenciaLocalService._();

  //----------------------------------------------------------
  // Obtener Base de Datos
  //----------------------------------------------------------

  Future<Database> _db() async {

    return await DatabaseHelper
        .instance
        .database;

  }
    //----------------------------------------------------------
  // Obtener evidencias pendientes
  //----------------------------------------------------------

  Future<List<Map<String, dynamic>>>
      obtenerPendientes() async {

    final db =
        await _db();

    return await db.query(

      'evidencias_local',

      where:
          'sincronizado = ?',

      whereArgs: [
        0,
      ],

      orderBy:
          'id_local ASC',

    );

  }
    //----------------------------------------------------------
  // Marcar sincronizada
  //----------------------------------------------------------

  Future<void> marcarSincronizada(

      String uuidEvidencia) async {

    final db =
        await _db();

    await db.update(

      'evidencias_local',

      {

        'sincronizado': 1,

        'ultimo_error': null,

      },

      where:
          'uuid_evidencia = ?',

      whereArgs: [

        uuidEvidencia,

      ],

    );

  }

    //----------------------------------------------------------
  // Registrar error
  //----------------------------------------------------------

  Future<void> registrarError(

      String uuidEvidencia,

      String error,

  ) async {

    final db =
        await _db();

    await db.rawUpdate(

      '''

      UPDATE evidencias_local

      SET

        intentos = intentos + 1,

        ultimo_error = ?

      WHERE uuid_evidencia = ?

      ''',

      [

        error,

        uuidEvidencia,

      ],

    );

  }


}