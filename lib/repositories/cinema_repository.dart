import 'package:movies_app/model/cinema_model.dart';
import 'package:movies_app/model/movie_model.dart';

class CinemaRepository {
  List<Cinema> getCinemas() {
    return [
      Cinema(name: "Cinema 1", latitude: -6.200000, longitude: 106.816666),
      Cinema(name: "Cinema 2", latitude: -6.210000, longitude: 106.826666),
      Cinema(name: "Cinema 3", latitude: -6.220000, longitude: 106.836666),
      Cinema(name: "Cinema 4", latitude: -6.230000, longitude: 106.846666),
      Cinema(name: "Cinema 5", latitude: -6.240000, longitude: 106.856666),
    ];
  }

  List<Cinema> getCinemasForMovie(Movie movie) {
    // Untuk simulasi, kita anggap semua bioskop menayangkan semua film
    // Dalam aplikasi nyata, ini bisa dihubungkan dengan data bioskop yang lebih spesifik
    return getCinemas();
  }
}
