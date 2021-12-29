import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:ice_cream_truck_app/classes/apiProviders/AuthApiProvider.dart';
import 'package:ice_cream_truck_app/classes/apiProviders/DatabaseApiProvider.dart';
import 'package:ice_cream_truck_app/screens/LandingPage.dart';
import 'package:ice_cream_truck_app/screens/ListScheduledPage.dart';
import 'package:ice_cream_truck_app/widgets/DateTimePickerWidget.dart';
import 'package:ice_cream_truck_app/widgets/MapWidget.dart';
import 'package:ice_cream_truck_app/widgets/SearchWidget.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/apiProviders/PlacesApiProvider.dart';
import 'package:geolocator/geolocator.dart';

class DriverHomePage extends StatefulWidget {
  static const String id = 'driverHomePage';
  DriverHomePage();

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  String placeId = '';
  DateTime date = DateTime.now();
  Set<Marker> markerSet = {};
  Completer<GoogleMapController> mapsController = Completer();
  CameraPosition mapCenter = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  bool sharingLocation = false;
  late Timer timer;

  @override
  void initState() {
    this.timer = new Timer.periodic(Duration(seconds: 30), (timer) {
      DatabaseApiProvider.sendLocation(sharingLocation);
    });
    super.initState();
    updateUserLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    this.timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Page'),
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.logout),
          onPressed: () async {
            AuthApiProvider.logout();
          },
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, ListScheduledPage.id);
            },
          ),
        ],
        bottom: PreferredSize(
          child: Column(
            children: [
              DateTimePickerWidget(date, setDate, 'Change Selected Time'),
              SearchWidget(
                placeId,
                setPlaceId,
                mapCenter,
                setMapCenter,
                goToLocation,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Send current location to database",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Switch(
                    onChanged: (bool value) {
                      setState(() {
                        sharingLocation = value;
                      });
                      DatabaseApiProvider.sendLocation(sharingLocation);
                    },
                    activeColor: Color(0xFFD77FA1),
                    value: sharingLocation,
                  ),
                ],
              ),
            ],
          ),
          preferredSize: Size.fromHeight(150),
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

  updateMarkers(query) async {
    this.markerSet = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    Map<String, dynamic> payload = Jwt.parseJwt(accessToken!);
    for (var driver in query) {
      if (driver["driver_id"].toString() == payload['id']) continue;
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
