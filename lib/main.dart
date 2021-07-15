import 'package:flutter/material.dart';
import 'package:ice_cream_truck_app/screens/AddMarkerPage.dart';
import 'package:ice_cream_truck_app/screens/CustomerHomePage.dart';
import 'package:ice_cream_truck_app/screens/DriverHomePage.dart';
import 'package:ice_cream_truck_app/screens/EditMarkerPage.dart';
import 'package:ice_cream_truck_app/screens/ListScheduledPage.dart';
import 'package:ice_cream_truck_app/screens/LoginScreen.dart';

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
      home: LoginScreen(),
      initialRoute: LoginScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        CustomerHomePage.id: (context) => CustomerHomePage(),
        DriverHomePage.id: (context) => DriverHomePage(),
        AddMarkerPage.id: (context) => AddMarkerPage(),
        EditMarkerPage.id: (context) => EditMarkerPage(),
        ListScheduledPage.id: (context) => ListScheduledPage(),
      },
    );
  }
}
