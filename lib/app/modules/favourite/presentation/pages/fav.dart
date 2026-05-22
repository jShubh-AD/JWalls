import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:walpy/app/modules/favourite/presentation/bloc/favourite_bloc.dart';

import '../../../../core/Widgets/wall.dart';
import '../../../../core/utils/const/app_const.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  Widget build(BuildContext context) {
    final darkMode = AppConst.isDarkMode(context);
    return BlocBuilder<FavouriteBloc, FavouriteState>(
      builder: (context, state) {
        if (state is FavouriteLoading || state is FavouriteInitial) {
          return Center(
            child: CircularProgressIndicator(
              color: darkMode ? Colors.white : Colors.black,
            ),
          );
        }

        if (state is FavouriteFailure) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(
                color: darkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          );
        }

        if (state is FavouriteLoaded) {
          final walls = state.favourites;
          if (walls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: darkMode ? Colors.white38 : Colors.black38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No liked wallpapers yet.",
                    style: TextStyle(
                      fontSize: 16,
                      color: darkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppConst.yAxisSpacing,
                  crossAxisSpacing: AppConst.xAxisSpacing,
                  childCount: walls.length,
                  itemBuilder: (context, index) {
                    return Wall(index, favouriteWall: walls[index]);
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
