import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:walpy/app/core/Widgets/error_retry_widget.dart';
import 'package:walpy/app/core/Widgets/wall.dart';
import 'package:walpy/app/core/utils/const/app_const.dart';
import 'package:walpy/app/modules/home/presentation/bloc/home_bloc.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = AppConst.isDarkMode(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: darkMode ? Colors.white : Colors.black,
            ),
          );
        }

        if (state is HomeLoaded) {
          final walls = state.walls;
          return CustomScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                stretch: true,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: 0,
                onStretchTrigger: () async {
                  context.read<HomeBloc>().add(HomeFetch());
                },
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppConst.yAxisSpacing,
                  crossAxisSpacing: AppConst.xAxisSpacing,
                  childCount:
                      state.walls.length +
                      (state.isLoadingNext || state.hasPaginationError ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= walls.length) {
                      if (state.isLoadingNext) {
                        return Container(
                          width: double.infinity,
                          height: index.isEven ? 180 : 250,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      } else if (state.hasPaginationError) {
                        return ErrorRetryWidget(
                          isMini: true,
                          errorMessage: state.errorNotification ?? "Connection issue",
                          onRetry: () =>
                              context.read<HomeBloc>().add(FetchNextPage()),
                        );
                      }
                    }
                    return Wall(index, wallInfo: walls[index]);
                  },
                ),
              ),
            ],
          );
        }

        if (state is HomeError) {
          return ErrorRetryWidget(
            isMini: false,
            errorMessage: state.message,
            onRetry: () => context.read<HomeBloc>().add(HomeFetch()),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final isBottom = position.atEdge && position.pixels != 0;
    if (isBottom) {
      final state = context.read<HomeBloc>().state;
      if (state is HomeLoaded &&
          !state.isLoadingNext &&
          !state.hasPaginationError) {
        context.read<HomeBloc>().add(FetchNextPage());
      }
    }
  }
}
