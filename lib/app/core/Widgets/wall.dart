import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:walpy/app/core/app_routes/app_routes.dart';
import 'package:walpy/app/modules/favourite/data/favourite_model.dart';
import 'package:walpy/app/modules/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/view_image/presentation/pages/view_image_args.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/const/app_const.dart';

class Wall extends StatelessWidget {
  final int index;
  final Wallpaper? wallInfo;
  final FavouriteModel? favouriteWall;

  const Wall(this.index, {super.key, this.wallInfo, this.favouriteWall});

  @override
  Widget build(BuildContext context) {
    final id = wallInfo?.id ?? favouriteWall?.id;
    return Container(
      width: double.infinity,
      height: index.isEven ? 180 : 250,
      child: ClipRRect(
        borderRadius: AppConst.borderRadius10,
        child: BlocBuilder<FavouriteBloc, FavouriteState>(
          builder: (context, state) {
            final isLiked = state is FavouriteLoaded
                ? state.favourites.any((f) => f.id == id)
                : (favouriteWall != null);

            final isToggling =
                state is FavouriteLoaded && state.togglingFavIds.contains(id);

            // Resolve local path if liked
            String? localPath = favouriteWall?.imagePath;
            if (state is FavouriteLoaded && id != null) {
              final match = state.favourites.where((f) => f.id == id);
              if (match.isNotEmpty) {
                localPath = match.first.imagePath;
              }
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.view_image,
                      extra: ViewImageArgs(
                        wallInfo: wallInfo,
                        favouriteWall: favouriteWall,
                      ),
                    );
                  },
                  child: localPath != null
                      ? Image.file(
                          File(localPath),
                          fit: BoxFit.cover,
                          cacheWidth: 350,
                          errorBuilder: (context, error, stackTrace) {
                            return CachedNetworkImage(
                              fadeInDuration: Duration.zero,
                              imageUrl:
                                  wallInfo?.urls?.small ??
                                  favouriteWall?.urls?.small ??
                                  "",
                              fit: BoxFit.cover,
                              memCacheWidth: 350,
                              placeholder: (context, url) {
                                return Container(color: Colors.grey.shade100);
                              },
                            );
                          },
                        )
                      : CachedNetworkImage(
                          fadeInDuration: Duration.zero,
                          imageUrl:
                              wallInfo?.urls?.small ??
                              favouriteWall?.urls?.small ??
                              "",
                          fit: BoxFit.cover,
                          memCacheWidth: 350,
                          placeholder: (context, url) {
                            return Container(color: Colors.grey.shade100);
                          },
                        ),
                ),
                if (id != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        if (isToggling) return;
                        context.read<FavouriteBloc>().add(
                          ToggleLike(wall: wallInfo, favWall: favouriteWall),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: isToggling
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? Colors.redAccent
                                    : Colors.white,
                                size: 18,
                              ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
