import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_details.dart';
import 'movie_provider.dart';

final favoriteIdsProvider =
    StateNotifierProvider<FavoriteNotifier, Set<int>>(
  (ref) => FavoriteNotifier(),
);

class FavoriteNotifier extends StateNotifier<Set<int>> {
  static const _prefsKey = 'favorites';

  FavoriteNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    state = list.map(int.parse).toSet();
  }

  Future<void> toggleFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final newSet = Set<int>.from(state);
    if (state.contains(movieId)) {
      newSet.remove(movieId);
    } else {
      newSet.add(movieId);
    }
    state = newSet;
    await prefs.setStringList(
      _prefsKey,
      newSet.map((e) => e.toString()).toList(),
    );
  }

  bool isFavorite(int movieId) => state.contains(movieId);
}

final favoriteMoviesProvider =
    FutureProvider<List<MovieDetails>>((ref) async {
  final ids = ref.watch(favoriteIdsProvider);
  final service = ref.watch(movieServiceProvider);
  final futures = ids.map((id) => service.fetchMovieDetails(id));
  return await Future.wait(futures);
});
