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
  final String? togglingFavId;
  final String? snackMessage;
  final bool? isErrorSnack;

  const FavouriteLoaded({
    required this.favourites,
    this.togglingFavId,
    this.snackMessage,
    this.isErrorSnack,
  });

  FavouriteLoaded copyWith({
    List<FavouriteModel>? favourites,
    String? togglingFavId,
    bool clearToggling = false,
    String? snackMessage,
    bool clearSnack = false,
    bool? isErrorSnack,
  }) {
    return FavouriteLoaded(
      favourites: favourites ?? this.favourites,
      togglingFavId: clearToggling ? null : (togglingFavId ?? this.togglingFavId),
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
      isErrorSnack: clearSnack ? null : (isErrorSnack ?? this.isErrorSnack),
    );
  }

  @override
  List<Object?> get props => [favourites, togglingFavId, snackMessage, isErrorSnack];
}

class FavouriteFailure extends FavouriteState {
  final String message;
  const FavouriteFailure(this.message);

  @override
  List<Object?> get props => [message];
}