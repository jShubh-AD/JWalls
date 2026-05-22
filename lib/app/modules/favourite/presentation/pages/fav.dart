import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:walpy/app/modules/favourite/presentation/bloc/favourite_bloc.dart';

import '../../../../core/Widgets/wall.dart';
import '../../../../core/utils/const/app_const.dart';
import '../../../view_image/presentation/pages/view_image.dart';
import '../../data/local_datasource.dart';

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
        if(state.isLoading){
          return Center(
            child: CircularProgressIndicator(
              color: darkMode ? Colors.white : Colors.black,
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppConst.yAxisSpacing,
                crossAxisSpacing: AppConst.xAxisSpacing,
                childCount: state.favourites.length,
                itemBuilder: (context, index) {
                  final walls = state.favourites;
                  if(walls.isEmpty){
                    return Text("No walls found");
                  }
                  return Wall(index, favouriteWall: walls[index]);
                },
              ),
            ),
          ],
        );
        // return Stack(
        //   children: [
        //
        //     Positioned(
        //       bottom: 10,
        //       right: 10,
        //       child: InkWell(
        //         child: Icon(Icons.favorite, color: Colors.red, size: 26),
        //       ),
        //     ),
        //   ],
        // );
      },
    );
  }
}
