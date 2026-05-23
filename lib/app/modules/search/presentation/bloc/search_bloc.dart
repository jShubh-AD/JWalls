import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:walpy/app/core/app_errors/app_errors.dart';
import 'package:walpy/app/core/network/api_const.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/search/domain/search_usecase.dart';
import 'package:walpy/app/modules/favourite/data/local_datasource.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase _useCase;

  SearchBloc(this._useCase)
    : super(SearchInitial(LocalDatabase.instance.getSearchHistory())) {
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<FetchNextSearchPage>(_onFetchNextSearchPage);
    on<DeleteSearchHistoryItem>(_onDeleteSearchHistoryItem);
    on<ClearSearchHistory>(_onClearSearchHistory);
  }

  void _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) {
    final history = LocalDatabase.instance.getSearchHistory();
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(history: history));
    } else {
      emit(SearchInitial(history));
    }
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final history = LocalDatabase.instance.getSearchHistory();

    if (event.query.trim().isEmpty) {
      emit(SearchInitial(history));
      return;
    }

    emit(SearchLoading(history));

    try {
      await LocalDatabase.instance.addSearchHistory(event.query);
      final updatedHistory = LocalDatabase.instance.getSearchHistory();

      final walls = await _useCase.searchWallpapers(
        params: {
          "query": event.query,
          "per_page": ApiConst.per_page,
          "page": 1,
        },
        url: ApiConst.baseUrl + ApiConst.searchWall,
      );

      emit(
        SearchLoaded(
          walls: walls,
          query: event.query,
          page: 1,
          history: updatedHistory,
        ),
      );
    } catch (e, st) {
      log(name: 'SearchQueryChanged', "", error: e, stackTrace: st);
      if (e is AppException) {
        emit(SearchError(e.message, e.statusCode));
      } else {
        emit(SearchError(e.toString(), null));
      }
    }
  }

  Future<void> _onFetchNextSearchPage(
    FetchNextSearchPage event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchLoaded) return;
    final currentState = (state as SearchLoaded);
    if (currentState.isLoadingNext) return;

    final currentList = currentState.walls;
    final nextPage = currentState.page + 1;

    emit(currentState.copyWith(isLoadingNext: true));

    try {
      final walls = await _useCase.searchWallpapers(
        params: {
          "query": currentState.query,
          "per_page": ApiConst.per_page,
          "page": nextPage,
        },
        url: ApiConst.baseUrl + ApiConst.searchWall,
      );

      emit(
        currentState.copyWith(
          walls: [...currentList, ...walls],
          page: nextPage,
          isLoadingNext: false,
        ),
      );
    } catch (e, st) {
      emit(currentState.copyWith(isLoadingNext: false));
      log(name: 'SearchFetchNextPage', "", error: e, stackTrace: st);
    }
  }

  Future<void> _onDeleteSearchHistoryItem(
    DeleteSearchHistoryItem event,
    Emitter<SearchState> emit,
  ) async {
    await LocalDatabase.instance.removeSearchHistory(event.query);
    final history = LocalDatabase.instance.getSearchHistory();
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(history: history));
    } else if (state is SearchLoading) {
      emit(SearchLoading(history));
    } else {
      emit(SearchInitial(history));
    }
  }

  Future<void> _onClearSearchHistory(
    ClearSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    await LocalDatabase.instance.clearSearchHistory();
    final history = <String>[];
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(history: history));
    } else if (state is SearchLoading) {
      emit(SearchLoading(history));
    } else {
      emit(SearchInitial(history));
    }
  }
}
