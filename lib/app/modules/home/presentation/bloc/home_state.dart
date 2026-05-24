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
  final bool hasPaginationError;
  final String? errorNotification;

  const HomeLoaded(
    this.walls, {
    this.page = 1,
    this.isLoadingNext = false,
    this.hasPaginationError = false,
    this.errorNotification,
  });

  HomeLoaded copyWith({
    List<Wallpaper>? walls,
    int? page,
    bool? isLoadingNext,
    String? errorNotification,
    bool? hasPaginationError,
    bool clearErrorNotification = false,
  }) {
    return HomeLoaded(
      walls ?? this.walls,
      page: page ?? this.page,
      isLoadingNext: isLoadingNext ?? this.isLoadingNext,
      errorNotification: clearErrorNotification ? null : (errorNotification ?? this.errorNotification),
      hasPaginationError: hasPaginationError ?? this.hasPaginationError,
    );
  }

  @override
  List<Object?> get props => [
        walls,
        page,
        isLoadingNext,
        hasPaginationError,
        errorNotification,
      ];
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
