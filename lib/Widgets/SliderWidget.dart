import 'package:flutter/material.dart';

class BlurSliderWidget extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final void Function() checkPressed;
  final void Function() closePressed;
  final ValueChanged<double> onChanged;

  const BlurSliderWidget({
    Key? key,
    required this.checkPressed,
    required this.closePressed,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
    this.divisions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.black.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: closePressed,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    )
                ),
                const Text(
                  'Blur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                    onTap: checkPressed,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    )
                )
              ],
            ),
            Slider(
              value: value,
              onChanged: onChanged,
              min: min,
              max: max,
              divisions: divisions,
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }
}
