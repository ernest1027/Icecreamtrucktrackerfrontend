import 'package:flutter/material.dart';
import 'package:ice_cream_truck_app/home.dart';
import 'package:ice_cream_truck_app/screens/AddMarkerPage.dart';
import 'package:ice_cream_truck_app/screens/CustomerHomePage.dart';
import 'package:ice_cream_truck_app/screens/DriverHomePage.dart';
import 'package:ice_cream_truck_app/screens/EditMarkerPage.dart';
import 'package:ice_cream_truck_app/screens/ListScheduledPage.dart';
import 'package:ice_cream_truck_app/screens/LandingPage.dart';
import 'package:ice_cream_truck_app/screens/LoginPage.dart';
import 'package:ice_cream_truck_app/screens/RegisterPage.dart';

import 'classes/utils/NavigationService.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ice Cream Truck Tracker',
      navigatorKey: NavigationService.instance.navigationKey,
      theme: ThemeData(
        primaryColor: Color(0xFFBAABDA),
        primaryTextTheme: TextTheme(
          headline6: TextStyle(color: Colors.white),
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      // initialRoute: LoginScreen.id,
      routes: {
        LoginPage.id: (context) => LoginPage(),
        RegisterPage.id: (context) => RegisterPage(),
        LandingPage.id: (context) => LandingPage(),
        CustomerHomePage.id: (context) => CustomerHomePage(),
        DriverHomePage.id: (context) => DriverHomePage(),
        AddMarkerPage.id: (context) => AddMarkerPage(),
        EditMarkerPage.id: (context) => EditMarkerPage(),
        ListScheduledPage.id: (context) => ListScheduledPage(),
      },
    );
  }
}
