import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
            slivers: [
              // todo: add sliverAppBar with horizontal scroll for categories
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppConst.yAxisSpacing,
                  crossAxisSpacing: AppConst.xAxisSpacing,
                  childCount: walls.length + 1,
                  itemBuilder: (context, index) {
                    if(index >= walls.length){
                      return Container(
                        width: double.infinity,
                        height: index.isEven ? 180 : 250,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }
                    return Wall(index, wallInfo: walls[index]);
                  },
                ),
              ),
            ],
          );
        }

        if (state is HomeError) {
          final String error = state.message;
          return Center(child: Text(error));
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
      if (state is HomeLoaded && !state.isLoadingNext) {
        context.read<HomeBloc>().add(FetchNextPage());
      }
    }
  }

  Future urltoUnit8(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final bytes = await file.readAsBytes();
    return bytes;
  }
}
