import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';

class AuthService {

  final Dio dio = Dio();

  Future<Map<String, dynamic>> login({

    required String usuario,

    required String password,

  }) async {

    final response = await dio.post(

      "${AppConstants.apiUrl}/api/login",

      data: {

        "usuario": usuario,

        "password": password,

      },

    );

    return response.data;

  }

}