import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FloatingButtons extends StatelessWidget {
  const FloatingButtons({
    super.key,
    required this.edit,
    required this.download,
    required this.info,
    required this.editPressed,
    required this.downloadPressed,
    required this.infoPressed
  });

  final Widget edit;
  final Widget download;
  final Widget info;
  final void Function() editPressed;
  final void Function() downloadPressed;
  final void Function() infoPressed;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      heroTag: null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      spacing: 4,
      overlayOpacity: .3,
      childrenButtonSize: Size(56, 67),
      backgroundColor: Colors.white,
      overlayColor: Colors.black,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(color: Colors.black),
      children: [
        SpeedDialChild(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            onTap: editPressed,
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