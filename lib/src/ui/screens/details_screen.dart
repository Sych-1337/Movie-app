import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie_details.dart';
import '../../providers/movie_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/history_provider.dart';

class DetailsScreen extends ConsumerWidget {
  final int movieId;
  const DetailsScreen({Key? key, required this.movieId}) : super(key: key);

  static const _imageBase = 'https://image.tmdb.org/t/p/w500';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<MovieDetails>>(
      movieDetailsProvider(movieId),
      (_, next) => next.whenData((movie) {
        ref.read(historyIdsProvider.notifier).add(movie.id);
      }),
    );

    final detailsAsync = ref.watch(movieDetailsProvider(movieId));
    final favoriteIds = ref.watch(favoriteIdsProvider);
    final favNotifier = ref.read(favoriteIdsProvider.notifier);
    final isFav = favoriteIds.contains(movieId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            color: isFav ? Colors.redAccent : Colors.white,
            onPressed: () => favNotifier.toggleFavorite(movieId),
          ),
        ],
      ),
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (movie) {
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
