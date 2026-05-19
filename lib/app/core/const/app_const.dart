import 'package:flutter/cupertino.dart';

abstract class AppConst {
  static const BorderRadius borderRadius10 = BorderRadius.all(Radius.circular(10));
  static const double xAxisSpacing = 8;
  static const double yAxisSpacing = 8;

  static double getMaxHeight(BuildContext c){
    return MediaQuery.sizeOf(c).height;
  }

  static double getMaxWidth(BuildContext c){
    return MediaQuery.sizeOf(c).width;
  }
}