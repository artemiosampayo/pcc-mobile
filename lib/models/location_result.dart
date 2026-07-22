/// -----------------------------------------------------------------------------
/// location_result.dart
/// -----------------------------------------------------------------------------
/// Modelo que representa el resultado de la obtención de la ubicación GPS.
///
/// Se utiliza como contrato entre LocationService y el resto de la aplicación,
/// evitando exponer directamente la implementación del plugin Geolocator.
///
/// Autor: PCC Mobile
/// Proyecto: PCC Logistics
/// -----------------------------------------------------------------------------

class LocationResult {
  /// Indica si fue posible obtener la ubicación.
  final bool success;

  /// Latitud obtenida.
  final double? latitud;

  /// Longitud obtenida.
  final double? longitud;

  /// Precisión del GPS en metros.
  final double? precision;

  /// Fecha y hora en que fue obtenida la ubicación.
  final DateTime? fechaGps;

  /// Mensaje descriptivo cuando ocurre algún problema.
  final String? mensaje;

  const LocationResult({
    required this.success,
    this.latitud,
    this.longitud,
    this.precision,
    this.fechaGps,
    this.mensaje,
  });

  /// Indica si existen coordenadas válidas.
  bool get tieneCoordenadas =>
      latitud != null && longitud != null;
}