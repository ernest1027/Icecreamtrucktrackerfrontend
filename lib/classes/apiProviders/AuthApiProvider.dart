import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:ice_cream_truck_app/screens/LandingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/NavigationService.dart';

class AuthApiProvider {
  static final apiURL = 'http://127.0.0.1:8000';

  static dynamic loginDriver(String email, String password) async {
    final url = apiURL + '/authentication/login/driver';
    return genericLogin(url, email, password);
  }

  static dynamic loginCustomer(String email, String password) async {
    final url = apiURL + '/authentication/login/customer';
    return genericLogin(url, email, password);
  }

  static dynamic genericLogin(String url, String email, String password) async {
    var client = Client();
    final response = await client
        .post(Uri.parse((url)), body: {'email': email, 'password': password});
    if (response.statusCode >= 400) return response;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'accessToken', json.decode(response.body)["data"]['accessToken']);
    prefs.setString(
        'refreshToken', json.decode(response.body)["data"]['refreshToken']);
    return response;
  }

  static dynamic registerDriver(String firstname, String lastname, String email,
      String password, String password2, String companyKey) {
    final url = apiURL + '/authentication/register/driver';
    final body = {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'password2': password2,
      'companyKey': companyKey
    };
    return genericRegister(body, url);
  }

  static dynamic registerCustomer(String firstname, String lastname,
      String email, String password, String password2) {
    final url = apiURL + '/authentication/register/customer';
    final body = {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'password2': password2,
    };
    return genericRegister(body, url);
  }

  static dynamic genericRegister(Map<String, String> body, url) async {
    var client = Client();
    final response = await client.post(Uri.parse((url)), body: body);
    return response;
  }

  static dynamic authenticatedGetRequest(url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    final client = Client();
    final response = await client.get(Uri.parse(url), headers: {
      'refreshToken': refreshToken!,
      'Authorization': 'Bearer $accessToken',
    });
    if (response.statusCode == 403) return logout();
    updateAccessToken(response);
    return response;
  }

  static dynamic authenticatedPostRequest(url, body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    final client = Client();
    final response = await client.post(Uri.parse(url), body: body, headers: {
      'refreshToken': refreshToken!,
      'Authorization': 'Bearer $accessToken',
    });
    if (response.statusCode == 403) return logout();
    updateAccessToken(response);
    return response;
  }

  static dynamic authenticatedDeleteRequest(url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    final client = Client();
    final response = await client.delete(Uri.parse(url), headers: {
      'refreshToken': refreshToken!,
      'Authorization': 'Bearer $accessToken',
    });
    if (response.statusCode == 403) return logout();
    updateAccessToken(response);
    return response;
  }

  static void updateAccessToken(response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (json.decode(response.body)['data']['newAccessToken'] != null)
      prefs.setString(
          'accessToken', json.decode(response.body)['data']['newAccessToken']);
  }

  static dynamic checkIfTokenValid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    final client = Client();
    final response = await client.post(Uri.parse(apiURL + '/test'), headers: {
      'refreshToken': refreshToken!,
      'Authorization': 'Bearer $accessToken',
    });
    if (response.statusCode == 403) return logout();
  }

  static void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    NavigationService.instance.navigateToReplacement(
        MaterialPageRoute(builder: (context) => LandingPage()));
  }
}
