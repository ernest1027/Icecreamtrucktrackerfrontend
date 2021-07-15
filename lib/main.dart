import 'package:flutter/material.dart';
import 'package:ice_cream_truck_app/screens/customerHomePage.dart';

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
      home: customerHomePage(title: 'Ice Cream Truck Tracker'),
    );
  }
}
