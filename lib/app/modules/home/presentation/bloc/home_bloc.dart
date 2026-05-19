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
  }

  Future<void> fetchHome(HomeFetch event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final walls = await _useCase.getWallpapers(
        params: {"per_page": ApiConst.per_page, "page": 1},
        url: ApiConst.baseUrl,
      );
      emit(HomeLoaded(walls));
    } catch (e) {
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
    final currentList = (state as HomeLoaded).walls;
    final nextPage = (state as HomeLoaded).page + 1;
    try {
      emit(HomeLoadingNext(currentList));
      final walls = await _useCase.getWallpapers(
        params: {"per_page": ApiConst.per_page, "page": nextPage},
        url: ApiConst.baseUrl,
      );
      emit(HomeLoaded([...currentList, ...walls], page: nextPage));
    } catch (e) {
      if (e is AppException) {
        emit(HomeErrorLoadingNext(currentList, e.message, e.statusCode));
      } else {
        emit(HomeErrorLoadingNext(currentList, e.toString(), null));
      }
    }
  }
}
