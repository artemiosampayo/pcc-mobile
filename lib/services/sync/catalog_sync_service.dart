/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// catalog_sync_service.dart
///
/// Carpeta:
/// lib/services/sync/
///
/// Descripción:
///
/// Servicio responsable de sincronizar el catálogo de
/// devoluciones entre PCC API y la base de datos local.
///
/// Flujo:
///
/// PCC API
///     ↓
/// CatalogService
///     ↓
/// SQLite
///     ↓
/// CatalogoLocalService
///
/// ===========================================================

import '../api/catalog_service.dart';
import '../local/catalogo_local_service.dart';
import '../../results/catalog_sync_result.dart';

class CatalogSyncService {

  //----------------------------------------------------------
  // Dependencias
  //----------------------------------------------------------

  final CatalogService _catalogService = CatalogService();

  final CatalogoLocalService _catalogoLocalService =
      CatalogoLocalService.instance;

  //----------------------------------------------------------
  // Sincronizar catálogo
  //----------------------------------------------------------

  Future<CatalogSyncResult> sincronizarCatalogo(
    String token,
  ) async {

    try {

      final catalogo =
          await _catalogService
              .obtenerCatalogoDevoluciones(token);

      await _catalogoLocalService
          .guardarCatalogo(catalogo);

      return CatalogSyncResult(

        success: true,

        registros: catalogo.length,

        fechaSincronizacion: DateTime.now(),

        error: null,

      );

    } catch (e) {

      return CatalogSyncResult(

        success: false,

        registros: 0,

        fechaSincronizacion: DateTime.now(),

        error: e.toString(),

      );

    }

  }

}