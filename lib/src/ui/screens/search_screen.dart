import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie.dart';
import '../../providers/search_provider.dart';
import '../../providers/favorite_provider.dart';
import '../widgets/movie_tile.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({Key? key}) : super(key: key);

  static const _hint = 'Search movies...';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchNotifier = ref.read(searchProvider.notifier);
    final searchAsync = ref.watch(searchProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider);
    final favNotifier = ref.read(favoriteIdsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: _hint,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: searchNotifier.setQuery,
            ),
          ),
          Expanded(
            child: searchAsync.when(
              data: (movies) {
                if (movies.isEmpty) {
                  return const Center(child: Text('Введите минимум 3 символа'));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
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
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Ошибка при поиске: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
