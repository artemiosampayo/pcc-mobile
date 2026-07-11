import 'package:flutter/material.dart';
import '../scanner/barcode_scanner_screen.dart';
import '../../services/local/envio_local_service.dart';

class EconScreen extends StatefulWidget {

  const EconScreen({
    super.key,
  });

  @override
  State<EconScreen> createState() =>
      _EconScreenState();

}

class _EconScreenState
    extends State<EconScreen> {

  final EnvioLocalService service =
      EnvioLocalService();

  List<Map<String,dynamic>>
      envios = [];

  bool loading = true;

  int totalEscaneadas = 0;

  int totalPendientes = 0;

  bool procesandoEscaneo = false;

  @override
  void initState() {

    super.initState();

    cargar();

  }

  Future<void> cargar() async {

    envios = await service.obtenerEnvios();

    totalEscaneadas =
        envios.where(
          (e) => e['escaneada'] == 1,
        ).length;

    totalPendientes =
        envios.length - totalEscaneadas;

    if (!mounted) return;

    setState(() {

      loading = false;

    });

  }
  Future<void> escanearGuia() async {

  if (procesandoEscaneo) {
    return;
  }

  procesandoEscaneo = true;

  final codigo =
      await Navigator.push<String>(

    context,

    MaterialPageRoute(

      builder: (_) =>
          const BarcodeScannerScreen(),

    ),

  );

  procesandoEscaneo = false;

  if (codigo == null) {
    return;
  }

  final envio =
      await service.buscarPorGuia(
        codigo,
      );

  if (envio == null) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(
          'La guía no pertenece a esta operación.',
        ),

      ),

    );

    return;

  }

  if (envio['escaneada'] == 1) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(
          'La guía ya fue escaneada.',
        ),

      ),

    );

    return;

  }

  await service.marcarEscaneada(
    envio['id_envio'],
  );

  await cargar();

}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
          "ECON",
        ),

      ),
    
      floatingActionButton:

        FloatingActionButton.extended(

          onPressed:
              escanearGuia,

          icon:
              const Icon(
                Icons.qr_code_scanner,
              ),

          label:
              const Text(
                "ESCANEAR",
              ),

        ),
      body: SafeArea(

  child:

  loading

  ?


      const Center(

        child:
            CircularProgressIndicator(),

      )

      :

      Column(

        children: [

         
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: Column(
                            children: [

                              const Text(
                                "TOTAL",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                envios.length.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            children: [

                              const Text(
                                "ECON",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                totalEscaneadas.toString(),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            ],
                          ),
                        ),

                     

                      ],
                    ),

                    const SizedBox(height: 16),

                    LinearProgressIndicator(

                      value: envios.isEmpty
                          ? 0
                          : totalEscaneadas / envios.length,

                      minHeight: 10,

                      borderRadius:
                          BorderRadius.circular(10),

                    ),

                  ],
                ),
              ),
            ),
          ),
          Expanded(

            child:

            ListView.builder(

              itemCount:
                  envios.length,

              itemBuilder:

                  (_, index) {

                final e =
                    envios[index];

                return Card(

                  margin:

                      const EdgeInsets.symmetric(

                    horizontal: 12,

                    vertical: 5,

                  ),

                  child: ListTile(

                    leading: Icon(

                      e['escaneada'] == 1
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,

                      color:

                          e['escaneada'] == 1

                              ? Colors.green

                              : Colors.grey,

),


                    title:

                        Text(

                      e['numero_guia'],

                    ),

                    subtitle:

                        Text(

                      e['cliente'],

                    ),

                    trailing: Column(

                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      crossAxisAlignment:
                          CrossAxisAlignment.end,

                      children: [

                        Text(
                          e['estado_envio'],
                        ),

                        const SizedBox(height: 4),

                        Text(

                          e['escaneada'] == 1

                              ? "Escaneada"

                              : "Pendiente",

                          style: TextStyle(

                            color:

                                e['escaneada'] == 1

                                    ? Colors.green

                                    : Colors.orange,

                            fontWeight:
                                FontWeight.bold,

                          ),

                        ),

                      ],

                    ),

                  ),

                );

              },

            ),

          ),
Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  175, // Reserva espacio para el botón ESCANEAR
                  16,
                ),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: totalEscaneadas > 0
          ? () async {

              final confirmar =
                  await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Confirmar ECON',
                    ),
                    content: Text(
                      'Se confirmará un manifiesto con '
                      '$totalEscaneadas guía(s).\n\n'
                      '¿Desea continuar?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            false,
                          );
                        },
                        child: const Text(
                          'Cancelar',
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            true,
                          );
                        },
                        child: const Text(
                          'Confirmar',
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirmar != true) {
                return;
              }

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'ECON confirmado.',
                  ),
                ),
              );

              // Aquí en el siguiente bloque
              // cambiaremos el Workflow
              // y navegaremos a InicioRutaScreen.

            }
          : null,
      icon: const Icon(
        Icons.check_circle,
      ),
      label: const Text(
        'CONFIRMAR ECON',
      ),
    ),
  ),
),
        ],

      ),
      ),
    );

  }

}