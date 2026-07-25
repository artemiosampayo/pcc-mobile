/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// devolucion_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Descripción:
///
/// Administra el registro local de devoluciones.
///
/// Responsabilidades:
///
/// • Crear una devolucion local.
/// • Persistir fotografía  en almacenamiento privado.
/// • Crear movimientos DEVOLUCION por cada guía.
/// • Relacionar las guías con la devolucion.
/// • Crear la cola local de evidencias.
/// • Actualizar el estado local de las guías.
/// • Garantizar atomicidad de la operación SQLite.
///
/// La creación de archivos ocurre antes de la transacción
/// SQLite.
///
/// Si la transacción falla, los archivos persistidos para la
/// devolucion son eliminados.
///
/// ===========================================================

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../database/database_helper.dart';

class DevolucionLocalService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final DevolucionLocalService instance =
      DevolucionLocalService._();

  DevolucionLocalService._();

  //----------------------------------------------------------
  // UUID
  //----------------------------------------------------------

  static const Uuid _uuid =
      Uuid();

  //----------------------------------------------------------
  // Obtener Base de Datos
  //----------------------------------------------------------

  Future<Database> _db() async {

    return await DatabaseHelper
        .instance
        .database;

  }

  //----------------------------------------------------------
  // Realizar devolucion local
  //----------------------------------------------------------

  Future<DevolucionLocalResult> realizarDevolucion({

    required int idOperacion,

    required List<Map<String, dynamic>> envios,

    required String fotoOrigenPath,

    required String motivo,

    required int idUbicacion,

    required int idEmpleado,

    required int idRuta,

    double? latitud,

    double? longitud,

  }) async {

    //--------------------------------------------------------
    // Validar guías
    //--------------------------------------------------------

    if (envios.isEmpty) {

      throw Exception(
        'No existen guías para realizar la devolución.',
      );

    }

    //--------------------------------------------------------
    // Identificadores de la devolucion
    //--------------------------------------------------------

    final uuidDevolucion =
        _uuid.v4();

    final uuidFoto =
        _uuid.v4();

    final fechaDevolucion =
        DateTime.now().toIso8601String();

    //--------------------------------------------------------
    // Crear directorio persistente
    //--------------------------------------------------------

    final applicationDirectory =
        await getApplicationDocumentsDirectory();

    final devolucionDirectory =
        Directory(
          path.join(
            applicationDirectory.path,
            'evidencias',
            'devoluciones',
            uuidDevolucion,
          ),
        );

    await devolucionDirectory.create(
      recursive: true,
    );

    //--------------------------------------------------------
    // Rutas persistentes
    //--------------------------------------------------------

    final fotoPath =
        path.join(
          devolucionDirectory.path,
          'foto.jpg',
        );


    try {

      //------------------------------------------------------
      // Persistir fotografía
      //------------------------------------------------------

      final fotoOrigen =
          File(fotoOrigenPath);

      if (!await fotoOrigen.exists()) {

        throw Exception(
          'No se encontró la fotografía de evidencia.',
        );

      }

      await fotoOrigen.copy(
        fotoPath,
      );


      //------------------------------------------------------
      // Base de datos
      //------------------------------------------------------

      final db =
          await _db();

      int movimientosCreados = 0;

      String? uuidMovimientoPrincipal;

      //------------------------------------------------------
      // Transacción SQLite
      //------------------------------------------------------

      await db.transaction(
        (txn) async {

          //--------------------------------------------------
          // Crear Devolucion
          //--------------------------------------------------

          await txn.insert(
            'devoluciones_local',
            {
              'uuid_devolucion':
                  uuidDevolucion,

              'id_operacion':
                  idOperacion,

              'motivo':
                  motivo.trim(),

              'fecha_devolucion':
                  fechaDevolucion,

              'sincronizado':
                  0,

              'fecha_sincronizacion':
                  null,
            },
            conflictAlgorithm:
                ConflictAlgorithm.abort,
          );

          //--------------------------------------------------
          // Crear movimientos y relaciones
          //--------------------------------------------------

          for (final envio in envios) {

            final idEnvio =
                int.parse(
                  envio['id_envio'].toString(),
                );

            final uuidMovimiento =
                _uuid.v4();
            
            uuidMovimientoPrincipal ??= uuidMovimiento;

            //----------------------------------------------
            // Movimiento DEVOLUCION
            //----------------------------------------------

            await txn.insert(
              'movimientos_local',
              {
                'uuid_sincronizacion':
                    uuidMovimiento,

                'id_operacion':
                    idOperacion,

                'id_envio':
                    idEnvio,

                'codigo_estado':
                    'DEVOLUCION',

                'id_estado':
                    8,

                'descripcion':
                    'Devolución realizada. Motivo: ${motivo.trim()}',

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
                    fechaDevolucion,

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

            //----------------------------------------------
            // Relación devolucion - envío
            //----------------------------------------------

            await txn.insert(
              'devolucion_envios_local',
              {
                'uuid_devolucion':
                    uuidDevolucion,

                'id_envio':
                    idEnvio,

                'uuid_movimiento':
                    uuidMovimiento,
              },
              conflictAlgorithm:
                  ConflictAlgorithm.abort,
            );

            //----------------------------------------------
            // Actualizar estado local
            //----------------------------------------------

            await txn.update(
              'envios_local',
              {
                'estatus_local':
                    'DEVOLUCION',

                'sincronizado':
                    0,
              },
              where:
                  'id_envio = ?',
              whereArgs: [
                idEnvio,
              ],
            );

            movimientosCreados++;

          }

          //--------------------------------------------------
          // Evidencia FOTO
          //--------------------------------------------------

          await txn.insert(
            'evidencias_local',
            {
              'uuid_evidencia':
                  uuidFoto,

              'uuid_referencia':
                  uuidDevolucion,

              'uuid_movimiento': uuidMovimientoPrincipal,

              'tipo':
                  'FOTO',

              'descripcion': 'Devolución realizada. Motivo: ${motivo.trim()}',

              'ruta_archivo':
                  fotoPath,

              'nombre_archivo':
                  'foto.jpg',

              'mime_type':
                  'image/jpeg',

              'fecha_creacion':
                  fechaDevolucion,

              'sincronizado':
                  0,

              'intentos':
                  0,

              'ultimo_error':
                  null,

              'fecha_sincronizacion':
                  null,
            },
            conflictAlgorithm:
                ConflictAlgorithm.abort,
          );

          

        },
      );

      //------------------------------------------------------
      // Resultado
      //------------------------------------------------------

      return DevolucionLocalResult(
        uuidDevolucion: uuidDevolucion,
        totalEnvios: envios.length,
        movimientosCreados:
            movimientosCreados,
        fotoPath: fotoPath,

      );

    } catch (e) {

      //------------------------------------------------------
      // Limpieza de archivos
      //------------------------------------------------------

      if (await devolucionDirectory.exists()) {

        await devolucionDirectory.delete(
          recursive: true,
        );

      }

      rethrow;

    }

  }

}


//============================================================
// RESULTADO DE DEVOLUCION LOCAL
//============================================================

class DevolucionLocalResult {

  final String uuidDevolucion;

  final int totalEnvios;

  final int movimientosCreados;

  final String fotoPath;



  const DevolucionLocalResult({

    required this.uuidDevolucion,

    required this.totalEnvios,

    required this.movimientosCreados,

    required this.fotoPath,


  });

  

}