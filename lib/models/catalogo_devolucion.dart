/// ===========================================================
///
/// PCC Mobile Framework v1.0
///
/// Archivo:
/// catalogo_devolucion.dart
///
/// Carpeta:
/// lib/models/
///
/// Descripción:
///
/// Representa un registro del catálogo de devoluciones.
///
/// Este modelo será utilizado por:
///
/// • CatalogService
/// • CatalogoLocalService
/// • CatalogSyncService
/// • DevolucionScreen
///
/// ===========================================================

class CatalogoDevolucion {

  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------

  CatalogoDevolucion({

    required this.idDevolucion,

    required this.codigo,

    required this.descripcion,

    required this.ordenVisual,

    this.fechaSincronizacion,

  });

  //------------------------------------------------------------
  // Propiedades
  //------------------------------------------------------------

  final int idDevolucion;

  final String codigo;

  final String descripcion;

  final int ordenVisual;

  final String? fechaSincronizacion;

  //------------------------------------------------------------
  // fromJson
  //------------------------------------------------------------

  factory CatalogoDevolucion.fromJson(
      Map<String, dynamic> json) {

    return CatalogoDevolucion(

      idDevolucion:
          json['id_devolucion'],

      codigo:
          json['codigo'],

      descripcion:
          json['descripcion'],

      ordenVisual:
          json['orden_visual'],

    );

  }

  //------------------------------------------------------------
  // fromMap
  //------------------------------------------------------------

  factory CatalogoDevolucion.fromMap(
      Map<String, dynamic> map) {

    return CatalogoDevolucion(

      idDevolucion:
          map['id_devolucion'],

      codigo:
          map['codigo'],

      descripcion:
          map['descripcion'],

      ordenVisual:
          map['orden_visual'],

      fechaSincronizacion:
          map['fecha_sincronizacion'],

    );

  }

  //------------------------------------------------------------
  // toMap
  //------------------------------------------------------------

  Map<String, dynamic> toMap() {

    return {

      'id_devolucion':
          idDevolucion,

      'codigo':
          codigo,

      'descripcion':
          descripcion,

      'orden_visual':
          ordenVisual,

      'fecha_sincronizacion':
          fechaSincronizacion,

    };

  }

}