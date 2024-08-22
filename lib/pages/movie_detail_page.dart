import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/blocs/movie/movie_bloc.dart';
import 'package:movies_app/blocs/movie/movie_event.dart';
import 'package:movies_app/blocs/movie/movie_state.dart';
import 'package:movies_app/model/reminder_model.dart';
import 'package:movies_app/pages/cinema_map_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MovieDetailPage extends StatefulWidget {
  final String movieTitle;

  const MovieDetailPage({Key? key, required this.movieTitle}) : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // iOS: IOSInitializationSettings(),
      iOS: DarwinInitializationSettings(),
    );
    _notificationsPlugin.initialize(initializationSettings);
  }

  void _scheduleNotification() async {
    final now = DateTime.now();
    final reminder = Reminder(
      title: widget.movieTitle,
      scheduledTime:
          now.add(Duration(hours: 1)), // Atur pengingat 1 jam dari sekarang
    );

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
      ),
      // iOS: IOSNotificationDetails(),
    );

    await _notificationsPlugin.schedule(
      0,
      'Pengingat Bioskop',
      'Saatnya pergi ke bioskop: ${reminder.title}',
      reminder.scheduledTime,
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   title: Text(
      //     widget.movieTitle,
      //     style: const TextStyle(
      //         fontSize: 24, color: Colors.white, fontWeight: FontWeight.w900),
      //   ),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back_ios),
      //     color: Colors.white, // Set the color of the back icon
      //     onPressed: () {
      //       // Add your action here
      //     },
      //   ),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                // margin: EdgeInsets.only(top: size.height * 0.1),
                // width: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                  // borderRadius: BorderRadius.only(
                  //   topLeft: Radius.circular(50.0),
                  //   topRight: Radius.circular(50.0),
                  // )
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
              const SizedBox(height: 12.0),
              Expanded(
                child: ListView(
                  children: [
                    BlocProvider(
                      create: (context) => MovieBloc()
                        ..add(FetchMovieDetail(widget
                            .movieTitle)), // Memicu event FetchMovieDetail
                      child: BlocBuilder<MovieBloc, MovieState>(
                        builder: (context, state) {
                          if (state is MovieDetailLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is MovieDetailLoaded) {
                            final movie = state.movie;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 16),
                                Text('Sutradara : ${movie.director}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300)),
                                const SizedBox(height: 8),
                                Text('Produser : ${movie.producer}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300)),
                                const SizedBox(height: 12),
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: movie.releaseDate,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const TextSpan(
                                          text: '  •  ',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500)),
                                      TextSpan(
                                        text: '${movie.episodeId} Eps',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Ringkasan:',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  movie.openingCrawl,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 12, 20, 12)),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CinemaMapPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Lihat Lokasi Bioskop',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 12, 20, 12)),
                                    onPressed: () {
                                      // final now = DateTime.now();
                                      // final reminder = Reminder(
                                      //   title: movieTitle,
                                      //   scheduledTime: now.add(Duration(
                                      //       hours: 1)), // Atur pengingat 1 jam dari sekarang
                                      // );
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         ReminderPage(reminder: reminder),
                                      //   ),
                                      // );

                                      _scheduleNotification();
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Atur Pengingat',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          } else if (state is MovieError) {
                            return Center(
                                child: Text(
                                    'Gagal memuat detail film: ${state.error}'));
                          }
                          return Container();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
