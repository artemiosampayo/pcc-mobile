/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// movimiento_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Descripción:
///
/// Administra la cola local de movimientos de envío.
///
/// Responsabilidades:
///
/// • Crear movimientos pendientes de sincronización.
/// • Consultar movimientos pendientes.
/// • Marcar movimientos como sincronizados.
/// • Registrar errores e intentos de sincronización.
///
/// Los movimientos se conservan localmente hasta confirmar
/// que PCC API los recibió correctamente.
///
/// ===========================================================

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../database/database_helper.dart';

class MovimientoLocalService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final MovimientoLocalService instance =
      MovimientoLocalService._();

  MovimientoLocalService._();

  //----------------------------------------------------------
  // UUID
  //----------------------------------------------------------

  static const Uuid _uuid =
      Uuid();

  //----------------------------------------------------------
  // Obtener BD
  //----------------------------------------------------------

  Future<Database> _db() async {

    return await DatabaseHelper
        .instance
        .database;

  }

  //----------------------------------------------------------
  // Crear movimiento pendiente
  //----------------------------------------------------------

  Future<String> crearMovimiento({

    required int idOperacion,

    required int idEnvio,

    required String codigoEstado,

    required int idEstado,

    required String descripcion,

    int? idUbicacion,

    int? idEmpleado,

    int? idRuta,

    double? latitud,

    double? longitud,

    String? dispositivo,

  }) async {

    final db =
        await _db();

    final uuidSincronizacion =
        _uuid.v4();

    await db.insert(

      'movimientos_local',

      {

        'uuid_sincronizacion':
            uuidSincronizacion,

        'id_operacion':
            idOperacion,

        'id_envio':
            idEnvio,

        'codigo_estado':
            codigoEstado,

        'id_estado':
            idEstado,

        'descripcion':
            descripcion,

        'id_ubicacion':
            idUbicacion,

        'id_empleado':
            idEmpleado,

        'id_ruta':
            idRuta,

        'latitud':
            latitud,

        'longitud':
            longitud,

        'dispositivo':
            dispositivo,

        'fecha_evento':
            DateTime.now()
                .toIso8601String(),

        'sincronizado':
            0,

        'intentos':
            0,

        'ultimo_error':
            null,

      },

      conflictAlgorithm:
          ConflictAlgorithm.abort,

    );

    return uuidSincronizacion;

  }
//----------------------------------------------------------
// Crear lote de movimientos ECON
//
// Crea un movimiento ECON por cada guía del manifiesto.
//
// La operación es transaccional:
// • Si ocurre un error, no se guarda un lote parcial.
// • Si el movimiento ya existe para:
//   operación + envío + estado
//   se ignora para evitar duplicados.
//----------------------------------------------------------

Future<int> crearLoteEcon({

  required int idOperacion,

  required List<Map<String, dynamic>> envios,

  required int idUbicacion,

  required int idEmpleado,

  required int idRuta,

  double? latitud,

  double? longitud,

}) async {

  final db =
      await _db();

  int movimientosCreados = 0;

  await db.transaction(
    (txn) async {

      for (final envio in envios) {

        final uuidSincronizacion =
            _uuid.v4();

        final resultado =
            await txn.insert(

          'movimientos_local',

          {

            'uuid_sincronizacion':
                uuidSincronizacion,

            'id_operacion':
                idOperacion,

            'id_envio':
                envio['id_envio'],

            'codigo_estado':
                'ECON',

            'id_estado':
                3,

            'descripcion':
                'Guía cargada y confirmada en ECON',

            'id_ubicacion':
                idUbicacion,

            'id_empleado':
                idEmpleado,

            'id_ruta':
                idRuta,

            'latitud':
                latitud,

            'longitud':
                longitud,

            'dispositivo':
                null,

            'fecha_evento':
                DateTime.now()
                    .toIso8601String(),

            'sincronizado':
                0,

            'intentos':
                0,

            'ultimo_error':
                null,

          },

          conflictAlgorithm:
              ConflictAlgorithm.ignore,

        );

        if (resultado > 0) {
          movimientosCreados++;
        }

      }

    },
  );

  return movimientosCreados;

}
//----------------------------------------------------------
// Marcar movimientos de una operación y estado
// como sincronizados.
//
// Utilizado para reconciliación controlada cuando PCC API
// recibió correctamente los movimientos, pero el cliente
// no reconoció la respuesta como exitosa.
//----------------------------------------------------------

Future<int> marcarEstadoOperacionSincronizado({

  required int idOperacion,

  required String codigoEstado,

}) async {

  final db =
      await _db();

  return await db.update(

    'movimientos_local',

    {
      'sincronizado': 1,
      'ultimo_error': null,
    },

    where:
        'id_operacion = ? '
        'AND codigo_estado = ? '
        'AND sincronizado = 0',

    whereArgs: [
      idOperacion,
      codigoEstado,
    ],

  );

}

  //----------------------------------------------------------
  // Obtener movimientos pendientes
  //----------------------------------------------------------

  Future<List<Map<String, dynamic>>>
      obtenerPendientes() async {

    final db =
        await _db();

    return await db.query(

      'movimientos_local',

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
// Crear lote de movimientos EN_RUTA
//
// Crea un movimiento EN_RUTA por cada guía que forma parte
// del manifiesto confirmado.
//
// La operación es transaccional:
// • Si ocurre un error, no se guarda un lote parcial.
// • Si el movimiento ya existe para:
//   operación + envío + estado
//   se ignora para evitar duplicados.
//----------------------------------------------------------

  Future<int> crearLoteEnRuta({

    required int idOperacion,

    required List<Map<String, dynamic>> envios,

    required int idUbicacion,

    required int idEmpleado,

    required int idRuta,

  }) async {

    final db =
        await _db();

    int movimientosCreados = 0;

    await db.transaction(
      (txn) async {

        for (final envio in envios) {

          final uuidSincronizacion =
              _uuid.v4();

          final resultado =
              await txn.insert(

            'movimientos_local',

            {

              'uuid_sincronizacion':
                  uuidSincronizacion,

              'id_operacion':
                  idOperacion,

              'id_envio':
                  envio['id_envio'],

              'codigo_estado':
                  'EN_RUTA',

              'id_estado':
                  4,

              'descripcion':
                  'Unidad en operación - inicio de ruta',

              'id_ubicacion':
                  idUbicacion,

              'id_empleado':
                  idEmpleado,

              'id_ruta':
                  idRuta,

              'latitud':
                  null,

              'longitud':
                  null,

              'dispositivo':
                  null,

              'fecha_evento':
                  DateTime.now()
                      .toIso8601String(),

              'sincronizado':
                  0,

              'intentos':
                  0,

              'ultimo_error':
                  null,

            },

            conflictAlgorithm:
                ConflictAlgorithm.ignore,

          );

          if (resultado > 0) {
            movimientosCreados++;
          }

        }

      },
    );

    return movimientosCreados;

  }

  //----------------------------------------------------------
  // Marcar movimiento sincronizado
  //----------------------------------------------------------

  Future<void> marcarSincronizado(
      String uuidSincronizacion) async {

    final db =
        await _db();

    await db.update(

      'movimientos_local',

      {
        'sincronizado': 1,
        'ultimo_error': null,
      },

      where:
          'uuid_sincronizacion = ?',

      whereArgs: [
        uuidSincronizacion,
      ],

    );

  }

  //----------------------------------------------------------
  // Registrar error de sincronización
  //----------------------------------------------------------

  Future<void> registrarError(

    String uuidSincronizacion,

    String error,

  ) async {

    final db =
        await _db();

    await db.rawUpdate(

      '''

      UPDATE movimientos_local

      SET
        intentos = intentos + 1,
        ultimo_error = ?

      WHERE uuid_sincronizacion = ?

      ''',

      [
        error,
        uuidSincronizacion,
      ],

    );

  }

}