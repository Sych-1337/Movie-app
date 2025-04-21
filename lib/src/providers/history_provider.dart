import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import 'movie_provider.dart';

final historyIdsProvider =
    StateNotifierProvider<HistoryNotifier, List<int>>(
  (ref) => HistoryNotifier(),
);

class HistoryNotifier extends StateNotifier<List<int>> {
  static const _prefsKey = 'history';

  HistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    state = list.map(int.parse).toList();
  }

  Future<void> add(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final newList = [id, ...state.where((e) => e != id)];
    state = newList;
    await prefs.setStringList(
      _prefsKey,
      newList.map((e) => e.toString()).toList(),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    state = [];
    await prefs.remove(_prefsKey);
  }
}
final historyMoviesProvider =
    FutureProvider<List<Movie>>((ref) async {
  final ids = ref.watch(historyIdsProvider);
  final service = ref.watch(movieServiceProvider);
  final list = <Movie>[];
  for (final id in ids) {
    final d = await service.fetchMovieDetails(id);
    list.add(Movie(
      id: d.id,
      title: d.title,
      posterPath: d.posterPath,
      voteAverage: d.voteAverage,
    ));
  }
  return list;
});
