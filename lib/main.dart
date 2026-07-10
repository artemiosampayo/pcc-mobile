import 'package:flutter/material.dart';

import 'screens/login/login_screen.dart';
import 'core/theme/app_theme.dart';

void main() {

  runApp(
    const PCCApp(),
  );

}

class PCCApp extends StatelessWidget {

  const PCCApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'PCC Mobile',

      theme: AppTheme.theme,

      home:
          const LoginScreen(),

    );

  }

}