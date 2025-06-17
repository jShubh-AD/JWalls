import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FloatingButtons extends StatelessWidget {
  const FloatingButtons({
    super.key,
    required this.edit,
    required this.onPressed,
    required this.download,
    required this.info,
    required this.profilePressed,
    required this.downloadPressed,
    required this.infoPressed
  });

  final Widget edit;
  final Widget download;
  final Widget info;
  final void Function() onPressed;
  final void Function() profilePressed;
  final void Function() downloadPressed;
  final void Function() infoPressed;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      heroTag: null,
      spacing: 4,
      childrenButtonSize: Size(55, 66),
      backgroundColor: Colors.white,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(color: Colors.black),
      children: [
        SpeedDialChild(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            onTap: profilePressed,
            child: edit
        ),
        SpeedDialChild(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            onTap: downloadPressed,
            child: download
        ),
        SpeedDialChild(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            onTap: infoPressed,
            child: info
        ),
      ],
    );
  }
}