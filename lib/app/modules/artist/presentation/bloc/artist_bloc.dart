import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:walpy/app/core/network/result.dart';
import 'package:walpy/app/core/network/api_const.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/artist/domain/artist_usecase.dart';

part 'artist_event.dart';
part 'artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final ArtistUseCase _useCase;
  String _username = '';

  ArtistBloc(this._useCase) : super(ArtistInitial()) {
    on<FetchArtistPhotos>(_onFetchArtistPhotos);
    on<FetchNextArtistPhotosPage>(_onFetchNextArtistPhotosPage);
  }

  Future<void> _onFetchArtistPhotos(
    FetchArtistPhotos event,
    Emitter<ArtistState> emit,
  ) async {
    _username = event.username;
    emit(ArtistLoading());

    final Result<List<Wallpaper>, Failure> result = await _useCase.getArtistPhotos(
      username: _username,
      params: {
        "per_page": ApiConst.per_page,
        "page": 1,
      },
    );

    result.fold(
      onSuccess: (List<Wallpaper> photos) => emit(ArtistLoaded(
        photos: photos,
        page: 1,
        hasReachedMax: photos.length < ApiConst.per_page,
      )),
      onFailure: (Failure failure) => emit(ArtistError(failure.message)),
    );
  }

  Future<void> _onFetchNextArtistPhotosPage(
    FetchNextArtistPhotosPage event,
    Emitter<ArtistState> emit,
  ) async {
    if (state is! ArtistLoaded) return;
    final currentState = (state as ArtistLoaded);
    if (currentState.isLoadingNext || currentState.hasReachedMax) return;

    final currentList = currentState.photos;
    final nextPage = currentState.page + 1;

    emit(currentState.copyWith(
      isLoadingNext: true,
      hasPaginationError: false,
    ));

    final Result<List<Wallpaper>, Failure> result = await _useCase.getArtistPhotos(
      username: _username,
      params: {
        "per_page": ApiConst.per_page,
        "page": nextPage,
      },
    );


    result.fold(
      onSuccess: (List<Wallpaper> photos) => emit(
        currentState.copyWith(
          photos: [...currentList, ...photos],
          page: nextPage,
          isLoadingNext: false,
          hasReachedMax: photos.length < ApiConst.per_page,
          hasPaginationError: false,
        ),
      ),
      onFailure: (Failure failure) {
        emit(currentState.copyWith(
          isLoadingNext: false,
          hasPaginationError: true,
          errorNotification: failure.message,
        ));
        emit((state as ArtistLoaded).copyWith(clearErrorNotification: true));
      },
    );
  }
}
