import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walpy/app/core/utils/const/app_const.dart';
import 'package:walpy/app/modules/view_image/bloc/view_image_bloc.dart';

class BlurSliderWidget extends StatelessWidget {
  const BlurSliderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.black87,
      shape: AppConst.recBorderRadius24,
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
                  onTap: () =>
                      context.read<ViewImageBloc>().add(EditingWallCancel()),
                  child: Icon(Icons.close, color: Colors.white),
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
                  onTap: () =>
                      context.read<ViewImageBloc>().add(EditingWallDone()),
                  child: Icon(Icons.check, color: Colors.white),
                ),
              ],
            ),
            BlocBuilder<ViewImageBloc, ViewImageState>(
              builder: (context, state) {
                final blur = switch (state) {
                  EditingWallState(:final blur) => blur,
                  EditingWallDoneState(:final blur) => blur,
                  _ => 0.0
                };
                return Slider(
                  value: blur,
                  onChanged: (v) => context.read<ViewImageBloc>().add(
                    EditWallBlurChanged(blur: v),
                  ),
                  min: 0,
                  max: 10,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
