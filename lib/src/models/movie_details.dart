class MovieDetails {
  final int id;
  final String title;
  final String? posterPath;
  final double voteAverage;
  final String overview;
  final String releaseDate;

  MovieDetails({
    required this.id,
    required this.title,
    this.posterPath,
    required this.voteAverage,
    required this.overview,
    required this.releaseDate,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['id'] as int,
      title: json['title'] as String,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      overview: json['overview'] as String,
      releaseDate: json['release_date'] as String,
    );
  }
}
