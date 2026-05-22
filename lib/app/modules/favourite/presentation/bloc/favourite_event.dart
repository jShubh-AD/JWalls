part of 'favourite_bloc.dart';

sealed class FavouriteEvent extends Equatable {
  const FavouriteEvent();
  @override
  List<Object?> get props => [];
}

class LoadFavourites extends FavouriteEvent {}

class ResetLikeState extends FavouriteEvent {}

class CheckIsLiked extends FavouriteEvent {
  final String wallId;
  const CheckIsLiked(this.wallId);
  @override
  List<Object?> get props => [wallId];
}

class ToggleLike extends FavouriteEvent {
  final Wallpaper? wall;
  final FavouriteModel? favWall;
  const ToggleLike({this.wall, this.favWall});
  @override
  List<Object?> get props => [wall, favWall];
}