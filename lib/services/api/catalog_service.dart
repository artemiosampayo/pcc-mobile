/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// catalog_service.dart
///
/// Carpeta:
/// lib/services/
///
/// Descripción:
///
/// Servicio responsable de consumir los catálogos remotos
/// publicados por PCC API.
///
/// Actualmente administra:
///
/// • Catálogo de devoluciones.
///
/// No realiza almacenamiento local.
///
/// La persistencia corresponde a:
///
/// • CatalogoLocalService
///
/// La sincronización corresponde a:
///
/// • CatalogSyncService
///
/// ===========================================================

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../models/catalogo_devolucion.dart';
class CatalogService {

  //------------------------------------------------------------
  // Cliente HTTP
  //------------------------------------------------------------

  final Dio dio = Dio();

  //------------------------------------------------------------
  // Obtener catálogo de devoluciones
  //------------------------------------------------------------

  Future<List<CatalogoDevolucion>>
      obtenerCatalogoDevoluciones(
    String token,
  ) async {

    final response =
        await dio.get(

      '${AppConstants.apiUrl}/api/catalogos/devoluciones',

      options: Options(

        headers: {

          'Authorization':
              'Bearer $token',

        },

        responseType:
            ResponseType.plain,

      ),

    );

    dynamic data =
        response.data;

    if (data is String) {

      data =
          jsonDecode(data);

    }

    if (

      data is! Map ||

      data['success'] != true

    ) {

      throw Exception(

        data is Map
            ? data['error'] ??
                'Error obteniendo catálogo de devoluciones.'
            : 'Respuesta inválida del servidor.',

      );

    }

    final List<dynamic> registros =
        data['data'];

    return registros

        .map(

          (item) =>

              CatalogoDevolucion.fromJson(item),

        )

        .toList();

  }

}