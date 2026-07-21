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
/// Futuros módulos:
/// - Catálogos
/// - Envíos
/// - Master Data
/// - Workflow
/// - Configuración
///
/// -----------------------------------------------------------------------------

import '../results/sync_manager_result.dart';
import '../services/sync/catalog_sync_service.dart';
import '../core/constants/sync_modules.dart';

class SyncManager {

  final _catalogSyncService = CatalogSyncService();

  /// ---------------------------------------------------------------------------
  /// Ejecuta la sincronización completa de la aplicación.
  ///
  /// Responsabilidades:
  /// - Coordinar los módulos de sincronización.
  /// - Consolidar los resultados.
  /// - Construir el resultado final.
  ///
  /// El SyncManager no realiza llamadas HTTP ni operaciones sobre SQLite.
  /// ---------------------------------------------------------------------------
  Future<SyncManagerResult> sincronizarTodo(String token,) async 
  {
    final modulos = <ModuloSyncResult>[];

    modulos.add(await _sincronizarCatalogos(token),);

    return _construirResultado(modulos);
  }

  /// ---------------------------------------------------------------------------
  /// Consolida los resultados de todos los módulos sincronizados.
  ///
  /// Determina si la sincronización fue exitosa y si la aplicación puede
  /// permitir iniciar una ruta.
  ///
  /// Returns:
  /// Resultado consolidado de la sincronización.
  /// ---------------------------------------------------------------------------
  SyncManagerResult _construirResultado(List<ModuloSyncResult> modulos,) 
  {
    final success = modulos.every((m) => m.success);

    return SyncManagerResult(
      success: success,
      puedeIniciarRuta: success,
      fechaSincronizacion: DateTime.now(),
      modulos: modulos,
    );
  }

  /// ---------------------------------------------------------------------------
  /// Ejecuta la sincronización del catálogo de devoluciones.
  ///
  /// Este método delega la sincronización al CatalogSyncService y transforma
  /// el resultado al formato utilizado por el SyncManager.
  ///
  /// Returns:
  /// Resultado del módulo de catálogos.
  /// ---------------------------------------------------------------------------
  Future<ModuloSyncResult> _sincronizarCatalogos(String token,) async 
  {
    try {
      final resultado = await _catalogSyncService.sincronizarCatalogo(token);

      return ModuloSyncResult(
        nombre: SyncModules.catalogos,
        success: resultado.success,
        mensaje: null,
      );
    } catch (e) {
      return ModuloSyncResult(
        nombre: 'Catálogos',
        success: false,
        mensaje: e.toString(),
      );
    }
  }
}