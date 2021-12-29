import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_cream_truck_app/classes/apiProviders/AuthApiProvider.dart';
import 'package:ice_cream_truck_app/screens/CustomerHomePage.dart';
import 'package:ice_cream_truck_app/screens/DriverHomePage.dart';
import 'package:ice_cream_truck_app/screens/RegisterPage.dart';
import 'package:ice_cream_truck_app/widgets/LoginButtonWidget.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'loginPage';
  LoginPage() {}

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  String? emailError = null;
  String? passwordError = null;
  bool isDriver = false;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    this.isDriver = arguments['isDriver'];
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isDriver ? "Driver Login" : "Customer Login"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80.0),
          child: Column(
            children: [
              TextField(
                decoration:
                    InputDecoration(labelText: 'Email', errorText: emailError),
                keyboardType: TextInputType.emailAddress,
                onChanged: (text) {
                  setState(() {
                    this.email = text;
                  });
                },
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Password', errorText: passwordError),
                keyboardType: TextInputType.visiblePassword,
                onChanged: (text) {
                  setState(() {
                    this.password = text;
                  });
                },
              ),
              SizedBox(
                height: 40.0,
              ),
              LoginButton("Login              ", () async {
                var response = isDriver
                    ? await AuthApiProvider.loginDriver(email, password)
                    : await AuthApiProvider.loginCustomer(email, password);
                if (response.statusCode >= 400) {
                  setState(() {
                    emailError = json.decode(response.body)['error']['email'];
                    passwordError =
                        json.decode(response.body)['error']['password'];
                  });
                  return;
                }

                Navigator.pushNamedAndRemoveUntil(
                    context,
                    isDriver ? DriverHomePage.id : CustomerHomePage.id,
                    (r) => false);
              }),
              SizedBox(
                height: 10.0,
              ),
              TextButton(
                child: Text("New to the App? Register Here"),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RegisterPage.id,
                    arguments: {'isDriver': isDriver},
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
