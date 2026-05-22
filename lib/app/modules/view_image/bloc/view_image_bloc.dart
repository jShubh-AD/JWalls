import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import '../../../core/utils/helpers/app_helpers.dart';

part 'view_image_event.dart';

part 'view_image_state.dart';

class ViewImageBloc extends Bloc<ViewImageEvent, ViewImageState> {
  ViewImageBloc() : super(const ViewImageState()) {
    // set wall events
    on<ViewImageSetWall>(viewImageSetWall);

    // download wall events
    on<DownloadWall>(downloadWall);

    on<ViewImageClearSnack>(viewImageClearSnack);

    // edit events
    on<EditingWall>(editingWall);
    on<EditWallBlurChanged>(editingWallBlurChanged);
    on<EditingWallCancel>(editingWallCancel);
    on<EditingWallDone>(editingWallDone);
  }

  // Set Wall Event
  Future<void> viewImageSetWall(
    ViewImageSetWall event,
    Emitter<ViewImageState> emit,
  ) async {
    emit(
      state.copyWith(
        isSettingWall: true,
        isError: false,
        showSnack: false,
        title: "",
        message: "",
      ),
    );
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
            message: "Could not capture image, please try again",
          ),
        );
        return;
      }

      final bytes = await AppHelpers.boundaryToBytes(boundary);

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
            message: "Wall set to match your vive.",
          ),
        );
      await file.delete();
    } catch (e, st) {
      log(name: "Set Wall", "(viewImageSetWall)", error: e, stackTrace: st);
      emit(
        state.copyWith(
          isSettingWall: false,
          isError: true,
          showSnack: true,
          title: "Couldn't match vibe!",
          message: "Could not set Wall, please try again.",
        ),
      );
    }
  }

  // Download Wall Event
  Future<void> downloadWall(
    DownloadWall event,
    Emitter<ViewImageState> emit,
  ) async {
    if (state.editStatus == EditStatus.editing) return;
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      emit(
        state.copyWith(
          showSnack: true,
          isDownloading: false,
          isError: true,
          title: "Permission Denied!",
          message: "Provide access from settings before trying again.",
        ),
      );
      return;
    }
    try {
      emit(state.copyWith(isDownloading: true));
      Uint8List bytes;
      if (state.blur > 0) {
        final boundary =
            event.boundaryKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary == null) {
          emit(
            state.copyWith(
              isSettingWall: false,
              isDownloading: false,
              isError: true,
              showSnack: true,
              title: "Error setting wall",
              message: "Could not capture image, please try again",
            ),
          );
          return;
        }
        bytes = await AppHelpers.boundaryToBytes(boundary);
      } else if (event.url != null) {
        final url = event.url;
        if (url == null) {
          emit(
            state.copyWith(
              showSnack: true,
              isDownloading: false,
              isError: true,
              title: "Couldn't download wall",
              message: "Could not download this wall, please try again.",
            ),
          );
          return;
        }
        bytes = await AppHelpers.urlToBytes(url);
      } else {
        bytes = event.bytes!;
      }
      final AssetEntity? entity = await PhotoManager.editor.saveImage(
        bytes,
        filename: 'JWalls_${DateTime.now().millisecondsSinceEpoch}',
        title: 'JWalls_${DateTime.now().millisecondsSinceEpoch}',
        desc: 'Saved by JWalls',
      );
      if (entity != null) {
        emit(
          state.copyWith(
            showSnack: true,
            isDownloading: false,
            isError: false,
            title: "Wall saved",
            message: "This wall have been saved in your gallery.",
          ),
        );
      }
    } catch (e, st) {
      emit(
        state.copyWith(
          showSnack: true,
          isError: true,
          isDownloading: false,
          title: "Couldn't download wall",
          message: "Could not download this wall, please try again.",
        ),
      );
      log(name: "Download", "", error: e, stackTrace: st);
    }
  }

  // Edit Wall Event
  Future<void> editingWall(
    EditingWall event,
    Emitter<ViewImageState> emit,
  ) async {
    if (state.editStatus == EditStatus.editing) return;
    emit(state.copyWith(showSnack: false, editStatus: EditStatus.editing));
  }

  Future<void> editingWallBlurChanged(
    EditWallBlurChanged event,
    Emitter<ViewImageState> emit,
  ) async {
    if (state.editStatus == EditStatus.editing) {
      emit(state.copyWith(showSnack: false, blur: event.blur));
    }
  }

  Future<void> editingWallCancel(
    EditingWallCancel event,
    Emitter<ViewImageState> emit,
  ) async {
    if (state.editStatus == EditStatus.editing) {
      emit(
        state.copyWith(
          showSnack: false,
          blur: 0.0,
          editStatus: EditStatus.initial,
        ),
      );
    }
  }

  Future<void> editingWallDone(
    EditingWallDone event,
    Emitter<ViewImageState> emit,
  ) async {
    if (state.editStatus == EditStatus.editing) {
      emit(state.copyWith(showSnack: false, editStatus: EditStatus.done));
    }
  }

  Future<void> viewImageClearSnack(
    ViewImageClearSnack event,
    Emitter<ViewImageState> emit,
  ) async {
    if (state.showSnack) {
      emit(state.copyWith(showSnack: false, title: "", message: ""));
    }
  }
}
