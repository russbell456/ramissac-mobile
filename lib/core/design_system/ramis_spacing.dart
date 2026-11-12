import 'package:flutter/widgets.dart';

abstract final class RamisSpacing {
  static const double xSmall = 4;
  static const double small = 8;
  static const double mediumSmall = 12;
  static const double medium = 16;
  static const double large = 20;
  static const double xLarge = 24;
  static const double xxLarge = 32;
  static const double xxxLarge = 40;
  static const double huge = 48;

  static const EdgeInsets cardPadding = EdgeInsets.all(medium);
  static const EdgeInsets screenPadding = EdgeInsets.all(medium);
}
