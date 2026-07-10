import 'package:flutter/material.dart';

import '../../services/api/auth_service.dart';

import '../../core/storage/storage_service.dart';

import '../configuracion_ruta/configuracion_ruta_screen.dart';
import '../../widgets/pcc_logo.dart';
class LoginScreen extends StatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();

}

class _LoginScreenState
    extends State<LoginScreen> {

  final usuarioController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool cargando = false;

  Future<void> login() async {

    try {

      setState(() {

        cargando = true;

      });

      final authService =
          AuthService();

      final data =
          await authService.login(

        usuario:
            usuarioController.text,

        password:
            passwordController.text,

      );
      if(
            data['rol']
            !=
            'CHOFER'
        ){

          throw Exception(

            'Este usuario no tiene acceso a PCC Mobile'

          );

        }

      await StorageService
        .guardarSesion(

      token:
          data['token'],

      usuario:
          data['usuario'],

      rol:
          data['rol'] ?? '',

      idUsuario:
          data['id_usuario'],

      idEmpleado:
          data['id_empleado'] ?? 0,

      idUbicacion:
          data['id_ubicacion'] ?? 0,

    );
      if(!mounted) return;

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>

          const ConfiguracionRutaScreen(),

        ),

      );

    }
    catch(e){

      if(!mounted) return;

      ScaffoldMessenger
          .of(context)
          .showSnackBar(

        SnackBar(

          content:
              Text(

            e.toString(),

          ),

        ),

      );

    }
    finally{

      if(mounted){

        setState(() {

          cargando = false;

        });

      }

    }

  }

  @override
Widget build(
  BuildContext context,
) {

  return Scaffold(

    body: Center(

      child: SingleChildScrollView(

        child: Padding(

          padding:
              const EdgeInsets.all(
                24,
              ),

          child: ConstrainedBox(

            constraints:
                const BoxConstraints(

              maxWidth: 450,

            ),

            child: Card(

              elevation: 8,

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

              ),

              child: Padding(

                padding:
                    const EdgeInsets.all(
                      30,
                    ),

                child: Column(

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    const PCCLogo(
                      width: 260,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(

                      'Paquetería y Carga Consolidada',

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(

                        fontSize: 18,

                        fontWeight:
                            FontWeight.w600,

                      ),

                    ),

                    const SizedBox(
                      height: 35,
                    ),

                    TextField(

                      controller:
                          usuarioController,

                      decoration:
                          const InputDecoration(

                        labelText:
                            'Usuario',

                        prefixIcon:
                            Icon(Icons.person),

                      ),

                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    TextField(

                      controller:
                          passwordController,

                      obscureText: true,

                      decoration:
                          const InputDecoration(

                        labelText:
                            'Contraseña',

                        prefixIcon:
                            Icon(Icons.lock),

                      ),

                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    SizedBox(

                      width:
                          double.infinity,

                      child:
                          ElevatedButton(

                        onPressed:

                            cargando

                            ? null

                            : login,

                        child:

                            cargando

                            ? const SizedBox(

                                width: 22,

                                height: 22,

                                child:
                                    CircularProgressIndicator(),

                              )

                            : const Text(

                                'INGRESAR',

                                style: TextStyle(

                                  fontWeight:
                                      FontWeight.bold,

                                ),

                              ),

                      ),

                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(

                      'Versión 1.0.0',

                      style: TextStyle(

                        color:
                            Colors.grey,

                        fontSize: 12,

                      ),

                    ),

                  ],

                ),

              ),

            ),

          ),

        ),

      ),

    ),

  );

}

}