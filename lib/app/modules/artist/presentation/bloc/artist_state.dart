part of 'artist_bloc.dart';

sealed class ArtistState extends Equatable {
  const ArtistState();

  @override
  List<Object?> get props => [];
}

final class ArtistInitial extends ArtistState {}

final class ArtistLoading extends ArtistState {}

final class ArtistLoaded extends ArtistState {
  final List<Wallpaper> photos;
  final int page;
  final bool isLoadingNext;
  final bool hasPaginationError;
  final String? errorNotification;
  final bool hasReachedMax;

  const ArtistLoaded({
    required this.photos,
    required this.page,
    this.isLoadingNext = false,
    this.hasPaginationError = false,
    this.errorNotification,
    required this.hasReachedMax,
  });

  ArtistLoaded copyWith({
    List<Wallpaper>? photos,
    int? page,
    bool? isLoadingNext,
    bool? hasPaginationError,
    String? errorNotification,
    bool? hasReachedMax,
    bool clearErrorNotification = false,
  }) {
    return ArtistLoaded(
      photos: photos ?? this.photos,
      page: page ?? this.page,
      isLoadingNext: isLoadingNext ?? this.isLoadingNext,
      hasPaginationError: hasPaginationError ?? this.hasPaginationError,
      errorNotification: clearErrorNotification ? null : (errorNotification ?? this.errorNotification),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        photos,
        page,
        isLoadingNext,
        hasPaginationError,
        errorNotification,
        hasReachedMax,
      ];
}

final class ArtistError extends ArtistState {
  final String message;
  const ArtistError(this.message);

  @override
  List<Object?> get props => [message];
}
