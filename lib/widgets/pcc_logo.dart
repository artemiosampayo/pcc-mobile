import 'package:flutter/material.dart';

class PCCLogo extends StatelessWidget {

  final double width;

  const PCCLogo({
    super.key,
    this.width = 220,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return Image.asset(

      'assets/images/logo_pcc2.png',

      width: width,

      fit: BoxFit.contain,

    );

  }

}