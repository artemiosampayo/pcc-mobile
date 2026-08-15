/// -----------------------------------------------------------------------------
/// sync_manager.dart
/// -----------------------------------------------------------------------------
///
/// Autor : PCC Mobile
///
/// Responsabilidad:
/// Orquestar los procesos de sincronización de la aplicación.
///
/// El SyncManager NO conoce detalles de HTTP ni de SQLite.
/// Su única responsabilidad es coordinar los diferentes módulos de
/// sincronización y consolidar sus resultados.
///
/// Arquitectura:
///
/// UI
///   ↓
/// SyncManager
///   ↓
/// Sync Services
///   ↓
/// API / SQLite
///
/// -----------------------------------------------------------------------------


import '../results/sync_manager_result.dart';

import '../services/sync/catalog_sync_service.dart';
import '../services/sync/movimiento_sync_service.dart';
import '../services/sync/evidencia_sync_service.dart';

import '../core/constants/sync_modules.dart';


class SyncManager {

  //----------------------------------------------------------
  // Servicios de sincronización
  //----------------------------------------------------------

  final _catalogSyncService =
      CatalogSyncService();

  final _movimientoSyncService =
      MovimientoSyncService.instance;

  final _evidenciaSyncService =
      EvidenciaSyncService.instance;


  //----------------------------------------------------------
  // Control de ejecución
  //----------------------------------------------------------

  bool _sincronizando = false;


  //----------------------------------------------------------
  // Sincronización completa
  //----------------------------------------------------------

  /// Ejecuta la sincronización completa de la aplicación.
  ///
  /// Actualmente utilizada principalmente para sincronización
  /// de información necesaria para iniciar la operación.
  ///
  /// Este método NO se modifica para no afectar el flujo actual.
  ///
  Future<SyncManagerResult> sincronizarTodo(
    String token,
  ) async {

    final modulos =
        <ModuloSyncResult>[];

    modulos.add(
      await _sincronizarCatalogos(token),
    );

    return _construirResultado(
      modulos,
    );
  }


  //----------------------------------------------------------
  // Sincronización de pendientes
  //----------------------------------------------------------

  /// Sincroniza los movimientos y evidencias pendientes
  /// almacenados localmente en SQLite.
  ///
  /// Orden de procesamiento:
  ///
  /// 1. Movimientos
  /// 2. Evidencias
  ///
  /// Las evidencias se procesan después de los movimientos
  /// porque necesitan conocer el ID generado por PCC API.
  ///
  /// Si ya existe una sincronización en ejecución, no inicia
  /// una segunda sincronización simultánea.
  ///
  Future<SyncManagerResult> sincronizarPendientes(
    String token,
  ) async {

    //--------------------------------------------------------
    // Evitar sincronizaciones simultáneas
    //--------------------------------------------------------

    if (_sincronizando) {

      return SyncManagerResult(
        success: true,
        puedeIniciarRuta: true,
        fechaSincronizacion:
            DateTime.now(),
        modulos: const [],
      );

    }


    _sincronizando = true;


    try {

      final modulos =
          <ModuloSyncResult>[];


      //------------------------------------------------------
      // 1. MOVIMIENTOS
      //------------------------------------------------------

      final resultadoMovimientos =
          await _sincronizarMovimientos(
        token,
      );

      modulos.add(
        resultadoMovimientos,
      );


      //------------------------------------------------------
      // 2. EVIDENCIAS
      //------------------------------------------------------

      final resultadoEvidencias =
          await _sincronizarEvidencias(
        token,
      );

      modulos.add(
        resultadoEvidencias,
      );


      //------------------------------------------------------
      // Resultado final
      //------------------------------------------------------

      return _construirResultado(
        modulos,
      );

    } finally {

      _sincronizando = false;

    }

  }


  //----------------------------------------------------------
  // Movimientos
  //----------------------------------------------------------

  Future<ModuloSyncResult>
      _sincronizarMovimientos(
    String token,
  ) async {

    try {

      final resultado =
          await _movimientoSyncService
              .sincronizarPendientes(
        token: token,
      );


      //------------------------------------------------------
      // No hay pendientes
      //------------------------------------------------------

      final success =
          resultado.total == 0 ||
          (
            resultado.sincronizados ==
                resultado.total &&
            resultado.errores == 0
          );


      return ModuloSyncResult(
        nombre: 'Movimientos',
        success: success,
        mensaje:
            success
                ? null
                : 'No fue posible sincronizar todos '
                  'los movimientos pendientes.',
      );

    } catch (e) {

      return ModuloSyncResult(
        nombre: 'Movimientos',
        success: false,
        mensaje: e.toString(),
      );

    }

  }


  //----------------------------------------------------------
  // Evidencias
  //----------------------------------------------------------

  Future<ModuloSyncResult>
      _sincronizarEvidencias(
    String token,
  ) async {

    try {

      final resultado =
          await _evidenciaSyncService
              .sincronizarPendientes(
        token: token,
      );


      //------------------------------------------------------
      // No hay pendientes
      //------------------------------------------------------

      final success =
          resultado.total == 0 ||
          (
            resultado.sincronizadas ==
                resultado.total &&
            resultado.errores == 0
          );


      return ModuloSyncResult(
        nombre: 'Evidencias',
        success: success,
        mensaje:
            success
                ? null
                : 'No fue posible sincronizar todas '
                  'las evidencias pendientes.',
      );

    } catch (e) {

      return ModuloSyncResult(
        nombre: 'Evidencias',
        success: false,
        mensaje: e.toString(),
      );

    }

  }


  //----------------------------------------------------------
  // Construir resultado
  //----------------------------------------------------------

  SyncManagerResult _construirResultado(
    List<ModuloSyncResult> modulos,
  ) {

    final success =
        modulos.every(
      (m) => m.success,
    );


    return SyncManagerResult(

      success: success,

      puedeIniciarRuta:
          success,

      fechaSincronizacion:
          DateTime.now(),

      modulos:
          modulos,

    );

  }


  //----------------------------------------------------------
  // Catálogos
  //----------------------------------------------------------

  Future<ModuloSyncResult>
      _sincronizarCatalogos(
    String token,
  ) async {

    try {

      final resultado =
          await _catalogSyncService
              .sincronizarCatalogo(
        token,
      );


      return ModuloSyncResult(

        nombre:
            SyncModules.catalogos,

        success:
            resultado.success,

        mensaje:
            null,

      );

    } catch (e) {

      return ModuloSyncResult(

        nombre:
            'Catálogos',

        success:
            false,

        mensaje:
            e.toString(),

      );

    }

  }

}