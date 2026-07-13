import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api/mobile_service.dart';
import '../../widgets/pcc_logo.dart';
import '../../services/local/envio_local_service.dart';
import '../econ/econ_screen.dart';

import '../../core/workflow/workflow_manager.dart';
import '../../core/enums/operation_state.dart';
import '../../models/workflow_model.dart';
import '../ruta/inicio_ruta_screen.dart';

class ConfiguracionRutaScreen
    extends StatefulWidget {

  const ConfiguracionRutaScreen({
    super.key,
  });

  @override
  State<ConfiguracionRutaScreen>
  createState() =>
      _ConfiguracionRutaScreenState();
}

class _ConfiguracionRutaScreenState
    extends State<ConfiguracionRutaScreen> {

  final MobileService service =
      MobileService();

  String token = "";
  String rol = "";
  int idOperacion = 0;

  int idUsuario = 0;

  int idEmpleado = 0;

  int idUbicacion = 0;

  String usuario = "";

  List<dynamic> rutas = [];

  dynamic rutaSeleccionada;

  bool loading = true;

  WorkflowModel? workflow;

  @override
  void initState() {

    super.initState();

    cargarDatos();

  }

Future<void> cargarDatos()
async {

  final prefs =
      await SharedPreferences
          .getInstance();

  //=========================
  // SESION
  //=========================

  token =
      prefs.getString(
        "token",
      ) ??
      "";

  usuario =
      prefs.getString(
        "usuario",
      ) ??
      "";
  rol =
    prefs.getString(
      "rol",
    ) ??
    "";

  idUsuario =
      prefs.getInt(
        "id_usuario",
      ) ??
      0;

  idEmpleado =
      prefs.getInt(
        "id_empleado",
      ) ??
      0;

  idUbicacion =
      prefs.getInt(
        "id_ubicacion",
      ) ??
      0;

  idOperacion =
      prefs.getInt(
        "id_operacion",
      ) ??
      0;

  print("TOKEN:");
  print(token);

  print("USUARIO:");
  print(usuario);

  print("ROL:");
  print(rol);

  print("ID USUARIO:");
  print(idUsuario);

  print("ID EMPLEADO:");
  print(idEmpleado);

  print("ID UBICACION:");
  print(idUbicacion);
  workflow =
    await WorkflowManager.instance
        .obtenerOperacion();

if (!mounted) return;

if (workflow != null) {

  WidgetsBinding.instance.addPostFrameCallback((_) {

    switch (workflow!.estadoOperacion) {

        case OperationState.econ:

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const EconScreen(),
            ),
          );

          break;

        case OperationState.econConfirmado:

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const InicioRutaScreen(),
            ),
          );

          break;

        default:

          setState(() {
            loading = false;
          });

          break;
      }

  });

  return;
}
        

  //=========================
  // OPERACION ACTIVA
  //=========================

  try {

    final operacion =

        await service
            .obtenerOperacionActiva(

      token,

      idEmpleado,

    );

    print(
      "OPERACION BD:"
    );

    print(
      operacion
    );

    if(
        operacion != null
        &&
        operacion != false
    ){

      idOperacion =

          int.parse(

        operacion[
          'id_operacion'
        ].toString(),

      );

      print(
        "ID OPERACION:"
      );

      print(
        idOperacion
      );

    }

  }
  catch(e){

    print(
      "ERROR OPERACION ACTIVA:"
    );

    print(e);

  }
  

  //=========================
  // RUTAS
  //=========================

  try {

    rutas =
        await service
            .obtenerRutas(

      token,

      idUbicacion,

    );
print("======================");
print("ID UBICACION");
print(idUbicacion);
print("======================");
    print(
      "RUTAS:"
    );

    print(
      rutas
    );

  }
  catch(e){

    print(
      "ERROR RUTAS:"
    );

    print(
      e
    );

  }

  if(
      rutas.isNotEmpty
  ){

    rutaSeleccionada =
        rutas.first;

  }

  setState(() {

    loading = false;

  });

}

Future<void> iniciarOperacion()
async {

  if(rutaSeleccionada == null){

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      const SnackBar(

        content: Text(
          "Seleccione una ruta",
        ),

      ),

    );

    return;

  }

  try {

     idOperacion =

        await service
            .iniciarOperacion(

      token: token,

      idRuta:
          rutaSeleccionada[
              'id_ruta'
          ],

      idUbicacion:
          idUbicacion,

      idEmpleado:
          idEmpleado,

      idUsuario:
          idUsuario,

    );

    final prefs =

        await SharedPreferences
            .getInstance();

    await prefs.setInt(

      "id_operacion",

      idOperacion,

    );

    await prefs.setInt(

      "id_ruta",

      rutaSeleccionada[
          'id_ruta'
      ],

    );

    //==============================
    // DESCARGAR GUIAS
    //==============================

    final guias =

        await service

            .obtenerGuiasRecepcionadas(

                token,

                idUbicacion);

    print("======================");
    print("GUIAS DESCARGADAS");
    print(guias.length);
    print(guias);
    print("======================");

    final local =

        EnvioLocalService();

    await local.guardarGuias(

        guias);
    final workflow = WorkflowModel(

      idOperacion: idOperacion,

      idRuta: rutaSeleccionada['id_ruta'],

      nombreRuta: rutaSeleccionada['nombre'],

      placa: rutaSeleccionada['placa'],

      numeroEconomico:
          rutaSeleccionada['numero_economico'],

      contenedor:
          rutaSeleccionada['contenedor'],

      idOperador: idEmpleado,

      nombreOperador: usuario,

      idUbicacion: idUbicacion,

      // mientras exista una sola plaza
      // después tomaremos el nombre
      // desde catálogo

      nombreUbicacion: "CVA",

      estadoOperacion:
          OperationState.econ,

      fechaInicio:
          DateTime.now().toIso8601String(),

      fechaActualizacion:
          DateTime.now().toIso8601String(),

    );

    await WorkflowManager.instance
        .iniciarOperacion(
            workflow);

    print("======================");
    print("WORKFLOW GUARDADO");
    print(workflow.toMap());
    print("======================");
        final lista =

await local.obtenerEnvios();

print("======================");

print("GUIAS SQLITE");

print(lista.length);

print(lista);

print("======================");
    setState(() {});
    if(!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(

        content: Text(

          "Operación $idOperacion iniciada",

        ),

      ),

    );

    //=================================
    // REDIRIGE A PANTALLA ECON
    //=================================

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_)

            => const EconScreen(),

      ),

    );

  }
  catch(e){

    if(!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(

        content: Text(
          e.toString(),
        ),

      ),

    );

    print(
      "ERROR INICIAR OPERACION:"
    );

    print(e);

  }

}
Future<void> finalizarOperacion()
async {

  try {

    await service.cerrarOperacion(

      token: token,

      idOperacion:
          idOperacion,

    );

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.remove(
      "id_operacion",
    );

    await prefs.remove(
      "id_ruta",
    );

    setState(() {

      idOperacion = 0;

    });

    if(!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      const SnackBar(

        content: Text(
          "Operación finalizada",
        ),

      ),

    );

  }
  catch(e){

    if(!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(

        content:
            Text(
              e.toString(),
            ),

      ),

    );

  }

}
Future<void> probarSQLite()
async {

  final localService =

      EnvioLocalService();

  await localService.insertarEnvio({

    'id_envio': 1,

    'numero_guia': 'GUIA001',

    'pedido': 'PED001',

    'cliente': 'Cliente Prueba',

    'direccion': 'Av Reforma 123',

    'telefono': '5551234567',

    'estatus_local': 'PENDIENTE',

    'sincronizado': 0,

  });

  final envios =

      await localService
          .obtenerEnvios();

  print(
    "ENVIOS SQLITE:"
  );

  print(
    envios
  );

}
@override
Widget build(
  BuildContext context,
) {

  if (loading) {

    return const Scaffold(

      body: Center(

        child:
            CircularProgressIndicator(),

      ),

    );

  }

  return Scaffold(

    body: SafeArea(

      child: Center(

        child: SingleChildScrollView(

          child: Padding(

            padding:
                const EdgeInsets.all(
                  24,
                ),

            child: ConstrainedBox(

              constraints:
                  const BoxConstraints(

                maxWidth: 500,

              ),

              child: Column(

                children: [

                  const PCCLogo(
                    width: 220,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(

                    "Configuración de Ruta",

                    style: TextStyle(

                      fontSize: 24,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  //=========================
                  // OPERADOR
                  //=========================

                  Card(

                    elevation: 5,

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                            16,
                          ),

                    ),

                    child: Padding(

                      padding:
                          const EdgeInsets.all(
                            16,
                          ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          const Row(

                            children: [

                              Icon(
                                Icons.person,
                              ),

                              SizedBox(
                                width: 8,
                              ),

                              Text(

                                "Operador",

                                style: TextStyle(

                                  fontWeight:
                                      FontWeight.bold,

                                  fontSize: 18,

                                ),

                              ),

                            ],

                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          Text(
                            "Usuario: $usuario",
                          ),

                          Text(
                            "Empleado: $idEmpleado",
                          ),

                          Text(
                            "Ubicación: $idUbicacion",
                          ),

                        ],

                      ),

                    ),

                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  //=========================
                  // RUTA
                  //=========================

                  DropdownButtonFormField(

                    value:
                        rutaSeleccionada,

                    decoration:
                        const InputDecoration(

                      labelText:
                          "Selecciona una ruta",

                      prefixIcon:
                          Icon(Icons.route),

                    ),

                    items:
                        rutas.map((r) {

                      return DropdownMenuItem(

                        value: r,

                        child: Text(
                          r['nombre'],
                        ),

                      );

                    }).toList(),

                    onChanged: (value) {

                      setState(() {

                        rutaSeleccionada =
                            value;

                      });

                    },

                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  if (
                    rutaSeleccionada != null
                  )

                    Card(

                      elevation: 5,

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                              16,
                            ),

                      ),

                      child: Padding(

                        padding:
                            const EdgeInsets.all(
                              16,
                            ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(

                              "Ruta ${rutaSeleccionada['nombre']}",

                              style:
                                  const TextStyle(

                                fontSize: 18,

                                fontWeight:
                                    FontWeight.bold,

                              ),

                            ),

                            const Divider(),

                            Text(

                              "🚚 Placa: ${rutaSeleccionada['placa']}",

                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(

                              "🏷 Económico: ${rutaSeleccionada['numero_economico']}",

                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(

                              "📦 Contenedor: ${rutaSeleccionada['contenedor']}",

                            ),

                          ],

                        ),

                      ),

                    ),

                  const SizedBox(
                    height: 30,
                  ),

                  const SizedBox(
  height: 30,
),

if(idOperacion == 0)

  SizedBox(

    width:
        double.infinity,

    child:
        ElevatedButton.icon(

      icon:
          const Icon(
            Icons.play_arrow,
          ),

      onPressed:
          iniciarOperacion,

      label:
          const Text(

        "INICIAR OPERACIÓN",

        style: TextStyle(

          fontWeight:
              FontWeight.bold,

        ),

      ),

    ),

  )

else

  Column(

    children: [

      Card(

        color: Colors.orange.shade50,

        child: Padding(

          padding:
              const EdgeInsets.all(
                12,
              ),

          child: Row(

            children: [

              const Icon(
                Icons.local_shipping,
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(

                child: Text(

                  "Operación #$idOperacion activa",

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

      const SizedBox(
        height: 12,
      ),

      SizedBox(

        width:
            double.infinity,

        child:
            ElevatedButton.icon(

          icon:
              const Icon(
                Icons.stop,
              ),

          onPressed:
              finalizarOperacion,

          label:
              Text(

            "FINALIZAR OPERACIÓN #$idOperacion",

            style:
                const TextStyle(

              fontWeight:
                  FontWeight.bold,

            ),

          ),

        ),

      ),

    ],

  ),

                ],

              ),

            ),

          ),

        ),

      ),

    ),

  );

}

}