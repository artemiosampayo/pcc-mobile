import 'package:flutter/material.dart';

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

  @override
  void initState() {

    super.initState();

    cargar();

  }

  Future<void> cargar()
  async {

    envios =
        await service
            .obtenerEnvios();

    setState(() {

      loading = false;

    });

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

      body:

      loading

      ?

      const Center(

        child:
            CircularProgressIndicator(),

      )

      :

      Column(

        children: [

          Card(

            margin:
                const EdgeInsets.all(
                  16,
                ),

            child: ListTile(

              leading:
                  const Icon(
                    Icons.download,
                    color: Colors.green,
                  ),

              title: Text(

                "${envios.length} guías descargadas",

              ),

              subtitle: const Text(

                "Listas para ECON",

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

                    leading:

                        const Icon(

                      Icons.inventory_2,

                      color:
                          Colors.orange,

                    ),

                    title:

                        Text(

                      e['numero_guia'],

                    ),

                    subtitle:

                        Text(

                      e['cliente'],

                    ),

                    trailing:

                        Text(

                      e['estado_envio'],

                    ),

                  ),

                );

              },

            ),

          ),

        ],

      ),

    );

  }

}