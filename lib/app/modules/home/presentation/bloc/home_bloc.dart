import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:walpy/app/core/app_errors/app_errors.dart';
import 'package:walpy/app/core/network/api_const.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/home/domain/home_usecase.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeUseCase _useCase;

  HomeBloc(this._useCase) : super(HomeInitial()) {
    on<HomeFetch>(fetchHome);
    on<FetchNextPage>(fetchNextPage);

    add(HomeFetch());
  }

  Future<void> fetchHome(HomeFetch event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final walls = await _useCase.getWallpapers(
        params: {"per_page": ApiConst.per_page, "page": 1},
        url: ApiConst.baseUrl + ApiConst.fetchImages,
      );
      emit(HomeLoaded(walls, page: 1));
    } catch (e, st) {
      log(name: 'FetchHome', "", error: e, stackTrace: st);
      if (e is AppException) {
        emit(HomeError(e.message, e.statusCode));
      } else {
        emit(HomeError(e.toString(), null));
      }
    }
  }

  Future<void> fetchNextPage(
    FetchNextPage event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    final currentState = (state as HomeLoaded);
    if (currentState.isLoadingNext) return;

    final currentList = currentState.walls;
    final nextPage = currentState.page + 1;

    emit(HomeLoaded(currentList, page: currentState.page, isLoadingNext: true));

    try {
      final walls = await _useCase.getWallpapers(
        params: {"per_page": ApiConst.per_page, "page": nextPage},
        url: ApiConst.baseUrl + ApiConst.fetchImages,
      );
      emit(
        HomeLoaded(
          [...currentList, ...walls],
          page: nextPage,
          isLoadingNext: false,
        ),
      );
    } catch (e, st) {
      emit(
        HomeLoaded(currentList, page: currentState.page, isLoadingNext: false),
      );
      log(name: 'HomeLoadingNext', "", error: e, stackTrace: st);
      if (e is AppException) {
        emit(HomeError(e.message, e.statusCode));
      } else {
        emit(HomeError(e.toString(), null));
      }
    }
  }
}
