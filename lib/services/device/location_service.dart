/// -----------------------------------------------------------------------------
/// location_service.dart
/// -----------------------------------------------------------------------------
/// Servicio encargado de obtener la ubicación GPS del dispositivo.
///
/// Centraliza toda la interacción con Geolocator para evitar dependencias
/// directas desde las pantallas o managers.
///
/// Autor: PCC Mobile
/// Proyecto: PCC Logistics
/// -----------------------------------------------------------------------------
import 'dart:async';
import '../../models/location_result.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();
  
  Future<LocationResult> obtenerUbicacion() async {
    final servicioHabilitado =
        await Geolocator.isLocationServiceEnabled();
    
    if (!servicioHabilitado) {
      return const LocationResult(
        success: false,
        mensaje: 'El servicio de ubicación está deshabilitado.',
      );
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return const LocationResult(
          success: false,
          mensaje: 'El usuario negó el permiso de ubicación.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(
        success: false,
        mensaje: 'Los permisos de ubicación fueron denegados permanentemente.',
      );
    }
    
    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return LocationResult(
        success: true,
        latitud: position.latitude,
        longitud: position.longitude,
        precision: position.accuracy,
        fechaGps: DateTime.now(),
        mensaje: 'Ubicación obtenida correctamente.',
      );
    } on TimeoutException {
      return const LocationResult(
        success: false,
        mensaje: 'No fue posible obtener la ubicación dentro del tiempo establecido.',
      );
    } on PermissionDeniedException {
      return const LocationResult(
        success: false,
        mensaje: 'Permiso de ubicación denegado.',
      );
    } catch (e) {
      return LocationResult(
        success: false,
        mensaje: 'No fue posible obtener la ubicación del dispositivo.'
      );
    }
  }
}