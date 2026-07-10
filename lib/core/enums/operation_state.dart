/// ===========================================================
/// PCC MOBILE
/// OperationState
///
/// Representa el flujo operativo del chofer.
///
/// Este enum será utilizado por:
///
/// • WorkflowManager
/// • Drawer
/// • Navegación
/// • Pantallas
///
/// Nunca deberá contener lógica.
///
/// ===========================================================

enum OperationState {

  /// El operador aún no tiene operación activa.
  sinOperacion,

  /// Configuración de ruta.
  configuracionRuta,

  /// Entrada a Contenedor.
  econ,

  /// ECON confirmado.
  econConfirmado,

  /// Ruta iniciada.
  enRuta,

  /// Cierre de ruta.
  cierreRuta,

  /// Operación finalizada.
  finalizada,

}