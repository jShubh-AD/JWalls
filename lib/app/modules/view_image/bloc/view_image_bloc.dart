import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

part 'view_image_event.dart';

part 'view_image_state.dart';

class ViewImageBloc extends Bloc<ViewImageEvent, ViewImageState> {
  ViewImageBloc() : super(ViewImageInitial()) {
    on<ViewImageSetWall>(viewImageSetWall);
    on<ViewImageLikeWall>(viewImageLikeWall);

    // edit events
    on<EditingWall>(editingWall);
    on<EditWallBlurChanged>(editingWallBlurChanged);
    on<EditingWallCancel>(editingWallCancel);
    on<EditingWallDone>(editingWallDone);
  }

  Future<void> viewImageSetWall(ViewImageSetWall event, Emitter<ViewImageState> emit,) async {
    emit(ViewImageSetWallState());
    try {
      final boundary =
          event.boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        emit(
          SetWallResultState(
            "Error setting wall",
            "Could not capture image, please try again",
            isError:  true
          ),
        );
      }

      final ui.Image uiImage = await boundary!.toImage(pixelRatio: 3.0);
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/JWalls_edited_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final ok = await WallpaperManagerFlutter().setWallpaper(
        file,
        WallpaperManagerFlutter.bothScreens, // todo: ask user (1,2,3)
      );
      if (ok)
        emit(
          SetWallResultState(
            "Vibe Matched!",
            "Wall set to match your vive.",
            isError:  false
          ),
        );
      await file.delete();
    } catch (e, st) {
      log(name: "Set Wall", "(viewImageSetWall)", error: e,stackTrace: st);
      emit(
        SetWallResultState(
          "Couldn't match vibe!",
          "Could not set Wall, please try again.",
          isError: true
        ),
      );
    }
  }

  Future<void> viewImageLikeWall(
    ViewImageEvent event,
    Emitter<ViewImageState> emit,
  ) async {}

  Future<void> editingWall(EditingWall event, Emitter<ViewImageState> emit) async {
    final blur = state is EditingWallDoneState
        ? (state as EditingWallDoneState).blur
        : 0.0;
    emit(EditingWallState(blur: blur));
  }

  Future<void> editingWallBlurChanged(EditWallBlurChanged event, Emitter<ViewImageState> emit) async {
    emit(EditingWallState(blur: event.blur));
  }

  Future<void> editingWallCancel(EditingWallCancel event, Emitter<ViewImageState> emit) async {
    emit(ViewImageInitial());
  }

  Future<void> editingWallDone(EditingWallDone event, Emitter<ViewImageState> emit) async {
    final blur = state is EditingWallState
        ? (state as EditingWallState).blur
        : 0.0;
    emit(EditingWallDoneState(blur: blur));
    // throw some error like like save or no changes made or just rest blur
  }
}
