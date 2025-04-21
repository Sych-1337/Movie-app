import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import 'movie_provider.dart';

class PaginatedMoviesNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final MovieService _service;
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  PaginatedMoviesNotifier(this._service) : super(const AsyncValue.data([])) {
    fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore || _isLoading) return;
    _isLoading = true;
    try {
      final newMovies = await _service.fetchTopRated(page: _page);
      if (newMovies.isEmpty) {
        _hasMore = false;
      } else {
        final current = state.value ?? [];
        state = AsyncValue.data([...current, ...newMovies]);
        _page++;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isLoading = false;
    }
  }

  bool get hasMore => _hasMore;
}

final paginatedMoviesProvider = StateNotifierProvider<
    PaginatedMoviesNotifier, AsyncValue<List<Movie>>>(
  (ref) => PaginatedMoviesNotifier(ref.watch(movieServiceProvider)),
);
