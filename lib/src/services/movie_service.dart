import 'package:dio/dio.dart';
import '../models/movie.dart';
import '../models/movie_details.dart';
import 'api_client.dart';

class MovieService {
  final Dio _dio;

  MovieService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<List<Movie>> fetchTopRated({int page = 1}) async {
    final response = await _dio.get('/movie/top_rated', queryParameters: {
      'page': page,
    });
    final results = response.data['results'] as List;
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  Future<MovieDetails> fetchMovieDetails(int movieId) async {
    final response = await _dio.get('/movie/$movieId');
    return MovieDetails.fromJson(response.data);
  }

  Future<List<Movie>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/search/movie',
      queryParameters: {
        'query': query,
        'page': page,
        'include_adult': false,
      },
    );
    final results = response.data['results'] as List;
    return results.map((e) => Movie.fromJson(e)).toList();
  }
}
