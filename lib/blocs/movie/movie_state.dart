import 'package:equatable/equatable.dart';
import 'package:movies_app/model/movie_model.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object> get props => [];
}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<Movie> movies;

  const MovieLoaded({required this.movies});

  @override
  List<Object> get props => [movies];
}

class MovieDetailLoading
    extends MovieState {} // Status loading untuk detail film

class MovieDetailLoaded extends MovieState {
  // Status ketika detail film berhasil dimuat
  final Movie movie;

  const MovieDetailLoaded({required this.movie});

  @override
  List<Object> get props => [movie];
}

class MovieError extends MovieState {
  final String error;

  const MovieError({required this.error});

  @override
  List<Object> get props => [error];
}
