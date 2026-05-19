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
  final bool isLoadingNext;
  const HomeLoaded(this.walls, {this.page = 1, this.isLoadingNext = false});
  @override
  List<Object> get props => [walls, page, isLoadingNext];
}

final class HomeError extends HomeState {
  final String message;
  final int? statusCode;
  const HomeError(this.message, this.statusCode);

  @override
  List<Object?> get props => [message, statusCode];
}


// action states
// todo : seen it all state (when no more pages left)
// todo : rate limit (403 error code)
// todo: wallpaper set successfully
