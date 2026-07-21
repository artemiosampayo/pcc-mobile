/// -----------------------------------------------------------------------------
/// sync_manager_result.dart
/// -----------------------------------------------------------------------------
///
/// Responsabilidad:
/// Representar el resultado consolidado de una sincronización ejecutada por el
/// SyncManager.
///
/// El resultado contiene el estado general de la sincronización y el detalle
/// individual de cada módulo sincronizado.
///
/// Arquitectura:
///
/// UI
///   ↓
/// SyncManager
///   ↓
/// SyncManagerResult
///
/// -----------------------------------------------------------------------------

class SyncManagerResult {
  /// Indica si la sincronización general fue exitosa.
  final bool success;

  /// Indica si la aplicación puede permitir iniciar una ruta.
  final bool puedeIniciarRuta;

  /// Fecha y hora en la que terminó la sincronización.
  final DateTime fechaSincronizacion;

  /// Resultado individual de cada módulo sincronizado.
  final List<ModuloSyncResult> modulos;

  const SyncManagerResult({
    required this.success,
    required this.puedeIniciarRuta,
    required this.fechaSincronizacion,
    required this.modulos,
  });
}

///
/// Resultado de un módulo individual.
///
class ModuloSyncResult {
  /// Nombre del módulo.
  final String nombre;

  /// Indica si el módulo fue sincronizado correctamente.
  final bool success;

  /// Mensaje opcional de error o información.
  final String? mensaje;

  const ModuloSyncResult({
    required this.nombre,
    required this.success,
    this.mensaje,
  });
}