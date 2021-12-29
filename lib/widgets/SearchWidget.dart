import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ice_cream_truck_app/classes/Suggestion.dart';
import 'package:uuid/uuid.dart';

import '../classes/AddressSearch.dart';
import '../classes/apiProviders/PlacesApiProvider.dart';

class SearchWidget extends StatelessWidget {
  String placeId;
  Function setPlaceId;
  CameraPosition mapCenter;
  Function setMapCenter;
  Function goToLocation;
  final textController = TextEditingController();
  SearchWidget(
    this.placeId,
    this.setPlaceId,
    this.mapCenter,
    this.setMapCenter,
    this.goToLocation,
  ) {}

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      readOnly: true,
      onTap: () async {
        final sessionToken = Uuid().v4();
        final Suggestion? result = await showSearch(
          context: context,
          delegate: AddressSearch(sessionToken),
        );
        if (result != null) {
          updateText(result, sessionToken);
        }
      },
      decoration: InputDecoration(
        icon: Container(
          width: 10,
          height: 10,
          child: Icon(
            Icons.home,
            color: Colors.black,
          ),
        ),
        hintText: "Enter a search address",
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
      ),
    );
  }

  void updateText(Suggestion result, String sessionToken) async {
    final placeDetails = await PlacesApiProvider(sessionToken)
        .getPlaceDetailFromId(result.placeId);
    setPlaceId(result.placeId);
    textController.text = result.description;
    setMapCenter(CameraPosition(
      target: LatLng(placeDetails.lat, placeDetails.lng),
      zoom: 14.4746,
    ));
    goToLocation();
  }
}
