import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie.dart';
import '../../models/movie_details.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/movie_provider.dart';
import '../widgets/movie_tile.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteMoviesProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider);
    final favNotifier = ref.read(favoriteIdsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (detailsList) {
          if (detailsList.isEmpty) {
            return const Center(child: Text('Нет избранного'));
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.65,
              ),
              itemCount: detailsList.length,
              itemBuilder: (context, i) {
                final MovieDetails d = detailsList[i];
                final isFav = favoriteIds.contains(d.id);

                final movie = Movie(
                  id: d.id,
                  title: d.title,
                  posterPath: d.posterPath,
                  voteAverage: d.voteAverage,
                );

                return MovieTile(
                  movie: movie,
                  isFavorite: isFav,
                  onTap: () => context.goNamed(
                    'details',
                    pathParameters: {'id': d.id.toString()},
                  ),
                  onFavoriteToggle: () => favNotifier.toggleFavorite(d.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
