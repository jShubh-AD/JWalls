part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class HomeFetch extends HomeEvent{
  final int pageNum;
  const HomeFetch({this.pageNum = 1});

  @override
  List<Object> get props => [pageNum];
}

class FetchNextPage extends HomeEvent{}