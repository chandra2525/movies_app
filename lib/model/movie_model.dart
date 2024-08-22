class Movie {
  final String title;
  final String director;
  final String releaseDate;
  final String openingCrawl;
  final String episodeId;
  final String producer;

  Movie({
    required this.title,
    required this.director,
    required this.releaseDate,
    required this.openingCrawl,
    required this.episodeId,
    required this.producer,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      director: json['director'],
      releaseDate: json['release_date'],
      openingCrawl: json['opening_crawl'],
      episodeId: json['episode_id'].toString(),
      producer: json['producer'],
    );
  }
}
