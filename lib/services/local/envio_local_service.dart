/// ===========================================================
///
/// PCC Mobile Framework
///
/// Archivo:
/// envio_local_service.dart
///
/// Carpeta:
/// lib/services/local/
///
/// Sprint:
/// SPR-001
///
/// Historia:
/// HU-005 - ECON
///
/// Descripción:
///
/// Servicio responsable de administrar las guías almacenadas
/// localmente en SQLite.
///
/// Es utilizado por:
///
/// - Configuración Ruta
/// - ECON
/// - Mi Ruta
/// - Entregas
/// - Devoluciones
///
/// ===========================================================
import '../../database/database_helper.dart';

class EnvioLocalService {

  Future<void> limpiarTabla()
  async {

    final db =
        await DatabaseHelper
            .instance
            .database;

    await db.delete(
      'envios_local',
    );

  }

  Future<void> insertarEnvio(Map<String,dynamic> envio,)
  async {

    final db =
        await DatabaseHelper
            .instance
            .database;

    await db.insert(

      'envios_local',

      envio,

    );

  }

  Future<List<Map<String,dynamic>>> obtenerEnvios()
  async {

    final db =
        await DatabaseHelper
            .instance
            .database;

    return await db.query(
      'envios_local',
    );

  }

  Future<Map<String,dynamic>?> buscarPorGuia(String guia,)
  async {

    final db =
        await DatabaseHelper
            .instance
            .database;

    final resultado =
        await db.query(

      'envios_local',

      where:
          'numero_guia = ?',

      whereArgs: [
        guia
      ],

      limit: 1,

    );

    if(
        resultado.isEmpty
    ){

      return null;

    }

    return resultado.first;

  }

  Future<void> actualizarEstado(int idEnvio,String estatus,)
  async {

    final db =
        await DatabaseHelper
            .instance
            .database;

    await db.update(

      'envios_local',

      {

        'estatus_local':
            estatus

      },

      where:
          'id_envio = ?',

      whereArgs: [

        idEnvio

      ],

    );

  }

  Future<void> guardarGuias(List<dynamic> guias,) 
  async {

    await limpiarTabla();

    for (final guia in guias) {

      await insertarEnvio({

        'id_envio':
            guia['id_envio'],

        'numero_guia':
            guia['numero_guia'],

        'pedido':
            guia['pedido'],

        'cliente':
            guia['cliente'],

        'nombre_cliente':
            guia['nombre_cliente'],

        'calle':
            guia['calle'],

        'numero':
            guia['numero'],

        'colonia':
            guia['colonia'],

        'ciudad':
            guia['ciudad'],

        'estado':
            guia['estado'],

        'codigo_postal':
            guia['codigo_postal'],

        'numero_caja':
            guia['numero_caja'],

        'total_caja':
            guia['total_caja'],

        'estado_envio':
            guia['estado_envio'],

        'escaneada': 0,

        'fecha_escaneo': null,

        'estatus_local': 'PENDIENTE',

        'sincronizado': 0,

      });

    }

  }
Future<void> marcarEscaneada(int idEnvio,) 
async {

  final db =
      await DatabaseHelper
          .instance
          .database;

  await db.update(

    'envios_local',

    {

      'escaneada': 1,

      'fecha_escaneo':
          DateTime.now().toIso8601String(),

      'estatus_local': 'CARGADA',

    },

    where: 'id_envio = ?',

    whereArgs: [

      idEnvio,

    ],

  );

}
Future<void> desmarcarEscaneada(int idEnvio,) 
async {

  final db =
      await DatabaseHelper
          .instance
          .database;

  await db.update(

    'envios_local',

    {

      'escaneada': 0,

      'fecha_escaneo': null,

      'estatus_local': 'PENDIENTE',

    },

    where: 'id_envio = ?',

    whereArgs: [

      idEnvio,

    ],

  );

}

Future<List<Map<String,dynamic>>> obtenerEscaneadas()
async {

  final db =
      await DatabaseHelper
          .instance
          .database;

  return await db.query(

    'envios_local',

    where:
        'escaneada = 1',

  );

}
Future<List<Map<String,dynamic>>> obtenerPendientes()
async {

  final db =
      await DatabaseHelper
          .instance
          .database;

  return await db.query(

    'envios_local',

    where:
        'escaneada = 0',

  );

}
Future<int> totalEscaneadas()
async {

  final db =
      await DatabaseHelper
          .instance
          .database;

  final resultado =
      await db.rawQuery(

    '''

    SELECT COUNT(*) total

    FROM envios_local

    WHERE escaneada = 1

    '''

  );

  return resultado.first['total']
      as int;

}

}