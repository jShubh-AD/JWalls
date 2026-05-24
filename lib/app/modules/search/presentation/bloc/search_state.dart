part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {
  final List<String> history;

  const SearchInitial(this.history);

  @override
  List<Object?> get props => [history];
}

final class SearchLoading extends SearchState {
  final List<String> history;

  const SearchLoading(this.history);

  @override
  List<Object?> get props => [history];
}

final class SearchLoaded extends SearchState {
  final List<Wallpaper> walls;
  final String query;
  final int page;
  final bool isLoadingNext;
  final List<String> history;
  final String? errorNotification;

  const SearchLoaded({
    required this.walls,
    required this.query,
    this.page = 1,
    this.isLoadingNext = false,
    required this.history,
    this.errorNotification,
  });

  SearchLoaded copyWith({
    List<Wallpaper>? walls,
    String? query,
    int? page,
    bool? isLoadingNext,
    List<String>? history,
    String? errorNotification,
    bool clearErrorNotification = false,
  }) {
    return SearchLoaded(
      walls: walls ?? this.walls,
      query: query ?? this.query,
      page: page ?? this.page,
      isLoadingNext: isLoadingNext ?? this.isLoadingNext,
      history: history ?? this.history,
      errorNotification: clearErrorNotification ? null : (errorNotification ?? this.errorNotification),
    );
  }

  @override
  List<Object?> get props => [walls, query, page, isLoadingNext, history, errorNotification];
}

final class SearchError extends SearchState {
  final String message;
  final int? statusCode;

  const SearchError(this.message, this.statusCode);

  @override
  List<Object?> get props => [message, statusCode];
}
