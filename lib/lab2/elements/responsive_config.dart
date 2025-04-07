import 'package:flutter/material.dart';

class ResponsiveConfig {
  static double iconSize(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600 ? 24.0 : 30.0;

  static double drawerFontSize(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600 ? 16.0 : 20.0;

  static double contentFontSize(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600 ? 20.0 : 24.0;

  static double avatarRadius(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return screenSize.width < 600 ? 39.0 : 45.0;
  }

  static double spacing(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return screenSize.height / (isLandscape ? 40 : 20);
  }

  static double fontSizeName(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return screenSize.width < 600 ? 16.0 : 20.0;
  }

  static double fontSizeEmail(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return screenSize.width < 600 ? 20.0 : 24.0;
  }

}
