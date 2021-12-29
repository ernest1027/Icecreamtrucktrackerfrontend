import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ice_cream_truck_app/classes/apiProviders/AuthApiProvider.dart';
import 'package:ice_cream_truck_app/screens/CustomerHomePage.dart';
import 'package:ice_cream_truck_app/screens/DriverHomePage.dart';
import 'package:ice_cream_truck_app/screens/LandingPage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    splashTimer();
    super.initState();
  }

  // ignore: missing_return
  Future<void> splashTimer() async {
    await AuthApiProvider.checkIfTokenValid();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    MaterialPageRoute route;
    if (accessToken == null) {
      route = MaterialPageRoute(
        builder: (BuildContext context) => LandingPage(),
      );
    } else if (Jwt.parseJwt(accessToken)['isDriver']) {
      route = MaterialPageRoute(
        builder: (BuildContext context) => DriverHomePage(),
      );
    } else {
      route = MaterialPageRoute(
        builder: (BuildContext context) => CustomerHomePage(),
      );
    }

    Timer(Duration(seconds: 2),
        () => Navigator.of(context).pushReplacement(route));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.0,
              height: 67.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/icecream.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Text('Ice Cream Truck Tracker')
          ],
        ),
      ),
    );
  }
}
