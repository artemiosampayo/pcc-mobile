/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// route_finish_service.dart
///
/// Carpeta:
/// lib/services/workflow
///
/// Descripción:
///
/// Administra el proceso de finalización de una ruta.
///
/// Responsabilidades:
///
/// • Obtener el resumen de la operación.
/// • Consultar información local necesaria para finalizar.
/// • Validar pendientes de sincronización.
/// • Coordinar el cierre de la operación.
/// • Preparar la limpieza local.
///
/// Este servicio NO realiza entregas ni devoluciones.
/// Su responsabilidad es exclusivamente coordinar el
/// cierre de una operación.
///
/// ===========================================================

import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../../models/route_summary.dart';
import '../../results/route_finish_result.dart';
import '../sync/movimiento_sync_service.dart';
import '../sync/evidencia_sync_service.dart';
import '../../core/authentication/authentication_manager.dart';

class RouteFinishService {

  //----------------------------------------------------------
  // Singleton
  //----------------------------------------------------------

  static final RouteFinishService instance =
      RouteFinishService._();

  RouteFinishService._();

  //----------------------------------------------------------
  // Dependencias
  //----------------------------------------------------------

  final MovimientoSyncService _movimientoSyncService =
      MovimientoSyncService.instance;

  final EvidenciaSyncService _evidenciaSyncService =
      EvidenciaSyncService.instance;

  //----------------------------------------------------------
  // Obtener Base de Datos
  //----------------------------------------------------------

  Future<Database> _db() async {

    return await DatabaseHelper
        .instance
        .database;

  }

  //----------------------------------------------------------
  // Contar registros
  //----------------------------------------------------------

  Future<int> _count(
    String tabla,
  ) async {

    final db =
        await _db();

    final resultado =
        await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $tabla',
    );

    return Sqflite.firstIntValue(
          resultado,
        ) ??
        0;

  }

  //----------------------------------------------------------
  // Contar registros con condición
  //----------------------------------------------------------

  Future<int> _countWhere({

    required String tabla,

    required String where,

    List<Object?>? whereArgs,

  }) async {

    final db =
        await _db();

    final resultado =
        await db.query(

      tabla,

      columns: const [
        'COUNT(*) AS total',
      ],

      where: where,

      whereArgs: whereArgs,

    );

    return Sqflite.firstIntValue(
          resultado,
        ) ??
        0;

  }

  //----------------------------------------------------------
  // Obtener resumen de la operación
  //----------------------------------------------------------

  Future<RouteSummary> obtenerResumen() async {

    final totalEntregas =
        await _count(
      'entregas_local',
    );

    final totalDevoluciones =
        await _count(
      'devoluciones_local',
    );

    final movimientosPendientes =
        await _countWhere(

      tabla: 'movimientos_local',

      where: 'sincronizado = ?',

      whereArgs: const [
        0,
      ],

    );

    final evidenciasPendientes =
        await _countWhere(

      tabla: 'evidencias_local',

      where: 'sincronizado = ?',

      whereArgs: const [
        0,
      ],

    );

    return RouteSummary(

      totalEntregas:
          totalEntregas,

      totalDevoluciones:
          totalDevoluciones,

      movimientosPendientes:
          movimientosPendientes,

      evidenciasPendientes:
          evidenciasPendientes,

      hayActividad:
          totalEntregas > 0 ||
          totalDevoluciones > 0,

    );

  }

  //----------------------------------------------------------
  // Finalizar ruta
  //----------------------------------------------------------

  Future<RouteFinishResult> finalizarRuta() async 
  {

    try {

      final session =
          await AuthenticationManager.instance
              .obtenerSesion();

      if (session == null || session.token.isEmpty) {

        return RouteFinishResult(
          success: false,
          puedeFinalizar: false,
          mensaje: 'No existe una sesión válida.',
          resumen: await obtenerResumen(),
        );

      }

final token = session.token;

      final resumenInicial =
          await obtenerResumen();

      if (resumenInicial.movimientosPendientes == 0 &&
          resumenInicial.evidenciasPendientes == 0) {

        return RouteFinishResult(
          success: true,
          puedeFinalizar: true,
          mensaje: 'La ruta está lista para finalizar.',
          resumen: resumenInicial,
        );

      }

      await _movimientoSyncService.sincronizarPendientes(
        token: token,
      );

  
      await _evidenciaSyncService.sincronizarPendientes(
        token: token,
      );

      final resumenFinal =
          await obtenerResumen();

      final puedeFinalizar =
          resumenFinal.movimientosPendientes == 0 &&
          resumenFinal.evidenciasPendientes == 0;

      return RouteFinishResult(
        success: puedeFinalizar,
        puedeFinalizar: puedeFinalizar,
        mensaje: puedeFinalizar
            ? 'Todos los datos fueron sincronizados.'
            : 'Existen registros pendientes de sincronización.',
        resumen: resumenFinal,
      );

    } catch (e) {

      final resumen =
          await obtenerResumen();

      return RouteFinishResult(
        success: false,
        puedeFinalizar: false,
        mensaje: 'Ocurrió un error al finalizar la ruta.',
        resumen: resumen,
      );

    }

  }

}