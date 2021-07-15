import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ice_cream_truck_app/widgets/dateTimePickerWidget.dart';
import 'package:ice_cream_truck_app/widgets/mapWidget.dart';
import 'package:ice_cream_truck_app/widgets/searchWidget.dart';
import '../place_service.dart';
import 'package:geolocator/geolocator.dart';

class customerHomePage extends StatefulWidget {
  customerHomePage({required this.title});
  final String title;

  @override
  _customerHomePageState createState() => _customerHomePageState();
}

class _customerHomePageState extends State<customerHomePage> {
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
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(IconData(0xe514, fontFamily: 'MaterialIcons')),
            onPressed: queryAndUpdate,
          ),
        ],
        bottom: PreferredSize(
          child: Column(
            children: [
              searchWidget(
                placeId,
                setPlaceId,
                mapCenter,
                setMapCenter,
                goToLocation,
              ),
              dateTimePickerWidget(date, setDate),
            ],
          ),
          preferredSize: Size.fromHeight(100),
        ),
      ),
      body: mapWidget(
        mapsController,
        mapCenter,
        setMapCenter,
        markerSet,
        queryAndUpdate,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async{await updateUserLocation();},
        label: Text('My Location'),
        icon: Icon(Icons.location_on),
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
    var query = await PlaceApiProvider("").getFromDatabase(
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

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var position = await Geolocator.getCurrentPosition();
    setMapCenter(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.4746,
    ));
    goToLocation();
  }
}
