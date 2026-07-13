/// ===========================================================
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// operation_header.dart
///
/// Carpeta:
/// lib/widgets/
///
/// Descripción:
/// Encabezado reutilizable que muestra el contexto de la
/// operación activa en las pantallas operativas de PCC Mobile.
///
/// Utilizado por:
/// • ECON
/// • Inicio de Ruta
/// • Mi Ruta
/// • Entrega
/// • Devolución
/// ===========================================================

import 'package:flutter/material.dart';

import '../models/workflow_model.dart';

class OperationHeader extends StatelessWidget {
  const OperationHeader({
    super.key,
    required this.workflow,
  });

  final WorkflowModel workflow;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRow(
              Icons.route,
              'Ruta',
              workflow.nombreRuta,
            ),
            const SizedBox(height: 10),
            _buildRow(
              Icons.person,
              'Operador',
              workflow.nombreOperador,
            ),
            const SizedBox(height: 10),
            _buildRow(
              Icons.location_on,
              'Plaza',
              workflow.nombreUbicacion,
            ),
            const SizedBox(height: 10),
            _buildRow(
              Icons.local_shipping,
              'Económico',
              workflow.numeroEconomico,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String label,
    String? value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: _displayValue(value),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '—';
    }

    return value;
  }
}