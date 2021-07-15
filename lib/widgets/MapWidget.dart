import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatelessWidget {
  Completer<GoogleMapController> controller;
  Function setMapCenter;
  CameraPosition mapCenter;
  Set<Marker> markerSet;
  Function queryAndUpdate;

  MapWidget(this.controller, this.mapCenter, this.setMapCenter, this.markerSet,
      this.queryAndUpdate);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Listener(
        onPointerUp: (e) async {
          final GoogleMapController mapController =
              await this.controller.future;

          setMapCenter(CameraPosition(
            target: await getCameraCenter(mapController),
            zoom: 14.4746,
          ));
          queryAndUpdate();
        },
        child: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: mapCenter,
          onMapCreated: (GoogleMapController controller) {
            this.controller.complete(controller);
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: markerSet,
        ),
      ),
    );
  }

  getCameraCenter(mapController) async {
    LatLngBounds bounds = await mapController.getVisibleRegion();
    LatLng center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );
    return center;
  }
}
