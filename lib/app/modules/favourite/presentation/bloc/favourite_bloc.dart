import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/helpers/app_helpers.dart';
import '../../../home/data/wallaper_response_modle.dart';
import '../../data/favourite_model.dart';
import '../../domain/favourite_usecase.dart';

part 'favourite_event.dart';
part 'favourite_state.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  final FavouriteUseCase _favouriteUseCase;

  FavouriteBloc(this._favouriteUseCase) : super(const FavouriteInitial()) {
    on<LoadFavourites>(_loadFavourites);
    on<ToggleLike>(_toggleLike);
    on<ClearSnack>(_clearSnack);
  }

  Future<void> _loadFavourites(
    LoadFavourites event,
    Emitter<FavouriteState> emit,
  ) async {
    emit(const FavouriteLoading());
    try {
      final favourites = _favouriteUseCase.getFavourites();
      emit(FavouriteLoaded(favourites: favourites));
    } catch (e, st) {
      log("Error loading favourites", error: e, stackTrace: st);
      emit(FavouriteFailure(e.toString()));
    }
  }

  void _clearSnack(ClearSnack event, Emitter<FavouriteState> emit) {
    if (state is FavouriteLoaded) {
      emit((state as FavouriteLoaded).copyWith(clearSnack: true));
    }
  }

  Future<void> _toggleLike(
    ToggleLike event,
    Emitter<FavouriteState> emit,
  ) async {
    final currentState = state;
    final List<FavouriteModel> currentFavourites =
        currentState is FavouriteLoaded ? currentState.favourites : [];

    final id = event.wall?.id ?? event.favWall?.id;
    if (id == null) return;

    emit(FavouriteLoaded(favourites: currentFavourites, togglingFavId: id));

    try {
      final existingIndex = currentFavourites.indexWhere((f) => f.id == id);
      final isLiked = existingIndex != -1;

      if (isLiked) {
        // unlike
        final favModel = currentFavourites[existingIndex];
        if (favModel.imagePath != null) {
          final file = File(favModel.imagePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        await _favouriteUseCase.removeFavourite(id);

        final updatedList = List<FavouriteModel>.from(currentFavourites)
          ..removeAt(existingIndex);

        emit(
          FavouriteLoaded(
            favourites: updatedList,
            snackMessage: "Wall removed from liked.",
            isErrorSnack: false,
          ),
        );
      } else {
        // like
        final url =
            event.wall?.urls?.full ??
            event.wall?.urls?.regular ??
            event.favWall?.urls?.full ??
            event.favWall?.urls?.regular;
        if (url == null) {
          emit(
            FavouriteLoaded(
              favourites: currentFavourites,
              snackMessage: "Could not save image, please try again",
              isErrorSnack: true,
            ),
          );
          return;
        }

        final bytes = await AppHelpers.urlToBytes(url);
        final dirPath = _favouriteUseCase.getLikedFolderPath();
        final file = File(
          '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(bytes);

        final fav = FavouriteModel(
          id: id,
          imagePath: file.path,
          urls: event.wall?.urls ?? event.favWall?.urls,
          user: event.wall?.user ?? event.favWall?.user,
        );
        await _favouriteUseCase.addFavourite(fav);

        final updatedList = [...currentFavourites, fav];

        emit(
          FavouriteLoaded(
            favourites: updatedList,
            snackMessage: "Wall added to liked.",
            isErrorSnack: false,
          ),
        );
      }
    } catch (e, st) {
      log("Error toggling favorite", error: e, stackTrace: st);
      emit(
        FavouriteLoaded(
          favourites: currentFavourites,
          snackMessage: "Something went wrong, please try again",
          isErrorSnack: true,
        ),
      );
    }
  }
}
