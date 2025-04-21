import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import 'movie_provider.dart'; 

class SearchNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final MovieService _service;
  Timer? _debounce;

  SearchNotifier(this._service) : super(const AsyncValue.data([]));

  void setQuery(String query) {
    if (query.length < 3) {
      state = const AsyncValue.data([]);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    state = const AsyncValue.loading();
    try {
      final results = await _service.searchMovies(query: query);
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, AsyncValue<List<Movie>>>(
  (ref) => SearchNotifier(ref.watch(movieServiceProvider)),
);
