import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:ice_cream_truck_app/classes/AuthApiProvider.dart';

class DatabaseApiProvider {
  static Future<dynamic> getMarkersFromDatabase(
      double lat, double lng, double radius, DateTime date) async {
    final client = Client();
    final request = AuthApiProvider.apiURL +
        '/search?lat=${lat}&lng=${lng}&radius=${radius}&time=${date.millisecondsSinceEpoch}';
    print(request);
    final response = await client.get(Uri.parse(request));
    return json.decode(response.body)["data"];
  }

  static void sendLocation(bool sharingLocation, String driverId) async {
    if (!sharingLocation) return;
    var position = await Geolocator.getCurrentPosition();
    final request = AuthApiProvider.apiURL +
        '/report?lat=${position.latitude}&lng=${position.longitude}&scheduled=false&driver_id=${driverId}&startTime=${DateTime.now().millisecondsSinceEpoch}&endTime=${DateTime.now().millisecondsSinceEpoch}';
    var client = Client();
    print(request);
    client.post(Uri.parse((request)));
  }

  static Future<List> getAllScheduledLocations(String driverId) async {
    final client = Client();
    final request =
        AuthApiProvider.apiURL + '/search/scheduled?driver_id=${driverId}';
    print(request);
    final response = await client.get(Uri.parse(request));
    print(json.decode(response.body)["data"]);
    return json.decode(response.body)["data"];
  }

  static void sendScheduledLocation(String driverId, double lat, double lng,
      DateTime start, DateTime end, String description) async {
    final request = AuthApiProvider.apiURL +
        '/report?lat=${lat}&lng=${lng}&scheduled=true&driver_id=${driverId}&startTime=${start.millisecondsSinceEpoch}&endTime=${end.millisecondsSinceEpoch}&description=${description}';
    var client = Client();
    print(request);
    client.post(Uri.parse((request)));
  }

  static Future<int> deleteScheduledLocation(String id) async {
    final request = AuthApiProvider.apiURL + '/report?id=${id}';
    var client = Client();
    print(request);
    await client.delete(Uri.parse((request)));
    return 1;
  }
}
