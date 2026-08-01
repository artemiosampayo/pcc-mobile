/// ===========================================================
///
/// PCC Mobile Framework
///
/// Archivo:
/// detalle_guia_screen.dart
///
/// Carpeta:
/// lib/screens/ruta/
///
/// Sprint:
/// SPR-003
///
/// Historia:
/// HU-021 - Información de la Guía
///
/// Descripción:
///
/// Permite consultar la información principal de una guía
/// antes de realizar una entrega o devolución.
///
/// La pantalla es únicamente de consulta.
///
/// Muestra:
///
/// • Número de guía.
/// • Destinatario.
/// • Dirección completa.
/// • Teléfono.
///
/// Esta pantalla podrá reutilizarse posteriormente desde:
///
/// • Mi Ruta.
/// • Pendientes.
/// • Entregadas.
/// • Devoluciones.
/// • Centro de Monitoreo.
///
/// ===========================================================

import 'package:flutter/material.dart';

class DetalleGuiaScreen extends StatelessWidget {

  final Map<String, dynamic> guia;

  const DetalleGuiaScreen({

    super.key,

    required this.guia,

  });

    @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Información de la Guía',
        ),

      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              Card(

  child: Padding(

    padding: const EdgeInsets.all(20),

    child: Column(

      children: [

                  Icon(
                    Icons.local_shipping_outlined,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(height: 12),

                  const Text(

                    'Guía',

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),

                  ),

                  const SizedBox(height: 12),

                  Text(

                    guia['numero_guia'] ?? 'Sin guía',

                    textAlign: TextAlign.center,

                    style: const TextStyle(

                      fontSize: 20,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

              ],

                  ),

                ),

              ),

              const SizedBox(height: 16),
              Card(

                child: Padding(

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    children: [

                      _buildInfoRow(
                         context: context,

                        icon: Icons.person_outline,

                        titulo: 'Destinatario',

                        valor: (guia['nombre_cliente']?.toString().trim().isNotEmpty ?? false)
                            ? guia['nombre_cliente']
                            : 'No disponible',

                      ),

                      const Divider(),

                      _buildInfoRow(
                        context: context,

                        icon: Icons.location_on_outlined,

                        titulo: 'Dirección',

                        valor: _buildDireccion(),

                      ),

                      const Divider(),

                      _buildInfoRow(
                         context: context,

                        icon: Icons.phone_outlined,

                        titulo: 'Teléfono',

                        valor: (guia['telefono']?.toString().trim().isNotEmpty ?? false)
                            ? guia['telefono']
                            : 'No disponible',

                      ),

                    ],

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(

                  valor,

                  style: const TextStyle(

                    fontSize: 15,

                    fontWeight: FontWeight.w500,

                  ),

                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildDireccion() {

    final calle =
        guia['calle']?.toString().trim() ?? '';

    final numero =
        guia['numero']?.toString().trim() ?? '';

    final colonia =
        guia['colonia']?.toString().trim() ?? '';

    final ciudad =
        guia['ciudad']?.toString().trim() ?? '';

    final estado =
        guia['estado']?.toString().trim() ?? '';

    final codigoPostal =
        guia['codigo_postal']?.toString().trim() ?? '';

    final List<String> lineas = [];

    //----------------------------------------------------------
    // Calle + Número
    //----------------------------------------------------------

    final calleCompleta = [
      calle,
      numero,
    ].where((e) => e.isNotEmpty).join(' ');

    if (calleCompleta.isNotEmpty) {
      lineas.add(calleCompleta);
    }

    //----------------------------------------------------------
    // Colonia
    //----------------------------------------------------------

    if (colonia.isNotEmpty) {
      lineas.add('COL. $colonia');
    }

    //----------------------------------------------------------
    // Ciudad, Estado
    //----------------------------------------------------------

    final ciudadEstado = [
      ciudad,
      estado,
    ].where((e) => e.isNotEmpty).join(', ');

    if (ciudadEstado.isNotEmpty) {
      lineas.add(ciudadEstado);
    }

    //----------------------------------------------------------
    // Código Postal
    //----------------------------------------------------------

    if (codigoPostal.isNotEmpty) {
      lineas.add(codigoPostal);
    }

    if (lineas.isEmpty) {
      return 'No disponible';
    }

    return lineas.join('\n');

  }

}