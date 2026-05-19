part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

final class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

final class HomeLoading extends HomeState {
  @override
  List<Object> get props => [];
}

final class HomeLoaded extends HomeState {
  final List<Wallpaper> walls;
  final int page;
  const HomeLoaded(this.walls, {this.page = 1});
  @override
  List<Object> get props => [walls, page];
}

final class HomeError extends HomeState {
  final String message;
  final int? statusCode;
  const HomeError(this.message, this.statusCode);

  @override
  List<Object?> get props => [message, statusCode];
}

final class HomeLoadingNext extends HomeState{
  final List<Wallpaper> walls;
  const HomeLoadingNext(this.walls);
  @override
  List<Object> get props => [walls];
}

final class HomeErrorLoadingNext extends HomeState{
  final List<Wallpaper> oldWalls;
  final String message;
  final int? statusCode;
  const HomeErrorLoadingNext(this.oldWalls, this.message, this.statusCode);
  @override
  List<Object?> get props => [oldWalls, message, statusCode];
}


// action states
// todo : seen it all state (when no more pages left)
// todo : rate limit (403 error code)
// todo: wallpaper set successfully
