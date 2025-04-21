import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'ui/screens/home_screen.dart';
import 'ui/screens/random_screen.dart';
import 'ui/screens/history_screen.dart';
import 'ui/screens/favorites_screen.dart';
import 'ui/screens/search_screen.dart';
import 'ui/screens/details_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'random',
            name: 'random',
            builder: (_, __) => const RandomScreen(),
          ),
          GoRoute(
            path: 'history',
            name: 'history',
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: 'favorites',
            name: 'favorites',
            builder: (_, __) => const FavoritesScreen(),
          ),
          GoRoute(
            path: 'search',
            name: 'search',
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            path: 'details/:id',
            name: 'details',
            builder: (context, state) {
              final movieId = int.parse(state.pathParameters['id']!);
              return DetailsScreen(movieId: movieId);
            },
          ),
        ],
      ),
    ],
  );
});
