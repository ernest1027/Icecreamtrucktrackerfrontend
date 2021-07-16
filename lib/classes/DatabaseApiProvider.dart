import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

class DatabaseApiProvider {
  static Future<dynamic> getMarkersFromDatabase(
      double lat, double lng, double radius, DateTime date) async {
    final client = Client();
    final request =
        'https://evening-bastion-66790.herokuapp.com/location/search?lat=${lat}&lng=${lng}&radius=${radius}&time=${date.millisecondsSinceEpoch}';
    print(request);
    final response = await client.get(Uri.parse(request));
    return json.decode(response.body)["data"];
  }

  static void sendLocation(bool sharingLocation, String driverId) async {
    if (!sharingLocation) return;
    var position = await Geolocator.getCurrentPosition();
    final request =
        'https://evening-bastion-66790.herokuapp.com/location/report?lat=${position.latitude}&lng=${position.longitude}&scheduled=false&driver_id=${driverId}&startTime=${DateTime.now().millisecondsSinceEpoch}&endTime=${DateTime.now().millisecondsSinceEpoch}';
    var client = Client();
    print(request);
    client.post(Uri.parse((request)));
  }

  static Future<List> getAllScheduledLocations(String driverId) async {
    final client = Client();
    final request =
        'https://evening-bastion-66790.herokuapp.com/location/searchScheduled?driver_id=${driverId}';
    print(request);
    final response = await client.get(Uri.parse(request));
    print(json.decode(response.body)["data"]);
    return json.decode(response.body)["data"];
  }

  static void sendScheduledLocation(String driverId, double lat, double lng,
      DateTime start, DateTime end, String description) async {
    final request =
        'https://evening-bastion-66790.herokuapp.com/location/report?lat=${lat}&lng=${lng}&scheduled=true&driver_id=${driverId}&startTime=${start.millisecondsSinceEpoch}&endTime=${end.millisecondsSinceEpoch}&description=${description}';
    var client = Client();
    print(request);
    client.post(Uri.parse((request)));
  }

  static void deleteScheduledLocation(String id) async {
    final request =
        'https://evening-bastion-66790.herokuapp.com/location/report?id=${id}';
    var client = Client();
    print(request);
    client.delete(Uri.parse((request)));
  }
}
