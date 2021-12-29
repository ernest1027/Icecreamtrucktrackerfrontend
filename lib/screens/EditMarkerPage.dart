import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ice_cream_truck_app/classes/Coordinates.dart';
import 'package:ice_cream_truck_app/classes/DatabaseApiProvider.dart';
import 'package:ice_cream_truck_app/widgets/DateTimePickerWidget.dart';
import 'package:ice_cream_truck_app/widgets/MapWidget.dart';
import 'package:ice_cream_truck_app/widgets/SearchWidget.dart';
import '../classes/PlacesApiProvider.dart';
import 'package:geolocator/geolocator.dart';

class EditMarkerPage extends StatefulWidget {
  static const String id = 'editMarkerPage';
  EditMarkerPage();

  @override
  _EditMarkerPageState createState() => _EditMarkerPageState();
}

class _EditMarkerPageState extends State<EditMarkerPage> {
  String placeId = '';
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  Set<Marker> markerSet = {};
  Completer<GoogleMapController> mapsController = Completer();
  CameraPosition mapCenter = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  bool inited = false;
  late Map data;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    this.data = arguments['data'];
    setAllData();
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit marker'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DateTimePickerWidget(startTime, setStartTime, "Start time"),
                  DateTimePickerWidget(endTime, setEndTime, "End time"),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Delete Marker',
                        style: TextStyle(fontSize: 20, color: Colors.red),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => deleteMarker(context)),
                    TextSpan(text: "                      "),
                    TextSpan(
                        text: 'Save Marker',
                        style: TextStyle(fontSize: 20, color: Colors.green),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => saveMarker(context)),
                  ],
                ),
              ),
            ],
          ),
          preferredSize: Size.fromHeight(100),
        ),
      ),
      body: Stack(children: [
        MapWidget(
          mapsController,
          mapCenter,
          setMapCenter,
          markerSet,
          queryAndUpdate,
        ),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Center(
              child: Image(
            width: 20,
            image: NetworkImage(
                'http://www.clker.com/cliparts/e/3/F/I/0/A/google-maps-marker-for-residencelamontagne-hi.png'),
          ))
        ]),
      ]),
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

  void setStartTime(DateTime date) {
    setState(() {
      this.startTime = date;
    });
    queryAndUpdate();
  }

  void setEndTime(DateTime date) {
    setState(() {
      this.endTime = date;
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
        mapCenter.target.latitude,
        mapCenter.target.longitude,
        50000,
        startTime);
    setState(() {
      updateMarkers(query);
    });
  }

  updateMarkers(query) {
    this.markerSet = {};
    for (var driver in query) {
      if (driver["driver_id"].toString() == this.data["driver_id"].toString())
        continue;
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

  void dismissScreen(context) {
    Navigator.pop(context);
  }

  void saveMarker(context) async {
    String details = await PlacesApiProvider("").getPlaceDetailFromCoord(
        new Coordinates(mapCenter.target.latitude, mapCenter.target.longitude));
    print(details);
    DatabaseApiProvider.sendScheduledLocation(
        this.data["driver_id"].toString(),
        mapCenter.target.latitude,
        mapCenter.target.longitude,
        this.startTime,
        this.endTime,
        details);
    await DatabaseApiProvider.deleteScheduledLocation(this.data["_id"]);
    dismissScreen(context);
  }

  void setAllData() {
    if (inited) return;
    setState(() {
      inited = true;
      startTime = DateTime.parse(this.data["startTime"]).toLocal();
      endTime = DateTime.parse(this.data["endTime"]).toLocal();
      setMapCenter(CameraPosition(
        target: LatLng(this.data["location"]["coordinates"][1],
            this.data["location"]["coordinates"][0]),
        zoom: 14.4746,
      ));
      print(mapCenter);
      goToLocation();
    });
  }

  deleteMarker(BuildContext context) async {
    await DatabaseApiProvider.deleteScheduledLocation(
        this.data["_id"].toString());
    dismissScreen(context);
  }
}
