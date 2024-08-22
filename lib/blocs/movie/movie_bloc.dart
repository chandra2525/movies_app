import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movies_app/model/movie_model.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  MovieBloc() : super(MovieLoading()) {
    on<FetchMovies>(_onFetchMovies);
    on<FetchMovieDetail>(
        _onFetchMovieDetail); // Tambahkan handler untuk event FetchMovieDetail
  }

  Future<void> _onFetchMovies(
      FetchMovies event, Emitter<MovieState> emit) async {
    try {
      final response =
          await http.get(Uri.parse('https://swapi.dev/api/films/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['results'];
        final movies = data.map((json) => Movie.fromJson(json)).toList();
        emit(MovieLoaded(movies: movies));
      } else {
        emit(MovieError(error: 'Failed to fetch movies'));
      }
    } catch (e) {
      emit(MovieError(error: e.toString()));
    }
  }

  Future<void> _onFetchMovieDetail(
      FetchMovieDetail event, Emitter<MovieState> emit) async {
    emit(MovieDetailLoading()); // Set status loading

    try {
      final response = await http.get(
          Uri.parse('https://swapi.dev/api/films/?search=${event.movieTitle}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['results'][0];
        final movie = Movie.fromJson(data);
        emit(MovieDetailLoaded(
            movie: movie)); // Set status loaded dengan data detail film
      } else {
        emit(MovieError(error: 'Failed to fetch movie details'));
      }
    } catch (e) {
      emit(MovieError(error: e.toString()));
    }
  }
}
