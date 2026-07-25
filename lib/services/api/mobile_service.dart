import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/constants/app_constants.dart';


class MobileService {

  final Dio dio = Dio();

  Future<List<dynamic>>
  obtenerUbicaciones(
    String token,
  ) async {

    final response =
        await dio.get(

      '${AppConstants.apiUrl}/api/mobile/ubicaciones',

      options: Options(

        headers: {

          'Authorization':
              'Bearer $token'

        },

      ),

    );

    return response.data['data'];

  }

Future<List<dynamic>> obtenerRutas(
  String token,
  int idUbicacion,
) async {

  final response = await dio.get(
  '${AppConstants.apiUrl}/api/mobile/rutas?id_ubicacion=$idUbicacion',
  options: Options(
    headers: {
      'Authorization': 'Bearer $token'
    },
    responseType: ResponseType.plain,
  ),
);

print("RESPUESTA RUTAS:");
print(response.data);

  dynamic data =
      response.data;

  if(data is String){

    data =
        jsonDecode(data);

  }

  return data['data'];

}

Future<List<dynamic>> obtenerGuiasRecepcionadas(

  String token,

  int idUbicacion,

) async {

  final response =

      await dio.get(

    '${AppConstants.apiUrl}/api/mobile/guias-recepcionadas?id_ubicacion=$idUbicacion',

    options: Options(

      headers: {

        'Authorization':

            'Bearer $token'

      },

    ),

  );

  dynamic data =

      response.data;

  if (data is String) {

    data = jsonDecode(data);

  }

  return data['data'];

}

Future<int> iniciarOperacion({

  required String token,

  required int idRuta,

  required int idUbicacion,

  required int idEmpleado,

  required int idUsuario,

}) async {

  final response =
      await dio.post(

    '${AppConstants.apiUrl}/api/mobile/iniciar-operacion',

    data: {

      "id_ruta": idRuta,

      "id_ubicacion": idUbicacion,

      "id_empleado": idEmpleado,

      "id_usuario": idUsuario

    },

    options: Options(

      headers: {

        'Authorization':
            'Bearer $token'

      },

    ),

  );

  print(
    "RESPUESTA COMPLETA:"
  );

  print(
    response.data
  );

  if(
      response.data['success']
      != true
  ){

    throw Exception(

      response.data['error']
      ??
      'Error iniciando operación'

    );

  }

  return int.parse(

    response.data[
      'id_operacion'
    ].toString(),

  );

}
Future<void> cerrarOperacion({

  required String token,

  required int idOperacion,

}) async {

  final response =
      await dio.post(

    '${AppConstants.apiUrl}/api/mobile/cerrar-operacion',

    data: {

      "id_operacion":
          idOperacion

    },

    options: Options(

      headers: {

        'Authorization':
            'Bearer $token'

      },

    ),

  );

  if(
      response.data['success']
      != true
  ){

    throw Exception(

      response.data['error']
      ??
      'Error cerrando operación'

    );

  }

}

Future<dynamic> obtenerOperacionActiva(

  String token,

  int idEmpleado,

) async {

  final response =
      await dio.get(

    '${AppConstants.apiUrl}/api/mobile/operacion-activa?id_empleado=$idEmpleado',

    options: Options(

      headers: {

        'Authorization':
            'Bearer $token'

      },
      responseType: ResponseType.plain,
    ),

  );
print("RESPUESTA UBICACIONES:");
print(response.data);
  dynamic data =
      response.data;

  if(data is String){

    data =
        jsonDecode(data);

  }

  print(
    "OPERACION ACTIVA:"
  );

  print(data);

  return data['data'];

}

//----------------------------------------------------------
// REGISTRAR MOVIMIENTO DE ENVÍO
//
// Envía un movimiento previamente creado en la cola local
// hacia PCC API.
//
// El uuid_sincronizacion permite identificar el evento
// durante reintentos de sincronización.
//----------------------------------------------------------

  Future<RegistroMovimientoResponse> registrarMovimiento({

    required String token,

    required Map<String, dynamic> movimiento,

  }) async {

    final response =
        await dio.post(

      '${AppConstants.apiUrl}/api/movimientos',

      data: {

        'id_envio':
            movimiento['id_envio'],

        'id_estado':
            movimiento['id_estado'],

        'descripcion':
            movimiento['descripcion'],

        'id_ubicacion':
            movimiento['id_ubicacion'],

        'id_empleado':
            movimiento['id_empleado'],

        'id_ruta':
            movimiento['id_ruta'],

        'latitud':
            movimiento['latitud'],

        'longitud':
            movimiento['longitud'],

        'dispositivo':
            movimiento['dispositivo'],

        'uuid_sincronizacion':
            movimiento['uuid_sincronizacion'],

        'fecha_evento':
            movimiento['fecha_evento'],

      },

      options: Options(

        headers: {

          'Authorization':
              'Bearer $token',

        },

      ),

    );
    print("STATUS:");
print(response.statusCode);

print("BODY:");
print(response.data);

    dynamic data =
        response.data;

    if (data is String) {
      data = jsonDecode(data);
    }

    if (
        data is Map &&
        data['success'] == false
    ) {
      throw Exception(
        data['error'] ??
        'Error registrando movimiento',
      );
    }

    return RegistroMovimientoResponse(

    success:
        data['success'] ?? true,

    idMovimiento:
        int.parse(
          data['id_movimiento'].toString(),
        ),

    mensaje:
        data['mensaje'] ?? '',

  );

  }
  //----------------------------------------------------------
  // REGISTRAR EVIDENCIA
  //----------------------------------------------------------

  Future<void> registrarEvidencia({

    required String token,

    required int idMovimiento,

    required Map<String, dynamic> evidencia,

  }) async {

    final formData = FormData.fromMap({

      'id_movimiento': idMovimiento,

      'tipo': evidencia['tipo'],

      'descripcion': evidencia['descripcion'] ?? '',

      'archivo': await MultipartFile.fromFile(

        evidencia['ruta_archivo'],

        filename: evidencia['nombre_archivo'],

      ),

    });

    final response = await dio.post(

      '${AppConstants.apiUrl}/api/evidencias',

      data: formData,

      options: Options(

        headers: {

          'Authorization': 'Bearer $token',

        },

      ),

    );

    dynamic data = response.data;

    if (data is String) {
      data = jsonDecode(data);
    }

    if (data is Map && data['success'] != true) {
      throw Exception(
        data['error'] ??
        'Error registrando evidencia',
      );
    }
  }

}
//----------------------------------------------------------
// RESPUESTA REGISTRO MOVIMIENTO
//----------------------------------------------------------

class RegistroMovimientoResponse {

  final bool success;

  final int idMovimiento;

  final String mensaje;

  const RegistroMovimientoResponse({

    required this.success,

    required this.idMovimiento,

    required this.mensaje,

  });

}