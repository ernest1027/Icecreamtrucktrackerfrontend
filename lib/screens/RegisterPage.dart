import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_cream_truck_app/classes/apiProviders/AuthApiProvider.dart';
import 'package:ice_cream_truck_app/screens/CustomerHomePage.dart';
import 'package:ice_cream_truck_app/screens/DriverHomePage.dart';
import 'package:ice_cream_truck_app/widgets/LoginButtonWidget.dart';

class RegisterPage extends StatefulWidget {
  static const String id = 'registerPage';
  RegisterPage() {}

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String firstname = '';
  String lastname = '';
  String email = '';
  String password = '';
  String password2 = '';
  String companyKey = '';

  String? firstnameError;
  String? lastnameError;
  String? emailError;
  String? passwordError;
  String? password2Error;
  String? companyKeyError;

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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                      labelText: 'First Name', errorText: firstnameError),
                  onChanged: (text) {
                    setState(() {
                      this.firstname = text;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Last Name', errorText: lastnameError),
                  onChanged: (text) {
                    setState(() {
                      this.lastname = text;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Email', errorText: emailError),
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
                  onChanged: (text) {
                    setState(() {
                      this.password = text;
                    });
                  },
                ),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Confirm Password', errorText: password2Error),
                  onChanged: (text) {
                    setState(() {
                      this.password2 = text;
                    });
                  },
                ),
                (isDriver
                    ? TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Company Key',
                            errorText: companyKeyError),
                        onChanged: (text) {
                          setState(() {
                            this.companyKey = text;
                          });
                        },
                      )
                    : Container()),
                SizedBox(
                  height: 40.0,
                ),
                LoginButton("Register              ", onRegister),
                SizedBox(
                  height: 10.0,
                ),
                TextButton(
                  child: Text("Have an Account? Login Here"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onRegister() async {
    var response = isDriver
        ? await AuthApiProvider.registerDriver(
            firstname, lastname, email, password, password2, companyKey)
        : await AuthApiProvider.registerCustomer(
            firstname, lastname, email, password, password2);
    if (response.statusCode >= 400) {
      setState(() {
        firstnameError = json.decode(response.body)['error']['firstname'];
        lastnameError = json.decode(response.body)['error']['lastname'];
        emailError = json.decode(response.body)['error']['email'];
        passwordError = json.decode(response.body)['error']['password'];
        password2Error = json.decode(response.body)['error']['password2'];
        companyKeyError = json.decode(response.body)['error']['companykey'];
      });
      return;
    }
    if (isDriver)
      await AuthApiProvider.loginDriver(email, password);
    else
      await AuthApiProvider.loginCustomer(email, password);
    Navigator.pushNamedAndRemoveUntil(context,
        isDriver ? DriverHomePage.id : CustomerHomePage.id, (r) => false);
  }
}
