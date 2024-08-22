import 'package:equatable/equatable.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object> get props => [];
}

class FetchMovies extends MovieEvent {}

class FetchMovieDetail extends MovieEvent {
  // Tambahkan event untuk mengambil detail film
  final String movieTitle;

  const FetchMovieDetail(this.movieTitle);

  @override
  List<Object> get props => [movieTitle];
}
