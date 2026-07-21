/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// catalog_sync_result.dart
///
/// Carpeta:
/// lib/results/
///
/// Descripción:
///
/// Resultado del proceso de sincronización del catálogo
/// de devoluciones.
///
/// ===========================================================

class CatalogSyncResult {

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------

  const CatalogSyncResult({

    required this.success,

    required this.registros,

    required this.fechaSincronizacion,

    this.error,

  });

  //----------------------------------------------------------
  // Propiedades
  //----------------------------------------------------------

  final bool success;

  final int registros;

  final DateTime fechaSincronizacion;

  final String? error;

}