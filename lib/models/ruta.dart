class Ruta {

  final int idRuta;

  final String nombre;

  Ruta({

    required this.idRuta,

    required this.nombre,

  });

  factory Ruta.fromJson(
    Map<String,dynamic> json,
  ){

    return Ruta(

      idRuta:
          json['id_ruta'],

      nombre:
          json['nombre'],

    );

  }

}