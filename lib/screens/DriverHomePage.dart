import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:ice_cream_truck_app/classes/DatabaseApiProvider.dart';
import 'package:ice_cream_truck_app/screens/ListScheduledPage.dart';
import 'package:ice_cream_truck_app/widgets/DateTimePickerWidget.dart';
import 'package:ice_cream_truck_app/widgets/MapWidget.dart';
import 'package:ice_cream_truck_app/widgets/SearchWidget.dart';
import '../classes/PlacesApiProvider.dart';
import 'package:geolocator/geolocator.dart';

class DriverHomePage extends StatefulWidget {
  static const String id = 'driverHomePage';
  DriverHomePage();

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  String placeId = '';
  String driverId = '';
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
      DatabaseApiProvider.sendLocation(sharingLocation, driverId);
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
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    this.driverId = arguments['driverId'] == '' ? "1" : arguments['driverId'];
    return Scaffold(
      appBar: AppBar(
        title: Text('driver id is ${driverId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                context,
                ListScheduledPage.id,
                arguments: {'driverId': driverId},
              );
            },
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
              DateTimePickerWidget(date, setDate, 'Selected time'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Send current location to database"),
                  ),
                  Switch(
                    onChanged: (bool value) {
                      setState(() {
                        sharingLocation = value;
                      });
                      DatabaseApiProvider.sendLocation(
                          sharingLocation, driverId);
                    },
                    activeColor: Colors.green,
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
    print(query);
    setState(() {
      updateMarkers(query);
    });
  }

  updateMarkers(query) {
    this.markerSet = {};
    for (var driver in query) {
      if (driver["driver_id"].toString() == this.driverId) continue;
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
