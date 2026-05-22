import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:walpy/app/UI/portfolio.dart';
import 'package:walpy/app/UI/search.dart';
import 'package:walpy/app/UI/settings.dart';
import 'package:walpy/app/modules/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/view_image/presentation/pages/view_image.dart';
import 'package:walpy/app/core/app_routes/app_routes.dart';
import 'package:walpy/app/modules/home/presentation/view/dashboard.dart';
import 'package:walpy/app/modules/home/presentation/view/home.dart';
import 'package:walpy/app/modules/splash.dart';
import '../../modules/favourite/presentation/pages/fav.dart';
import '../../modules/view_image/bloc/view_image_bloc.dart';
import '../../modules/view_image/presentation/pages/view_image_args.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: AppRoutes.initial,
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      name: AppRoutes.dashboard,
      path: '/dashboard',
      builder: (context, state) => Dashboard(),
    ),
    GoRoute(
      name: AppRoutes.home,
      path: '/home',
      builder: (context, state) => Homepage(),
    ),
    GoRoute(
      name: AppRoutes.search,
      path: '/search',
      builder: (context, state) => SearchPage(),
    ),
    GoRoute(
      name: AppRoutes.fav,
      path: '/favourite',
      builder: (context, state) => FavouritePage(),
    ),
    GoRoute(
      name: AppRoutes.settings,
      path: '/settings',
      builder: (context, state) => Settings(),
    ),
    GoRoute(
      name: AppRoutes.view_image,
      path: '/view_image',
      builder: (context, state) {
        final args = state.extra as ViewImageArgs;
        return BlocProvider(
          create: (_) => ViewImageBloc(),
          child: ViewImage(wallInfo: args.wallInfo, favouriteWall: args.favouriteWall),
        );
      },
    ),
    GoRoute(
      name: AppRoutes.portfolio,
      path: '/portfolio',
      builder: (context, state){
        final args = state.extra as User;
        return Portfolio(user: args);
      },
    ),
  ],
);
