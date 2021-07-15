import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ice_cream_truck_app/classes/DatabaseApiProvider.dart';
import 'package:ice_cream_truck_app/widgets/DateTimePickerWidget.dart';
import 'package:ice_cream_truck_app/widgets/MapWidget.dart';
import 'package:ice_cream_truck_app/widgets/SearchWidget.dart';
import '../classes/PlacesApiProvider.dart';
import 'package:geolocator/geolocator.dart';

class AddMarkerPage extends StatefulWidget {
  static const String id = 'addMarkerPage';
  AddMarkerPage();

  @override
  _AddMarkerPageState createState() => _AddMarkerPageState();
}

class _AddMarkerPageState extends State<AddMarkerPage> {
  String placeId = '';
  DateTime date = DateTime.now();
  Set<Marker> markerSet = {};
  Completer<GoogleMapController> mapsController = Completer();
  CameraPosition mapCenter = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    // TODO: implement initState

    updateUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add marker'),
        actions: [
          IconButton(
            icon: const Icon(IconData(0xe514, fontFamily: 'MaterialIcons')),
            onPressed: queryAndUpdate,
          ),
        ],
        bottom: PreferredSize(
          child: Column(
            children: [
              SearchWidget(
                placeId,
                setPlaceId,
                mapCenter,
                setMapCenter,
                goToLocation,
              ),
              DateTimePickerWidget(date, setDate),
            ],
          ),
          preferredSize: Size.fromHeight(100),
        ),
      ),
      body: MapWidget(
        mapsController,
        mapCenter,
        setMapCenter,
        markerSet,
        queryAndUpdate,
      ),
      floatingActionButton: Align(
        alignment: Alignment(1.1, 1),
        child: FloatingActionButton.extended(
          onPressed: updateUserLocation,
          label: Text('My Location'),
          icon: Icon(Icons.location_on),
        ),
      ),
    );
  }

  void setMapCenter(CameraPosition mapCenter) {
    setState(() {
      this.mapCenter = mapCenter;
    });
    queryAndUpdate();
  }

  void setPlaceId(String placeId) {
    setState(() {
      this.placeId = placeId;
    });
  }

  void setDate(DateTime date) {
    setState(() {
      this.date = date;
    });
    queryAndUpdate();
  }

  Future<void> goToLocation() async {
    final GoogleMapController controller = await mapsController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(mapCenter));
    queryAndUpdate();
  }

  queryAndUpdate() async {
    var query = await DatabaseApiProvider.getMarkersFromDatabase(
        mapCenter.target.latitude, mapCenter.target.longitude, 50000, date);
    setState(() {
      updateMarkers(query);
    });
  }

  updateMarkers(query) {
    this.markerSet = {};
    for (var driver in query) {
      this.markerSet.add(Marker(
            markerId: MarkerId(driver["driver_id"].toString()),
            position: LatLng(driver["location"]["coordinates"][1],
                driver["location"]["coordinates"][0]),
          ));
    }
  }

  Future<void> updateUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    var position = await Geolocator.getCurrentPosition();
    setMapCenter(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.4746,
    ));
    goToLocation();
  }
}
