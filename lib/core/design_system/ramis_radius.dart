import 'package:flutter/widgets.dart';

abstract final class RamisRadius {
  static const double smallValue = 8;
  static const double mediumValue = 12;
  static const double largeValue = 16;
  static const double extraLargeValue = 24;

  static const BorderRadius small =
      BorderRadius.all(Radius.circular(smallValue));
  static const BorderRadius medium =
      BorderRadius.all(Radius.circular(mediumValue));
  static const BorderRadius large =
      BorderRadius.all(Radius.circular(largeValue));
  static const BorderRadius extraLarge =
      BorderRadius.all(Radius.circular(extraLargeValue));
}
