import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'address_search.dart';
import 'place_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ice Cream Truck Tracker',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Ice Cream Truck Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';
  String _placeId = '';
  DateTime Date = DateTime.now();
  Set<Marker> markerSet = {};

  Completer<GoogleMapController> _mapsController = Completer();

  CameraPosition _kMapCenter = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(IconData(0xe514, fontFamily: 'MaterialIcons')),
            onPressed: () async {
              var query = await PlaceApiProvider("asd").getFromDatabase(
                  _kMapCenter.target.latitude,
                  _kMapCenter.target.longitude,
                  50000,
                  Date);
              print(query);
              setState(() {
                updateMarkers(query);
              });
            },
          ),
        ],
        bottom: PreferredSize(
          child: Column(
            children: [
              TextField(
                controller: _textController,
                readOnly: true,
                onTap: () async {
                  // generate a new token here
                  final sessionToken = Uuid().v4();
                  final Suggestion? result = await showSearch(
                    context: context,
                    delegate: AddressSearch(sessionToken),
                  );
                  // This will change the text displayed in the TextField
                  if (result != null) {
                    final placeDetails = await PlaceApiProvider(sessionToken)
                        .getPlaceDetailFromId(result.placeId);
                    setState(() {
                      _placeId = result.placeId;
                      _textController.text = result.description;
                      _streetNumber = placeDetails.streetNumber;
                      _street = placeDetails.street;
                      _city = placeDetails.city;
                      _zipCode = placeDetails.zipCode;
                      _kMapCenter = CameraPosition(
                        target: LatLng(placeDetails.lat, placeDetails.lng),
                        zoom: 14.4746,
                      );
                      _goToLocation();
                    });
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
              ),
              TextButton(
                onPressed: () {
                  DatePicker.showTimePicker(context, showSecondsColumn: false,
                      onChanged: (date) {
                    print('change $date');
                  }, onConfirm: (date) {
                    print('confirm $date');
                    setState(() {
                      Date = date;
                    });
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                child: Text(
                  'Selected time : ${Date.hour}:${Date.minute}',
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ],
          ),
          preferredSize: Size.fromHeight(100),
        ),
      ),
      body: Container(
        child: Listener(
          onPointerUp: (e) async {
            final GoogleMapController controller = await _mapsController.future;
            LatLngBounds bounds = await controller.getVisibleRegion();
            LatLng center = LatLng(
              (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
              (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
            );
            _kMapCenter = CameraPosition(
              target: center,
              zoom: 14.4746,
            );
            var query = await PlaceApiProvider("asd").getFromDatabase(
                _kMapCenter.target.latitude,
                _kMapCenter.target.longitude,
                50000,
                Date);
            setState(() {
              updateMarkers(query);
            });
          },
          child: GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kMapCenter,
            onMapCreated: (GoogleMapController controller) {
              _mapsController.complete(controller);
            },
            markers: markerSet,
          ),
        ),
      ),
    );
  }

  Future<void> _goToLocation() async {
    final GoogleMapController controller = await _mapsController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kMapCenter));
    var query = await PlaceApiProvider("asd").getFromDatabase(
        _kMapCenter.target.latitude, _kMapCenter.target.longitude, 50000, Date);
    updateMarkers(query);
  }

  updateMarkers(query) {
    print(Date);
    print(query);
    print(_kMapCenter);
    this.markerSet = {};
    for (var driver in query) {
      this.markerSet.add(Marker(
            markerId: MarkerId(driver["driver_id"].toString()),
            position: LatLng(driver["location"]["coordinates"][1],
                driver["location"]["coordinates"][0]),
          ));
    }
  }
}
