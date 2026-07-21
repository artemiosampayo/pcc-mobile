/// -----------------------------------------------------------------------------
/// sync_modules.dart
/// -----------------------------------------------------------------------------
///
/// Autor : PCC Mobile
///
/// Responsabilidad:
/// Centralizar los nombres de los módulos utilizados por el proceso de
/// sincronización.
///
/// Evita el uso de cadenas de texto duplicadas y facilita el mantenimiento
/// de la aplicación.
/// -----------------------------------------------------------------------------

class SyncModules {
  const SyncModules._();

  /// Módulo de catálogos.
  static const String catalogos = 'Catálogos';

  /// Módulo de configuración.
  static const String configuracion = 'Configuración';

  /// Módulo de datos maestros.
  static const String masterData = 'Master Data';

  /// Módulo de envíos.
  static const String envios = 'Envíos';

  /// Módulo de workflow.
  static const String workflow = 'Workflow';
}