/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// operacion_reconciliacion_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Descripción:
///
/// Servicio responsable de reconciliar y limpiar el contexto
/// operativo local de una operación que ya fue finalizada
/// centralmente en PCC.
///
/// Este servicio se utiliza cuando Mobile detecta que la
/// operación almacenada localmente ya no está activa en PCC.
///
/// Responsabilidades:
///
/// • Validar que el workflow local corresponde a la operación.
/// • Obtener rutas de archivos de evidencias de la operación.
/// • Eliminar evidencias locales de la operación.
/// • Eliminar relaciones entrega-envío.
/// • Eliminar relaciones devolución-envío.
/// • Eliminar referencias de movimientos remotos.
/// • Eliminar movimientos locales.
/// • Eliminar entregas locales.
/// • Eliminar devoluciones locales.
/// • Limpiar envios_local.
/// • Eliminar workflow_operacion.
///
/// NO modifica:
///
/// • usuario_sesion
/// • catalogo_devoluciones_local
/// • configuración general del dispositivo
///
/// Regla funcional:
///
/// Una operación finalizada no puede permanecer como contexto
/// operativo local y mezclarse con una operación posterior.
///
/// La limpieza se realiza exclusivamente después de que PCC
/// confirmó que la operación ya fue FINALIZADA.
///
/// ===========================================================

import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';

class OperacionReconciliacionLocalService {

  //===========================================================
  // Singleton
  //===========================================================

  static final
      OperacionReconciliacionLocalService
          instance =
      OperacionReconciliacionLocalService._();

  OperacionReconciliacionLocalService._();

  //===========================================================
  // Obtener base de datos
  //===========================================================

  Future<Database> _db() async {

    return await DatabaseHelper
        .instance
        .database;

  }

  //===========================================================
  // RECONCILIAR OPERACION FINALIZADA
  //
  // Elimina exclusivamente el contexto local de la operación
  // indicada.
  //
  // Importante:
  //
  // Este método NO consulta la API.
  //
  // La decisión de que la operación está FINALIZADA debe
  // realizarse antes de invocar este servicio.
  //===========================================================

  Future<OperacionReconciliacionResult>
      reconciliarOperacionFinalizada(
    int idOperacion,
  ) async {

    if (idOperacion <= 0) {

      throw ArgumentError(
        'El id de operación debe ser mayor que cero.',
      );

    }

    final db =
        await _db();

    //=========================================================
    // Rutas de archivos que deberán eliminarse después de
    // confirmar correctamente la transacción SQLite.
    //=========================================================

    final List<String>
        rutasArchivos = [];

    int movimientosEliminados = 0;
    int entregasEliminadas = 0;
    int devolucionesEliminadas = 0;
    int evidenciasEliminadas = 0;
    int relacionesEntregaEliminadas = 0;
    int relacionesDevolucionEliminadas = 0;
    int movimientosRemotosEliminados = 0;
    int enviosEliminados = 0;
    int workflowEliminado = 0;

    //=========================================================
    // TRANSACCION SQLITE
    //=========================================================

    await db.transaction(
      (txn) async {

        //=====================================================
        // 1. VALIDAR WORKFLOW LOCAL
        //
        // Debemos asegurarnos de que el workflow almacenado
        // corresponde exactamente a la operación recibida.
        //
        // Esto evita eliminar accidentalmente el workflow de
        // otra operación.
        //=====================================================

        final workflow =
            await txn.query(
          'workflow_operacion',
          columns: [
            'id_operacion',
          ],
          where:
              'id_operacion = ?',
          whereArgs: [
            idOperacion,
          ],
          limit: 1,
        );

        if (workflow.isEmpty) {

          throw StateError(
            'No existe workflow local para la operación '
            '$idOperacion.',
          );

        }

        //=====================================================
        // 2. OBTENER RUTAS DE EVIDENCIAS
        //
        // evidencias_local no tiene id_operacion.
        //
        // La relación es:
        //
        // evidencias_local.uuid_movimiento
        //          ↓
        // movimientos_local.uuid_sincronizacion
        //          ↓
        // movimientos_local.id_operacion
        //
        // Guardamos las rutas antes de eliminar los registros.
        //=====================================================

        final evidencias =
            await txn.rawQuery(
          '''
          SELECT
              e.ruta_archivo
          FROM evidencias_local e
          INNER JOIN movimientos_local m
              ON m.uuid_sincronizacion =
                 e.uuid_movimiento
          WHERE
              m.id_operacion = ?
          ''',
          [
            idOperacion,
          ],
        );

        for (
          final evidencia
          in evidencias
        ) {

          final ruta =
              evidencia['ruta_archivo'];

          if (
            ruta != null &&
            ruta.toString().trim().isNotEmpty
          ) {

            rutasArchivos.add(
              ruta.toString(),
            );

          }

        }

        //=====================================================
        // 3. ELIMINAR EVIDENCIAS
        //=====================================================

        final resultadoEvidencias =
            await txn.rawDelete(
          '''
          DELETE FROM evidencias_local
          WHERE uuid_movimiento IN (
              SELECT uuid_sincronizacion
              FROM movimientos_local
              WHERE id_operacion = ?
          )
          ''',
          [
            idOperacion,
          ],
        );

        evidenciasEliminadas =
            resultadoEvidencias;

        //=====================================================
        // 4. ELIMINAR RELACIONES ENTREGA - ENVIO
        //
        // Primero eliminamos la relación para evitar dejar
        // referencias locales huérfanas.
        //=====================================================

        final resultadoRelacionesEntrega =
            await txn.rawDelete(
          '''
          DELETE FROM entrega_envios_local
          WHERE uuid_entrega IN (
              SELECT uuid_entrega
              FROM entregas_local
              WHERE id_operacion = ?
          )
          ''',
          [
            idOperacion,
          ],
        );

        relacionesEntregaEliminadas =
            resultadoRelacionesEntrega;

        //=====================================================
        // 5. ELIMINAR RELACIONES DEVOLUCION - ENVIO
        //=====================================================

        final resultadoRelacionesDevolucion =
            await txn.rawDelete(
          '''
          DELETE FROM devolucion_envios_local
          WHERE uuid_devolucion IN (
              SELECT uuid_devolucion
              FROM devoluciones_local
              WHERE id_operacion = ?
          )
          ''',
          [
            idOperacion,
          ],
        );

        relacionesDevolucionEliminadas =
            resultadoRelacionesDevolucion;

        //=====================================================
        // 6. ELIMINAR REFERENCIAS DE MOVIMIENTOS REMOTOS
        //
        // movimientos_remotos solamente conserva la relación
        // entre UUID local e ID remoto.
        //
        // El histórico real permanece en PCC.
        //=====================================================

        final resultadoMovimientosRemotos =
            await txn.rawDelete(
          '''
          DELETE FROM movimientos_remotos
          WHERE uuid_movimiento IN (
              SELECT uuid_sincronizacion
              FROM movimientos_local
              WHERE id_operacion = ?
          )
          ''',
          [
            idOperacion,
          ],
        );

        movimientosRemotosEliminados =
            resultadoMovimientosRemotos;

        //=====================================================
        // 7. ELIMINAR MOVIMIENTOS LOCALES
        //=====================================================

        final resultadoMovimientos =
            await txn.delete(
          'movimientos_local',
          where:
              'id_operacion = ?',
          whereArgs: [
            idOperacion,
          ],
        );

        movimientosEliminados =
            resultadoMovimientos;

        //=====================================================
        // 8. ELIMINAR ENTREGAS LOCALES
        //=====================================================

        final resultadoEntregas =
            await txn.delete(
          'entregas_local',
          where:
              'id_operacion = ?',
          whereArgs: [
            idOperacion,
          ],
        );

        entregasEliminadas =
            resultadoEntregas;

        //=====================================================
        // 9. ELIMINAR DEVOLUCIONES LOCALES
        //=====================================================

        final resultadoDevoluciones =
            await txn.delete(
          'devoluciones_local',
          where:
              'id_operacion = ?',
          whereArgs: [
            idOperacion,
          ],
        );

        devolucionesEliminadas =
            resultadoDevoluciones;

        //=====================================================
        // 10. LIMPIAR GUIAS LOCALES
        //
        // envios_local representa el conjunto de guías del
        // contexto operativo actual.
        //
        // No tiene id_operacion.
        //
        // Como workflow_operacion es único en el dispositivo
        // y todavía NO se ha iniciado una nueva operación,
        // aquí corresponde limpiar todo el manifiesto local.
        //=====================================================

        final resultadoEnvios =
            await txn.delete(
          'envios_local',
        );

        enviosEliminados =
            resultadoEnvios;

        //=====================================================
        // 11. ELIMINAR WORKFLOW
        //
        // Es la última pieza del contexto operativo.
        //=====================================================

        final resultadoWorkflow =
            await txn.delete(
          'workflow_operacion',
          where:
              'id_operacion = ?',
          whereArgs: [
            idOperacion,
          ],
        );

        workflowEliminado =
            resultadoWorkflow;

      },
    );

    //=========================================================
    // ELIMINAR ARCHIVOS FISICOS
    //
    // La transacción SQLite ya terminó correctamente.
    //
    // Si un archivo ya no existe, simplemente continuamos.
    //
    // Si un archivo no puede eliminarse, NO revertimos la
    // transacción porque SQLite ya fue reconciliado.
    //
    // El error se registra pero no bloquea la liberación
    // operativa del dispositivo.
    //=========================================================

    int archivosEliminados = 0;
    int archivosNoEliminados = 0;

    final rutasUnicas =
        rutasArchivos.toSet();

    for (
      final ruta
      in rutasUnicas
    ) {

      try {

        final archivo =
            File(ruta);

        if (
          await archivo.exists()
        ) {

          await archivo.delete();

          archivosEliminados++;

        }

      } catch (e) {

        archivosNoEliminados++;

        print(
          '==================================================',
        );

        print(
          'RECONCILIACION OPERACION',
        );

        print(
          'No se pudo eliminar archivo:',
        );

        print(ruta);

        print(
          'Error:',
        );

        print(e);

        print(
          '==================================================',
        );

      }

    }

    //=========================================================
    // RESULTADO
    //=========================================================

    return
        OperacionReconciliacionResult(

      idOperacion:
          idOperacion,

      movimientosEliminados:
          movimientosEliminados,

      entregasEliminadas:
          entregasEliminadas,

      devolucionesEliminadas:
          devolucionesEliminadas,

      evidenciasEliminadas:
          evidenciasEliminadas,

      relacionesEntregaEliminadas:
          relacionesEntregaEliminadas,

      relacionesDevolucionEliminadas:
          relacionesDevolucionEliminadas,

      movimientosRemotosEliminados:
          movimientosRemotosEliminados,

      enviosEliminados:
          enviosEliminados,

      workflowEliminado:
          workflowEliminado,

      archivosEliminados:
          archivosEliminados,

      archivosNoEliminados:
          archivosNoEliminados,

    );

  }

}


//=============================================================
// RESULTADO DE RECONCILIACION
//=============================================================

class OperacionReconciliacionResult {

  final int idOperacion;

  final int movimientosEliminados;

  final int entregasEliminadas;

  final int devolucionesEliminadas;

  final int evidenciasEliminadas;

  final int relacionesEntregaEliminadas;

  final int relacionesDevolucionEliminadas;

  final int movimientosRemotosEliminados;

  final int enviosEliminados;

  final int workflowEliminado;

  final int archivosEliminados;

  final int archivosNoEliminados;

  const OperacionReconciliacionResult({

    required this.idOperacion,

    required this.movimientosEliminados,

    required this.entregasEliminadas,

    required this.devolucionesEliminadas,

    required this.evidenciasEliminadas,

    required this.relacionesEntregaEliminadas,

    required this.relacionesDevolucionEliminadas,

    required this.movimientosRemotosEliminados,

    required this.enviosEliminados,

    required this.workflowEliminado,

    required this.archivosEliminados,

    required this.archivosNoEliminados,

  });

}