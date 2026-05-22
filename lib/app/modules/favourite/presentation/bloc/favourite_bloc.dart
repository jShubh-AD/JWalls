import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/helpers/app_helpers.dart';
import '../../../home/data/wallaper_response_modle.dart';
import '../../data/favourite_model.dart';
import '../../data/local_datasource.dart';

part 'favourite_event.dart';

part 'favourite_state.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  FavouriteBloc() : super(const FavouriteState()) {
    on<LoadFavourites>(_loadFavourites);
    on<ToggleLike>(_toggleLike);
    on<CheckIsLiked>(_checkIsLiked);
    on<ResetLikeState>((event, emit) {
      emit(state.copyWith(isLiking: false, isLiked: false, showSnack: false));
    });
  }

  Future<void> _loadFavourites(
    LoadFavourites event,
    Emitter<FavouriteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final favourites = LocalDatabase.instance.getFavourites();
    emit(state.copyWith(isLoading: false, favourites: favourites));
  }

  Future<void> _checkIsLiked(
    CheckIsLiked event,
    Emitter<FavouriteState> emit,
  ) async {
    final isLiked = LocalDatabase.instance.isFavourite(event.wallId);
    emit(state.copyWith(isLiked: isLiked));
  }

  Future<void> _toggleLike(
    ToggleLike event,
    Emitter<FavouriteState> emit,
  ) async {
    emit(state.copyWith(isLiking: true, showSnack: false));
    try {
      final db = LocalDatabase.instance;

      // unlike
      if (event.favWall != null) {
        final file = File(event.favWall!.imagePath!);
        if (await file.exists()) await file.delete();
        await db.removeFavourite(event.favWall!.id!);

        // update list and isLiked
        final updated = state.favourites
            .where((f) => f.id != event.favWall!.id)
            .toList();

        emit(
          state.copyWith(
            isLiking: false,
            isLiked: false,
            favourites: updated,
            showSnack: true,
            isError: false,
            title: "Removed",
            message: "Wall removed from liked.",
          ),
        );
        return;
      }

      // like
      final url = event.wall!.urls?.full ?? event.wall!.urls?.regular;
      if (url == null) {
        emit(
          state.copyWith(
            isLiking: false,
            showSnack: true,
            isError: true,
            title: "Error",
            message: "Could not save image, please try again",
          ),
        );
        return;
      }

      final bytes = await AppHelpers.urlToBytes(url);
      if (emit.isDone) {
        log("linking canceled after getting bytes ", name: "Toggle Like");
        return;
      }

      final file = File(
        '${db.likedFolder.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(bytes);
      if (emit.isDone) {
        log("linking canceled after file.write ", name: "Toggle Like");
        return;
      }

      final fav = FavouriteModel(
        id: event.wall!.id,
        imagePath: file.path,
        urls: event.wall!.urls,
        user: event.wall!.user,
      );
      await db.addFavourite(fav);
      if (emit.isDone) {
        log("linking canceled after db.write ", name: "Toggle Like");
        return;
      }

      emit(
        state.copyWith(
          isLiking: false,
          isLiked: true,
          favourites: [...state.favourites, fav],
          showSnack: true,
          isError: false,
          title: "Liked!",
          message: "Wall added to liked.",
        ),
      );
    } catch (e, st) {
      log("", name: "Toggle Like", error: e, stackTrace: st);
      emit(
        state.copyWith(
          isLiking: false,
          showSnack: true,
          isError: true,
          title: "Error",
          message: "Something went wrong, please try again",
        ),
      );
    }
  }
}
