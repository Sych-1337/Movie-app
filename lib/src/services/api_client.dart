import 'package:dio/dio.dart';

class ApiClient {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _apiKey = 'db1a335ca9a81dce3f1e84b198077f43';
  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      queryParameters: {
        'api_key': _apiKey,
        'language': 'en-US',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
