import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/movie_details.dart';
import '../../providers/movie_provider.dart';
import '../../providers/favorite_provider.dart';

final randomMovieProvider = FutureProvider<MovieDetails>((ref) async {
  final service = ref.watch(movieServiceProvider);
  final list = await service.fetchTopRated(page: 1);
  if (list.isEmpty) throw Exception('No movies available');
  final randomMovie = list[Random().nextInt(list.length)];
  return service.fetchMovieDetails(randomMovie.id);
});

class RandomScreen extends ConsumerWidget {
  const RandomScreen({Key? key}) : super(key: key);

  static const _imageBase = 'https://image.tmdb.org/t/p/w500';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(randomMovieProvider);
    final favorites = ref.watch(favoriteIdsProvider);
    final favNotifier = ref.read(favoriteIdsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Movie'),
      ),
      body: movieAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (MovieDetails movie) {
          final isFav = favorites.contains(movie.id);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (movie.posterPath != null)
                  Image.network(
                    '$_imageBase${movie.posterPath}',
                    fit: BoxFit.cover,
                    height: 400,
                  )
                else
                  Container(
                    height: 400,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.movie, size: 100, color: Colors.grey),
                    ),
                  ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(movie.voteAverage.toString()),
                          const Spacer(),
                          Text(
                            'Release: ${movie.releaseDate}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        movie.overview,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              ref.refresh(randomMovieProvider);
                            },
                            child: const Text('Try Again'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              favNotifier.toggleFavorite(movie.id);
                            },
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.redAccent : null,
                            ),
                            label: Text(
                              isFav ? 'Remove Favorite' : 'Add to Favorite',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
