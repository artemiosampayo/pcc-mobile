enum Environment {
  dev,
  qa,
  prod,
}

class AppConstants {

  //============================================================
  // AMBIENTE ACTUAL
  //============================================================

  static const Environment currentEnvironment =
      Environment.qa;

  //============================================================
  // URLS POR AMBIENTE
  //============================================================

  static const String devApiUrl =
      "http://192.168.0.182";

  static const String qaApiUrl =
      "http://192.168.1.99";

  static const String prodApiUrl =
      "https://pcc.com.mx";

  //============================================================
  // URL ACTIVA
  //============================================================

  static String get apiUrl {

    switch (currentEnvironment) {

      case Environment.dev:
        return devApiUrl;

      case Environment.qa:
        return qaApiUrl;

      case Environment.prod:
        return prodApiUrl;
    }
  }

  //============================================================
  // EVIDENCIAS FOTOGRÁFICAS
  //============================================================

  static const double photoMaxWidth = 1600;

  static const int photoImageQuality = 80;
}