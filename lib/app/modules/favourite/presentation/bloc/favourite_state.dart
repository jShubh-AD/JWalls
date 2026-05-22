part of 'favourite_bloc.dart';

sealed class FavouriteState extends Equatable {
  const FavouriteState();

  @override
  List<Object?> get props => [];
}

class FavouriteInitial extends FavouriteState {
  const FavouriteInitial();
}

class FavouriteLoading extends FavouriteState {
  const FavouriteLoading();
}

class FavouriteLoaded extends FavouriteState {
  final List<FavouriteModel> favourites;
  final Set<String> togglingFavIds;
  final String? snackMessage;
  final bool? isErrorSnack;

  const FavouriteLoaded({
    required this.favourites,
    this.togglingFavIds = const {},
    this.snackMessage,
    this.isErrorSnack,
  });

  FavouriteLoaded copyWith({
    List<FavouriteModel>? favourites,
    Set<String>? togglingFavIds,
    String? snackMessage,
    bool clearSnack = false,
    bool? isErrorSnack,
  }) {
    return FavouriteLoaded(
      favourites: favourites ?? this.favourites,
      togglingFavIds: togglingFavIds ?? this.togglingFavIds,
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
      isErrorSnack: clearSnack ? null : (isErrorSnack ?? this.isErrorSnack),
    );
  }

  @override
  List<Object?> get props => [favourites, togglingFavIds, snackMessage, isErrorSnack];
}

class FavouriteFailure extends FavouriteState {
  final String message;
  const FavouriteFailure(this.message);

  @override
  List<Object?> get props => [message];
}