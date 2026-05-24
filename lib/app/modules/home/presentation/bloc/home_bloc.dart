import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:walpy/app/core/network/result.dart';
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
    final Result<List<Wallpaper>, Failure> result = await _useCase.getWallpapers(
      params: {"per_page": ApiConst.per_page, "page": 1},
      url: ApiConst.baseUrl + ApiConst.fetchImages,
    );

    result.fold(
      onSuccess: (List<Wallpaper> walls) => emit(HomeLoaded(walls, page: 1)),
      onFailure: (Failure failure) => emit(HomeError(failure.message, null)),
    );
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

    emit(currentState.copyWith(
      isLoadingNext: true,
      hasPaginationError: false,
    ));

    final Result<List<Wallpaper>, Failure> result = await _useCase.getWallpapers(
      params: {"per_page": ApiConst.per_page, "page": nextPage},
      url: ApiConst.baseUrl + ApiConst.fetchImages,
    );

    result.fold(
      onSuccess: (List<Wallpaper> walls) => emit(
        currentState.copyWith(
          walls: [...currentList, ...walls],
          page: nextPage,
          isLoadingNext: false,
          hasPaginationError: false,
        ),
      ),
      onFailure: (Failure failure) {
        emit(currentState.copyWith(
          isLoadingNext: false,
          hasPaginationError: true,
          errorNotification: failure.message,
        ));
        if (state is HomeLoaded) {
          emit((state as HomeLoaded).copyWith(clearErrorNotification: true));
        }
      },
    );
  }
}
