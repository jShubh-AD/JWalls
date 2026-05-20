import 'package:flutter/material.dart';

abstract class AppConst {
  static const BorderRadius borderRadius10 = BorderRadius.all(Radius.circular(10));
  static const BorderRadius borderRadius18 = BorderRadius.all(Radius.circular(18));
  static const RoundedRectangleBorder recBorderRadius24 = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)));
  static const double xAxisSpacing = 8;
  static const double yAxisSpacing = 8;

  static const Widget sizedBoxH10 = const SizedBox(height: 10);

  static double getMaxHeight(BuildContext c){
    return MediaQuery.sizeOf(c).height;
  }

  static double getMaxWidth(BuildContext c){
    return MediaQuery.sizeOf(c).width;
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

}