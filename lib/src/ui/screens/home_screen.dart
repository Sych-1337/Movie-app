import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie.dart';
import '../../providers/paginated_movies_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/movie_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(paginatedMoviesProvider);
    final paginator = ref.read(paginatedMoviesProvider.notifier);

    final favoriteIds = ref.watch(favoriteIdsProvider);
    final favNotifier = ref.read(favoriteIdsProvider.notifier);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final hasMore = paginator.hasMore;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Rated Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino),
            tooltip: 'Random Movie',
            onPressed: () => context.goNamed('random'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => context.goNamed('history'),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorites',
            onPressed: () => context.goNamed('favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => context.goNamed('search'),
          ),
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: themeNotifier.setTheme,
            itemBuilder: (_) => const [
              PopupMenuItem(value: ThemeMode.system, child: Text('System')),
              PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
              PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
          ),
        ],
      ),
      body: moviesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (movies) {
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200 &&
                  hasMore) {
                paginator.fetchNextPage();
              }
              return false;
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.65,
                ),
                itemCount: movies.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == movies.length && hasMore) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final movie = movies[index];
                  final isFav = favoriteIds.contains(movie.id);
                  return MovieTile(
                    movie: movie,
                    isFavorite: isFav,
                    onTap: () => context.goNamed(
                      'details',
                      pathParameters: {'id': movie.id.toString()},
                    ),
                    onFavoriteToggle: () {
                      favNotifier.toggleFavorite(movie.id);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
