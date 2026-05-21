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
  ViewImageBloc() : super(const ViewImageState()) {
    // set wall events
    on<ViewImageSetWall>(viewImageSetWall);

    // download wall events

    // like wall events
    on<ViewImageLikeWall>(viewImageLikeWall);

    // edit events
    on<EditingWall>(editingWall);
    on<EditWallBlurChanged>(editingWallBlurChanged);
    on<EditingWallCancel>(editingWallCancel);
    on<EditingWallDone>(editingWallDone);
  }

  // set wall event
  Future<void> viewImageSetWall(ViewImageSetWall event, Emitter<ViewImageState> emit,) async {
    emit(
        state.copyWith(
          isSettingWall: true,
          isError: false,
          showSnack: false,
          title: "",
          message: ""
        ));
    try {
      final boundary =
          event.boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        emit(
            state.copyWith(
                isSettingWall: false,
                isError: true,
                showSnack: true,
                title: "Error setting wall",
                message: "Could not capture image, please try again"
            )
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
            state.copyWith(
                isSettingWall: false,
                isError: false,
                showSnack: true,
                title: "Vibe Matched!",
                message: "Wall set to match your vive."
            )
        );

      await file.delete();
    } catch (e, st) {
      log(name: "Set Wall", "(viewImageSetWall)", error: e,stackTrace: st);
      emit(
          state.copyWith(
              isSettingWall: false,
              isError: true,
              showSnack: true,
              title: "Couldn't match vibe!",
              message: "Could not set Wall, please try again."
          )
      );
    }
  }

  // like wall event
  Future<void> viewImageLikeWall(
    ViewImageEvent event,
    Emitter<ViewImageState> emit,
  ) async {}

  // edit wall event
  Future<void> editingWall(EditingWall event, Emitter<ViewImageState> emit) async {
    emit(state.copyWith(showSnack: false,editStatus: EditStatus.editing));
  }

  Future<void> editingWallBlurChanged(EditWallBlurChanged event, Emitter<ViewImageState> emit) async {
    if(state.editStatus == EditStatus.editing){
      emit(state.copyWith(showSnack: false,blur: event.blur));
    }
  }

  Future<void> editingWallCancel(EditingWallCancel event, Emitter<ViewImageState> emit) async {
    if(state.editStatus == EditStatus.editing){
      emit(state.copyWith(showSnack: false,blur: 0.0, editStatus: EditStatus.initial));
    }
  }

  Future<void> editingWallDone(EditingWallDone event, Emitter<ViewImageState> emit) async {
    if(state.editStatus == EditStatus.editing){
      emit(state.copyWith(showSnack: false,editStatus: EditStatus.done));
    }
  }
}
