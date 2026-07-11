/// ===========================================================
///
/// PCC Mobile Framework
///
/// Archivo:
/// envio_tile.dart
///
/// Carpeta:
/// lib/widgets/
///
/// Sprint:
/// SPR-002
///
/// Historia:
/// HU-005 - ECON
///
/// Descripción:
///
/// Widget reutilizable para mostrar una guía dentro de las
/// diferentes pantallas del sistema.
///
/// Será utilizado por:
///
/// - ECON
/// - Mi Ruta
/// - Entregas
/// - Devoluciones
///
/// ===========================================================

import 'package:flutter/material.dart';

class EnvioTile extends StatelessWidget {
  final String numeroGuia;
  final String cliente;
  final String estado;
  final bool escaneada;
  final VoidCallback? onTap;

  const EnvioTile({
    super.key,
    required this.numeroGuia,
    required this.cliente,
    required this.estado,
    required this.escaneada,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorEstado =
        escaneada ? Colors.green : Colors.grey;

    final IconData icono =
        escaneada
            ? Icons.check_circle
            : Icons.radio_button_unchecked;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icono,
          color: colorEstado,
          size: 32,
        ),
        title: Text(
          numeroGuia,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(cliente),
        trailing: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              estado,
              style: TextStyle(
                color: colorEstado,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              escaneada
                  ? "Escaneada"
                  : "Pendiente",
              style: TextStyle(
                color: colorEstado,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}