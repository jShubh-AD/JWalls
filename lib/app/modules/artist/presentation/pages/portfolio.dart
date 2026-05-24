import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:walpy/app/core/Widgets/app_snackbar.dart';
import 'package:walpy/app/core/Widgets/error_retry_widget.dart';
import 'package:walpy/app/core/Widgets/wall.dart';
import 'package:walpy/app/core/utils/const/app_const.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/artist/presentation/bloc/artist_bloc.dart';

class Portfolio extends StatefulWidget {
  const Portfolio({super.key, required this.user});

  final User user;

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
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

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          AppSnackBar.show(
            context,
            title: "Error",
            message: 'Could not launch profile',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          title: "Error",
          message: 'Could not launch profile',
          isError: true,
        );
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final isBottom = position.atEdge && position.pixels != 0;
    if (isBottom) {
      final state = context.read<ArtistBloc>().state;
      if (state is ArtistLoaded &&
          !state.isLoadingNext &&
          !state.hasReachedMax &&
          !state.hasPaginationError) {
        context.read<ArtistBloc>().add(FetchNextArtistPhotosPage());
      }
    }
  }

  Widget _buildProfileHeader(BuildContext context, bool darkMode) {
    final user = widget.user;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(darkMode ? 0.4 : 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: darkMode
                  ? Colors.grey.shade900
                  : Colors.grey.shade200,
              backgroundImage: user.profileImage?.large != null
                  ? CachedNetworkImageProvider(user.profileImage!.large!)
                  : null,
              child: user.profileImage?.large == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: darkMode ? Colors.white54 : Colors.black54,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'Unknown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: darkMode ? Colors.white : Colors.black87,
                  ),
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _launchUrl(user.link),
                  child: Text(
                    '@${user.username}',
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ),

                // Location
                if (user.location != null && user.location!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.location!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: darkMode ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],

                // Bio
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.bio!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                      color: darkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool darkMode) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: darkMode ? Colors.white38 : Colors.black38,
            ),
            const SizedBox(height: 16),
            Text(
              'No photos available',
              style: TextStyle(
                fontSize: 16,
                color: darkMode ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = AppConst.isDarkMode(context);

    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: darkMode ? Colors.black : Colors.white,
            surfaceTintColor: Colors.transparent,
            floating: true,
            pinned: true,
            expandedHeight: 200,
            stretch: true,
            onStretchTrigger: () async {
              context.read<ArtistBloc>().add(FetchArtistPhotos(widget.user.username ?? ''));
            },
            automaticallyImplyLeading: false,
            leading: Center(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                color: Colors.transparent,
                borderRadius: AppConst.borderRadius18,
                onPressed: () => context.pop(),
                child: Icon(
                  CupertinoIcons.back,
                  size: 24,
                  color: darkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            title: Text(
              "Vibe Creator!",
              style: TextStyle(
                fontSize: 18,
                color: darkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [_buildProfileHeader(context, darkMode)],
              ),
            ),
          ),
          BlocBuilder<ArtistBloc, ArtistState>(
            builder: (context, state) {
              if (state is ArtistLoading) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }

              if (state is ArtistError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: ErrorRetryWidget(
                      isMini: false,
                      errorMessage: state.message,
                      onRetry: () {
                        context.read<ArtistBloc>().add(
                          FetchArtistPhotos(widget.user.username ?? ''),
                        );
                      },
                    ),
                  ),
                );
              }

              if (state is ArtistLoaded) {
                final photos = state.photos;
                if (photos.isEmpty) {
                  return _buildEmptyState(darkMode);
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppConst.yAxisSpacing,
                    crossAxisSpacing: AppConst.xAxisSpacing,
                    childCount:
                        photos.length +
                        (state.isLoadingNext || state.hasPaginationError
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index >= photos.length) {
                        if (state.isLoadingNext) {
                          return SizedBox(
                            height: 120,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: darkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          );
                        } else if (state.hasPaginationError) {
                          return ErrorRetryWidget(
                            isMini: true,
                            errorMessage:
                                state.errorNotification ?? 'Connection error',
                            onRetry: () {
                              context.read<ArtistBloc>().add(
                                FetchNextArtistPhotosPage(),
                              );
                            },
                          );
                        }
                      }
                      return Wall(index, wallInfo: photos[index]);
                    },
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }
}
