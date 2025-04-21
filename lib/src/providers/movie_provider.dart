import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie.dart';
import '../models/movie_details.dart';
import '../services/movie_service.dart';


final movieServiceProvider = Provider<MovieService>((ref) => MovieService());

final topRatedMoviesProvider =
    FutureProvider.family<List<Movie>, int>((ref, page) async {
  final service = ref.watch(movieServiceProvider);
  return service.fetchTopRated(page: page);
});

final movieDetailsProvider =
    FutureProvider.family<MovieDetails, int>((ref, movieId) async {
  final service = ref.watch(movieServiceProvider);
  return service.fetchMovieDetails(movieId);
});
