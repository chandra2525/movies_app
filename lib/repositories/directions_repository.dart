import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsRepository {
  final String apiKey = 'AIzaSyDll7fuFD_F2ohgFFi1jO8hJxhvWydP4EI';

  Future<Map<String, dynamic>> getRouteAndETA(LatLng start, LatLng end) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final polylinePoints = data['routes'][0]['overview_polyline']['points'];
      final duration = data['routes'][0]['legs'][0]['duration']['text'];
      final steps = data['routes'][0]['legs'][0]['steps'] as List;
      final instructions =
          steps.map((step) => step['html_instructions']).toList();
      return {
        'polyline': polylinePoints,
        'eta': duration,
        'instructions': instructions
      };
    } else {
      throw Exception('Failed to load directions');
    }
  }

  // Future<Map<String, dynamic>> getRouteAndETA(LatLng start, LatLng end) async {
  //   final String url =
  //       'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final polylinePoints = data['routes'][0]['overview_polyline']['points'];
  //     final duration = data['routes'][0]['legs'][0]['duration']['text'];
  //     return {'polyline': polylinePoints, 'eta': duration};
  //   } else {
  //     throw Exception('Failed to load directions');
  //   }
  // }
}

Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng end) async {
  final String url =
      'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=AIzaSyDll7fuFD_F2ohgFFi1jO8hJxhvWydP4EI';

  final response = await Dio().get(url);
  final data = response.data['routes'][0]['overview_polyline']['points'];

  return _decodePolyline(data);
}

List<LatLng> _decodePolyline(String polyline) {
  List<LatLng> points = [];
  int index = 0, len = polyline.length;
  int lat = 0, lng = 0;

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

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return points;
}
