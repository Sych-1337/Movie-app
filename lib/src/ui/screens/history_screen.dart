import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie.dart';
import '../../providers/history_provider.dart';
import '../../providers/favorite_provider.dart';
import '../widgets/movie_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyMoviesProvider);
    final historyIds = ref.watch(historyIdsProvider);
    final historyNotifier = ref.read(historyIdsProvider.notifier);
    final favNotifier = ref.read(favoriteIdsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear History',
            onPressed: () => historyNotifier.clear(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Нет просмотров'));
          }
          return Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.65,
              ),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final m = list[i];
                final isFav = ref.read(favoriteIdsProvider).contains(m.id);
                return MovieTile(
                  movie: m,
                  isFavorite: isFav,
                  onTap: () => context.goNamed(
                    'details',
                    pathParameters: {'id': m.id.toString()},
                  ),
                  onFavoriteToggle: () =>
                      favNotifier.toggleFavorite(m.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
