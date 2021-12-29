import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_cream_truck_app/screens/CustomerHomePage.dart';
import 'package:ice_cream_truck_app/screens/DriverHomePage.dart';
import 'package:ice_cream_truck_app/widgets/LoginButtonWidget.dart';

import 'LoginPage.dart';

class LandingPage extends StatefulWidget {
  static const String id = 'landingPage';
  LandingPage() {}

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ice Cream Truck Tracker"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80.0),
          child: Column(
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
                height: 40.0,
              ),
              LoginButton("Login as Driver", () {
                Navigator.pushNamed(
                  context,
                  LoginPage.id,
                  arguments: {'isDriver': true},
                );
              }),
              SizedBox(
                height: 40.0,
              ),
              LoginButton(
                "Login as Customer",
                () {
                  Navigator.pushNamed(
                    context,
                    LoginPage.id,
                    arguments: {'isDriver': false},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
