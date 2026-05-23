part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class LoadSearchHistory extends SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class FetchNextSearchPage extends SearchEvent {}

class DeleteSearchHistoryItem extends SearchEvent {
  final String query;

  const DeleteSearchHistoryItem(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchHistory extends SearchEvent {}
