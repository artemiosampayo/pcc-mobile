/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// entrega_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Descripción:
///
/// Administra el registro local de entregas.
///
/// Responsabilidades:
///
/// • Crear una entrega local.
/// • Persistir fotografía y firma en almacenamiento privado.
/// • Crear movimientos ENTREGADO por cada guía.
/// • Relacionar las guías con la entrega.
/// • Crear la cola local de evidencias.
/// • Actualizar el estado local de las guías.
/// • Garantizar atomicidad de la operación SQLite.
///
/// La creación de archivos ocurre antes de la transacción
/// SQLite.
///
/// Si la transacción falla, los archivos persistidos para la
/// entrega son eliminados.
///
/// ===========================================================

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../database/database_helper.dart';

class EntregaLocalService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final EntregaLocalService instance =
      EntregaLocalService._();

  EntregaLocalService._();

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
  // Realizar entrega local
  //----------------------------------------------------------

  Future<EntregaLocalResult> realizarEntrega({

    required int idOperacion,

    required List<Map<String, dynamic>> envios,

    required String quienRecibe,

    required String fotoOrigenPath,

    required Uint8List firmaBytes,

    required int idUbicacion,

    required int idEmpleado,

    required int idRuta,

  }) async {

    //--------------------------------------------------------
    // Validar guías
    //--------------------------------------------------------

    if (envios.isEmpty) {

      throw Exception(
        'No existen guías para realizar la entrega.',
      );

    }

    //--------------------------------------------------------
    // Identificadores de la entrega
    //--------------------------------------------------------

    final uuidEntrega =
        _uuid.v4();

    final uuidFoto =
        _uuid.v4();

    final uuidFirma =
        _uuid.v4();

    final fechaEntrega =
        DateTime.now().toIso8601String();

    //--------------------------------------------------------
    // Crear directorio persistente
    //--------------------------------------------------------

    final applicationDirectory =
        await getApplicationDocumentsDirectory();

    final entregaDirectory =
        Directory(
          path.join(
            applicationDirectory.path,
            'evidencias',
            'entregas',
            uuidEntrega,
          ),
        );

    await entregaDirectory.create(
      recursive: true,
    );

    //--------------------------------------------------------
    // Rutas persistentes
    //--------------------------------------------------------

    final fotoPath =
        path.join(
          entregaDirectory.path,
          'foto.jpg',
        );

    final firmaPath =
        path.join(
          entregaDirectory.path,
          'firma.png',
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
      // Persistir firma
      //------------------------------------------------------

      if (firmaBytes.isEmpty) {

        throw Exception(
          'La firma de recibido está vacía.',
        );

      }

      await File(firmaPath).writeAsBytes(
        firmaBytes,
        flush: true,
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
          // Crear entrega
          //--------------------------------------------------

          await txn.insert(
            'entregas_local',
            {
              'uuid_entrega':
                  uuidEntrega,

              'id_operacion':
                  idOperacion,

              'quien_recibe':
                  quienRecibe.trim(),

              'fecha_entrega':
                  fechaEntrega,

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
            // Movimiento ENTREGADO
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
                    'ENTREGADO',

                'id_estado':
                    7,

                'descripcion':
                    'Entrega realizada a '
                    '${quienRecibe.trim()}',

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
                    fechaEntrega,

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
            // Relación entrega - envío
            //----------------------------------------------

            await txn.insert(
              'entrega_envios_local',
              {
                'uuid_entrega':
                    uuidEntrega,

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
                    'ENTREGADA',

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

              'uuid_entrega':
                  uuidEntrega,

              'uuid_movimiento': uuidMovimientoPrincipal,

              'tipo':
                  'FOTO',

              'descripcion': 'Fotografía de evidencia de entrega',

              'ruta_archivo':
                  fotoPath,

              'nombre_archivo':
                  'foto.jpg',

              'mime_type':
                  'image/jpeg',

              'fecha_creacion':
                  fechaEntrega,

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

          //--------------------------------------------------
          // Evidencia FIRMA
          //--------------------------------------------------

          await txn.insert(
            'evidencias_local',
            {
              'uuid_evidencia':
                  uuidFirma,

              'uuid_entrega':
                  uuidEntrega,

              'uuid_movimiento': uuidMovimientoPrincipal,

              'tipo':
                  'FIRMA',

              'descripcion': 'Firma de recibido',

              'ruta_archivo':
                  firmaPath,

              'nombre_archivo':
                  'firma.png',

              'mime_type':
                  'image/png',

              'fecha_creacion':
                  fechaEntrega,

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

      return EntregaLocalResult(
        uuidEntrega: uuidEntrega,
        totalEnvios: envios.length,
        movimientosCreados:
            movimientosCreados,
        fotoPath: fotoPath,
        firmaPath: firmaPath,
      );

    } catch (e) {

      //------------------------------------------------------
      // Limpieza de archivos
      //------------------------------------------------------

      if (await entregaDirectory.exists()) {

        await entregaDirectory.delete(
          recursive: true,
        );

      }

      rethrow;

    }

  }

}


//============================================================
// RESULTADO DE ENTREGA LOCAL
//============================================================

class EntregaLocalResult {

  final String uuidEntrega;

  final int totalEnvios;

  final int movimientosCreados;

  final String fotoPath;

  final String firmaPath;

  const EntregaLocalResult({

    required this.uuidEntrega,

    required this.totalEnvios,

    required this.movimientosCreados,

    required this.fotoPath,

    required this.firmaPath,

  });

  

}