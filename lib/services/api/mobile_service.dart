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


}