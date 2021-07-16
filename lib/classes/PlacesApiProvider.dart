import 'dart:convert';
import 'package:http/http.dart';
import 'package:ice_cream_truck_app/classes/Suggestion.dart';
import 'Coordinates.dart';

class PlacesApiProvider {
  final client = Client();

  PlacesApiProvider(this.sessionToken);

  final sessionToken;

  final apiKey = 'AIzaSyDpn1DGZqFL26rRcEcds_2_lUCmjz2YNlM';

  Future<Coordinates> getPlaceDetailFromId(String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return Coordinates(result["result"]["geometry"]["location"]["lat"],
            result["result"]["geometry"]["location"]["lng"]);
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&components=country:ca&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<String> getPlaceDetailFromCoord(Coordinates coord) async {
    final request =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${coord.lat},${coord.lng}&key=$apiKey&sessiontoken=$sessionToken';
    print(request);
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print(result);
      if (result['status'] == 'OK') {
        return (result["results"][0]["formatted_address"]);
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
