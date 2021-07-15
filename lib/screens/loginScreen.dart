import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_cream_truck_app/screens/customerHomePage.dart';
import 'package:ice_cream_truck_app/screens/driverHomePage.dart';

class loginScreen extends StatefulWidget {
  static const String id = 'loginScreen';
  loginScreen() {}

  @override
  _loginScreenState createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  String driverId = '';
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    super.dispose();
  }

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
              onChanged: (text) {
                setState(() {
                  this.driverId = text;
                });
              },
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 40.0,
            ),
            loginButton("Login as driver", () {
              Navigator.pushNamed(
                context,
                driverHomePage.id,
                arguments: {'driverId': this.driverId},
              );
            }),
            SizedBox(
              height: 40.0,
            ),
            loginButton(
              "Login as customer",
              () {
                Navigator.pushNamed(
                  context,
                  customerHomePage.id,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class loginButton extends StatelessWidget {
  String text;
  Function callback;
  loginButton(this.text, this.callback) {}

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: Colors.amber,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: Colors.black,
              textStyle: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              this.callback();
            },
            child: Text(this.text),
          ),
        ],
      ),
    );
  }
}
