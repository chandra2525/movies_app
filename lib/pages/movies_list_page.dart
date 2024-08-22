import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/blocs/movie/movie_bloc.dart';
import 'package:movies_app/blocs/movie/movie_event.dart';
import 'package:movies_app/blocs/movie/movie_state.dart';
import 'package:movies_app/pages/movie_detail_page.dart';

class MoviesListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0, top: 12.0),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'FREE',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w900),
              ),
              Text(
                'FLIX',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.red,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Brings',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: ' Free ',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 22,
                        fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: 'Streaming to',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const Text(
              'Your Device',
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 30.0),
            Expanded(
              child: BlocProvider(
                create: (context) => MovieBloc()..add(FetchMovies()),
                child: BlocBuilder<MovieBloc, MovieState>(
                  builder: (context, state) {
                    if (state is MovieLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MovieLoaded) {
                      return ListView.builder(
                        itemCount: state.movies.length,
                        itemBuilder: (context, index) {
                          final movie = state.movies[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MovieDetailPage(movieTitle: movie.title),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, bottom: 4.0),
                                  child: Text(
                                    'Sutradara : ${movie.director}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rilis : ${movie.releaseDate}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      'Jumlah Eps : ${movie.episodeId}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding:
                                      EdgeInsets.only(top: 12.0, bottom: 8.0),
                                  child: Divider(
                                    color: Colors.white,
                                    thickness: 0.3,
                                    height: 1,
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    } else if (state is MovieError) {
                      return Center(
                          child: Text('Gagal memuat film: ${state.error}'));
                    }
                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
