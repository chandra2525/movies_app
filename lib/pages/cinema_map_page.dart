import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:html/parser.dart' as html_parser;
import 'package:geolocator/geolocator.dart';
// import 'cinema_repository.dart';
// import 'cinema_model.dart';
import 'package:movies_app/repositories/cinema_repository.dart';
import 'package:movies_app/repositories/directions_repository.dart';

class CinemaMapPage extends StatefulWidget {
  @override
  _CinemaMapPageState createState() => _CinemaMapPageState();
}

class _CinemaMapPageState extends State<CinemaMapPage> {
  late GoogleMapController mapController;
  Position? currentPosition;
  String? eta;
  List<String>? instructions;

  final CinemaRepository cinemaRepository = CinemaRepository();
  final DirectionsRepository directionsRepository = DirectionsRepository();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadCinemas();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // bool serviceEnabled;
    // LocationPermission permission;

    // // Periksa apakah layanan lokasi aktif
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   // Layanan lokasi tidak aktif, beri tahu pengguna untuk mengaktifkan
    //   return Future.error('Location services are disabled.');
    // }

    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   // Minta izin lokasi jika belum diberikan
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.denied) {
    //     // Izin lokasi ditolak, kembalikan error
    //     return Future.error('Location permissions are denied');
    //   }
    // }

    // if (permission == LocationPermission.deniedForever) {
    //   // Pengguna telah menolak izin lokasi secara permanen
    //   return Future.error(
    //       'Location permissions are permanently denied, we cannot request permissions.');
    // }

    // Ambil posisi pengguna jika izin diberikan
    currentPosition = await Geolocator.getCurrentPosition();

    setState(() {});
  }

  void _loadCinemas() {
    final cinemas = cinemaRepository.getCinemas();
    for (var cinema in cinemas) {
      _markers.add(
        Marker(
          markerId: MarkerId(cinema.name),
          position: LatLng(cinema.latitude, cinema.longitude),
          infoWindow: InfoWindow(
            title: cinema.name,
            onTap: () {
              _drawRouteAndETA(
                LatLng(currentPosition!.latitude, currentPosition!.longitude),
                LatLng(cinema.latitude, cinema.longitude),
              );
            },
          ),
        ),
      );
    }
    setState(() {});
  }

  void _drawRouteAndETA(LatLng start, LatLng end) async {
    final result = await directionsRepository.getRouteAndETA(start, end);
    final polyline = Polyline(
      polylineId: PolylineId('route'),
      points: _convertToLatLng(_decodePolyline(result['polyline'])),
      color: Colors.blue,
      width: 5,
    );
    setState(() {
      _polylines.add(polyline);
      eta = result['eta'];
      instructions = result['instructions']; // Set instructions
    });
  }

  List<LatLng> _convertToLatLng(List<mp.LatLng> points) {
    return points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  List<mp.LatLng> _decodePolyline(String polyline) {
    List<mp.LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(mp.LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  final String _darkModeMapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#424242"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.stroke",
        "stylers": [
          {
            "color": "#1f1f1f"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          }
        ]
      }
    ]
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Lokasi Bioskop',
          style: const TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // padding: const EdgeInsets.all(8),
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
        ),
        backgroundColor: Colors.black,
      ),
      body: currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    mapController.setMapStyle(_darkModeMapStyle);
                  },
                  initialCameraPosition: CameraPosition(
                    // target: LatLng(
                    //     currentPosition!.latitude, currentPosition!.longitude),
                    target: LatLng(-6.200000, 106.816666),
                    zoom: 12,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                ),
                if (eta != null) // Menampilkan ETA di layar
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.white,
                      child: Text('ETA: $eta', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                if (instructions != null) // Menampilkan instruksi navigasi
                  Positioned(
                    bottom: 60,
                    left: 20,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: instructions!
                            .map((instruction) => Text(
                                  _decodeHtml(instruction),
                                  style: TextStyle(fontSize: 14),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  // Fungsi untuk mendecode HTML dari instruksi
  String _decodeHtml(String htmlString) {
    var document = html_parser.parse(htmlString);
    return document.body?.text ?? htmlString;
  }
}

// class CinemaMapPage extends StatefulWidget {
//   @override
//   _CinemaMapPageState createState() => _CinemaMapPageState();
// }

// class _CinemaMapPageState extends State<CinemaMapPage> {
//   late GoogleMapController mapController;
//   Position? currentPosition;

//   final CinemaRepository cinemaRepository = CinemaRepository();
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};

//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//     _loadCinemas();
//   }

//   Future<void> _determinePosition() async {
//     currentPosition = await Geolocator.getCurrentPosition();
//     setState(() {});
//   }

//   void _loadCinemas() {
//     final cinemas = cinemaRepository.getCinemas();
//     for (var cinema in cinemas) {
//       _markers.add(
//         Marker(
//           markerId: MarkerId(cinema.name),
//           position: LatLng(cinema.latitude, cinema.longitude),
//           infoWindow: InfoWindow(
//             title: cinema.name,
//             onTap: () {
//               _drawRoute(
//                 LatLng(currentPosition!.latitude, currentPosition!.longitude),
//                 LatLng(cinema.latitude, cinema.longitude),
//               );
//             },
//           ),
//         ),
//       );
//     }
//     setState(() {});
//   }

//   void _drawRoute(LatLng start, LatLng end) async {
//     final route = await getRouteCoordinates(start, end);
//     final Polyline polyline = Polyline(
//       polylineId: PolylineId('route'),
//       points: route,
//       color: Colors.blue,
//       width: 5,
//     );
//     setState(() {
//       _polylines.add(polyline);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Lokasi Bioskop')),
//       body: currentPosition == null
//           ? Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               onMapCreated: (controller) {
//                 mapController = controller;
//               },
//               initialCameraPosition: CameraPosition(
//                 // target: LatLng(
//                 //     currentPosition!.latitude, currentPosition!.longitude),
//                 target: LatLng(-6.200000, 106.816666),
//                 zoom: 12,
//               ),
//               markers: _markers,
//               polylines: _polylines,
//               myLocationEnabled: true,
//             ),
//     );
//   }
// }
