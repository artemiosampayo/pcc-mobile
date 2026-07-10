class Ubicacion {

  final int idUbicacion;

  final String nombre;

  Ubicacion({

    required this.idUbicacion,

    required this.nombre,

  });

  factory Ubicacion.fromJson(
    Map<String,dynamic> json,
  ){

    return Ubicacion(

      idUbicacion:
          json['id_ubicacion'],

      nombre:
          json['nombre'],

    );

  }

}