import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

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
    final id = event.wall?.id ?? event.favWall?.id;
    if (id == null) return;

    final currentState = state;
    final List<FavouriteModel> initialFavourites =
        currentState is FavouriteLoaded ? currentState.favourites : [];
    final Set<String> initialToggling =
        currentState is FavouriteLoaded ? currentState.togglingFavIds : const {};

    final updatedToggling = Set<String>.from(initialToggling)..add(id);

    emit(FavouriteLoaded(
      favourites: initialFavourites,
      togglingFavIds: updatedToggling,
    ));

    final existingIndex = initialFavourites.indexWhere((f) => f.id == id);
    final isLiked = existingIndex != -1;

    try {
      if (isLiked) {
        // unlike
        final favModel = initialFavourites[existingIndex];
        if (favModel.imagePath != null) {
          final file = File(favModel.imagePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        await _favouriteUseCase.removeFavourite(id);

        final latestState = state;
        final latestFavourites =
            latestState is FavouriteLoaded ? latestState.favourites : initialFavourites;
        final latestToggling =
            latestState is FavouriteLoaded ? latestState.togglingFavIds : updatedToggling;

        final updatedList = latestFavourites.where((f) => f.id != id).toList();
        final finalToggling = Set<String>.from(latestToggling)..remove(id);

        emit(
          FavouriteLoaded(
            favourites: updatedList,
            togglingFavIds: finalToggling,
            snackMessage: "Wall removed from liked.",
            isErrorSnack: false,
          ),
        );
      } else {
        // like
        final originalUrl =
            event.wall?.urls?.full ??
            event.wall?.urls?.regular ??
            event.favWall?.urls?.full ??
            event.favWall?.urls?.regular;
        if (originalUrl == null) {
          final latestState = state;
          final latestFavourites =
              latestState is FavouriteLoaded ? latestState.favourites : initialFavourites;
          final latestToggling =
              latestState is FavouriteLoaded ? latestState.togglingFavIds : updatedToggling;

          final finalToggling = Set<String>.from(latestToggling)..remove(id);
          emit(
            FavouriteLoaded(
              favourites: latestFavourites,
              togglingFavIds: finalToggling,
              snackMessage: "Could not save image, please try again",
              isErrorSnack: true,
            ),
          );
          return;
        }

        final url = AppHelpers.optimizeUnsplashUrl(originalUrl);

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

        final latestState = state;
        final latestFavourites =
            latestState is FavouriteLoaded ? latestState.favourites : initialFavourites;
        final latestToggling =
            latestState is FavouriteLoaded ? latestState.togglingFavIds : updatedToggling;

        final updatedList = latestFavourites.any((f) => f.id == id)
            ? latestFavourites
            : [...latestFavourites, fav];
        final finalToggling = Set<String>.from(latestToggling)..remove(id);

        emit(
          FavouriteLoaded(
            favourites: updatedList,
            togglingFavIds: finalToggling,
            snackMessage: "Wall added to liked.",
            isErrorSnack: false,
          ),
        );
      }
    } catch (e, st) {
      log("Error toggling favorite", error: e, stackTrace: st);
      final latestState = state;
      final latestFavourites =
          latestState is FavouriteLoaded ? latestState.favourites : initialFavourites;
      final latestToggling =
          latestState is FavouriteLoaded ? latestState.togglingFavIds : updatedToggling;

      final finalToggling = Set<String>.from(latestToggling)..remove(id);
      emit(
        FavouriteLoaded(
          favourites: latestFavourites,
          togglingFavIds: finalToggling,
          snackMessage: "Something went wrong, please try again",
          isErrorSnack: true,
        ),
      );
    }
  }
}
