import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:ice_cream_truck_app/classes/apiProviders/AuthApiProvider.dart';

class DatabaseApiProvider {
  static Future<dynamic> getMarkersFromDatabase(
      double lat, double lng, double radius, DateTime date) async {
    final request = AuthApiProvider.apiURL +
        '/search?lat=${lat}&lng=${lng}&radius=${radius}&time=${date.millisecondsSinceEpoch}';
    final response = await AuthApiProvider.authenticatedGetRequest(request);
    return json.decode(response.body)["data"]['result'];
  }

  static void sendLocation(bool sharingLocation) async {
    if (!sharingLocation) return;
    var position = await Geolocator.getCurrentPosition();
    final request = AuthApiProvider.apiURL +
        '/report?lat=${position.latitude}&lng=${position.longitude}&scheduled=false&startTime=${DateTime.now().millisecondsSinceEpoch}&endTime=${DateTime.now().millisecondsSinceEpoch}';
    AuthApiProvider.authenticatedPostRequest(request, []);
  }

  static Future<List> getAllScheduledLocations() async {
    final request = AuthApiProvider.apiURL + '/search/scheduled';
    final response = await AuthApiProvider.authenticatedGetRequest(request);
    return json.decode(response.body)["data"]['result'];
  }

  static void sendScheduledLocation(double lat, double lng, DateTime start,
      DateTime end, String description) async {
    final request = AuthApiProvider.apiURL +
        '/report?lat=${lat}&lng=${lng}&scheduled=true&startTime=${start.millisecondsSinceEpoch}&endTime=${end.millisecondsSinceEpoch}&description=${description}';
    AuthApiProvider.authenticatedPostRequest(request, []);
  }

  static Future<int> deleteScheduledLocation(String id) async {
    final request = AuthApiProvider.apiURL + '/report?id=${id}';
    await AuthApiProvider.authenticatedDeleteRequest(request);
    return 1;
  }
}
