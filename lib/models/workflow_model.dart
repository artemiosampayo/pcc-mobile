/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// workflow_model.dart
///
/// Carpeta:
/// lib/models/
///
/// Descripción:
///
/// Representa la operación activa del dispositivo.
///
/// Este modelo será utilizado por:
///
/// • WorkflowLocalService
/// • WorkflowManager
/// • Drawer
/// • Header
///
/// ===========================================================

import '../core/enums/operation_state.dart';

class WorkflowModel {

  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------

  WorkflowModel({

    this.id,

    this.idOperacion,

    this.idRuta,

    this.nombreRuta,

    this.idOperador,

    this.nombreOperador,

    this.idUbicacion,

    this.nombreUbicacion,

    this.contenedor,

    this.placa,

    this.numeroEconomico,

    this.estadoOperacion =
        OperationState.sinOperacion,

    this.fechaInicio,

    this.fechaActualizacion,

  });

  //------------------------------------------------------------
  // Propiedades
  //------------------------------------------------------------

  final int? id;

  final int? idOperacion;

  final int? idRuta;

  final String? nombreRuta;

  final int? idOperador;

  final String? nombreOperador;

  final int? idUbicacion;

  final String? nombreUbicacion;

  final String? contenedor;

  final OperationState estadoOperacion;

  final String? fechaInicio;

  final String? fechaActualizacion;

  final String? placa;

  final String? numeroEconomico;

  //------------------------------------------------------------
  // fromMap
  //------------------------------------------------------------

  factory WorkflowModel.fromMap(
      Map<String, dynamic> map) {

    return WorkflowModel(

      id: map['id'],

      idOperacion:
          map['id_operacion'],

      idRuta:
          map['id_ruta'],

      nombreRuta:
          map['nombre_ruta'],

      idOperador:
          map['id_operador'],

      nombreOperador:
          map['nombre_operador'],

      idUbicacion:
          map['id_ubicacion'],

      nombreUbicacion:
          map['nombre_ubicacion'],

      contenedor:
          map['contenedor'],

      placa:
          map['placa'],

      numeroEconomico: 
          map['numero_economico'],

      estadoOperacion:
          OperationState.values.firstWhere(

            (e) =>

                e.name ==
                map['estado_operacion'],

            orElse: () =>

                OperationState.sinOperacion,

          ),

      fechaInicio:
          map['fecha_inicio'],

      fechaActualizacion:
          map['fecha_actualizacion'],

    );

  }

  //------------------------------------------------------------
  // toMap
  //------------------------------------------------------------

  Map<String, dynamic> toMap() {

    return {

      'id': id,

      'id_operacion': idOperacion,

      'id_ruta': idRuta,

      'nombre_ruta': nombreRuta,

      'id_operador': idOperador,

      'nombre_operador': nombreOperador,

      'id_ubicacion': idUbicacion,

      'nombre_ubicacion': nombreUbicacion,

      'contenedor': contenedor,

      'placa':placa,

      'numero_economico':numeroEconomico,

      'estado_operacion':
          estadoOperacion.name,

      'fecha_inicio':
          fechaInicio,

      'fecha_actualizacion':
          fechaActualizacion,

    };

  }

  //------------------------------------------------------------
  // copyWith
  //------------------------------------------------------------

  WorkflowModel copyWith({

    int? id,

    int? idOperacion,

    int? idRuta,

    String? nombreRuta,

    int? idOperador,

    String? nombreOperador,

    int? idUbicacion,

    String? nombreUbicacion,

    String? contenedor,

    String? placa,

    String? numeroEconomico,

    OperationState? estadoOperacion,

    String? fechaInicio,

    String? fechaActualizacion,

  }) {

    return WorkflowModel(

      id:
          id ?? this.id,

      idOperacion:
          idOperacion ??
          this.idOperacion,

      idRuta:
          idRuta ??
          this.idRuta,

      nombreRuta:
          nombreRuta ??
          this.nombreRuta,

      idOperador:
          idOperador ??
          this.idOperador,

      nombreOperador:
          nombreOperador ??
          this.nombreOperador,

      idUbicacion:
          idUbicacion ??
          this.idUbicacion,

      nombreUbicacion:
          nombreUbicacion ??
          this.nombreUbicacion,

      contenedor:
          contenedor ??
          this.contenedor,
      
      placa: 
          placa ??
          this.placa,

      numeroEconomico: 
          numeroEconomico ??
          this.numeroEconomico,

      estadoOperacion:
          estadoOperacion ??
          this.estadoOperacion,

      fechaInicio:
          fechaInicio ??
          this.fechaInicio,

      fechaActualizacion:
          fechaActualizacion ??
          this.fechaActualizacion,

    );

  }

}