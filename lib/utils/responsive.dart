import 'package:flutter/material.dart';
import 'dart:math';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double textScaleFactor;

  // Base design dimensions (e.g., iPhone 11 Pro)
  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    textScaleFactor = _mediaQueryData.textScaleFactor;
  }

  static double get widthMultiplier => screenWidth / _designWidth;
  static double get heightMultiplier => screenHeight / _designHeight;

  /// Returns a width scaled according to screen size
  static double w(double width) => width * widthMultiplier;

  /// Returns a height scaled according to screen size
  static double h(double height) => height * heightMultiplier;

  /// Returns a font size scaled according to screen size
  static double sp(double fontSize) =>
      fontSize * min(widthMultiplier, heightMultiplier);

  /// Returns a radius scaled according to screen size
  static double r(double radius) =>
      radius * min(widthMultiplier, heightMultiplier);

  /// Returns an icon size scaled according to screen size
  static double i(double size) =>
      size * min(widthMultiplier, heightMultiplier);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;
}

extension ResponsiveExtension on num {
  double get w => Responsive.w(toDouble());
  double get h => Responsive.h(toDouble());
  double get sp => Responsive.sp(toDouble());
  double get r => Responsive.r(toDouble());
  double get i => Responsive.i(toDouble());
}
