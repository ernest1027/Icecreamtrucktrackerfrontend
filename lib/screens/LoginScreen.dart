import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_cream_truck_app/screens/CustomerHomePage.dart';
import 'package:ice_cream_truck_app/screens/DriverHomePage.dart';
import 'package:ice_cream_truck_app/widgets/LoginButtonWidget.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'loginScreen';
  LoginScreen() {}

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String driverId = '';

  @override
  Widget build(BuildContext context) {
    String driverId;
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to the Ice Cream Truck App"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                  hintText: "Enter a driver id (must be a number)"),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              keyboardType: TextInputType.number,
              onChanged: (text) {
                setState(() {
                  this.driverId = text;
                });
              },
            ),
            SizedBox(
              height: 40.0,
            ),
            LoginButton("Login as driver", () {
              Navigator.pushNamed(
                context,
                DriverHomePage.id,
                arguments: {'driverId': this.driverId},
              );
            }),
            SizedBox(
              height: 40.0,
            ),
            LoginButton(
              "Login as customer",
              () {
                Navigator.pushNamed(
                  context,
                  CustomerHomePage.id,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
