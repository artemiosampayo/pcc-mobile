/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// route_summary.dart
///
/// Carpeta:
/// lib/models/
///
/// Descripción:
///
/// Representa el resumen de la operación actual antes
/// de finalizar una ruta.
///
/// Este modelo concentra toda la información necesaria
/// para que la pantalla Finalizar Ruta pueda mostrar
/// el estado de la operación sin conocer la lógica
/// de negocio ni consultar SQLite.
///
/// Este modelo NO se almacena en SQLite ni proviene
/// del API. Es construido por RouteFinishService.
///
/// Este modelo será utilizado por:
///
/// • RouteFinishService
/// • FinalizarRutaScreen
///
/// ===========================================================

class RouteSummary {

  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------

  const RouteSummary({

    required this.totalEntregas,

    required this.totalDevoluciones,

    required this.movimientosPendientes,

    required this.evidenciasPendientes,

    required this.hayActividad,

  });

  //------------------------------------------------------------
  // Propiedades
  //------------------------------------------------------------

  /// Total de entregas realizadas.
  final int totalEntregas;

  /// Total de devoluciones realizadas.
  final int totalDevoluciones;

  /// Total de movimientos pendientes de sincronizar.
  final int movimientosPendientes;

  /// Total de evidencias pendientes de sincronizar.
  final int evidenciasPendientes;

  /// Indica si durante la operación existió
  /// al menos una entrega o devolución.
  final bool hayActividad;

  //------------------------------------------------------------
  // copyWith
  //------------------------------------------------------------

  RouteSummary copyWith({

    int? totalEntregas,

    int? totalDevoluciones,

    int? movimientosPendientes,

    int? evidenciasPendientes,

    bool? hayActividad,

  }) {

    return RouteSummary(

      totalEntregas:
          totalEntregas ??
          this.totalEntregas,

      totalDevoluciones:
          totalDevoluciones ??
          this.totalDevoluciones,

      movimientosPendientes:
          movimientosPendientes ??
          this.movimientosPendientes,

      evidenciasPendientes:
          evidenciasPendientes ??
          this.evidenciasPendientes,

      hayActividad:
          hayActividad ??
          this.hayActividad,

    );

  }

}