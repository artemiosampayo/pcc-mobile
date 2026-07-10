import 'package:flutter/material.dart';

class AppTheme {

  static const Color primary =
      Color(0xFF1E1E2F);

  static const Color accent =
      Color(0xFFF57C00);

  static ThemeData theme =
      ThemeData(

    useMaterial3: true,

    scaffoldBackgroundColor:
        const Color(0xFFF5F6FA),

    colorScheme:
        ColorScheme.fromSeed(

      seedColor: primary,

    ),

    appBarTheme:
        const AppBarTheme(

      backgroundColor:
          primary,

      foregroundColor:
          Colors.white,

      centerTitle: true,

    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(

      style:
          ElevatedButton.styleFrom(

        backgroundColor:
            accent,

        foregroundColor:
            Colors.white,

        minimumSize:
            const Size(
              double.infinity,
              55,
            ),

      ),

    ),

  );

}