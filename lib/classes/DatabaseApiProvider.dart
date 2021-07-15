import 'dart:convert';
import 'package:http/http.dart';

class DatabaseApiProvider {
  static Future<dynamic> getMarkersFromDatabase(
      double lat, double lng, double radius, DateTime date) async {
    final client = Client();
    final request =
        'http://localhost:8000/location/search?lat=${lat}&lng=${lng}&radius=${radius}&time=${date.millisecondsSinceEpoch}';
    print(request);
    final response = await client.get(Uri.parse(request));
    return json.decode(response.body)["data"];
  }
}
