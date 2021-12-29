import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  String text;
  Function callback;
  LoginButton(this.text, this.callback) {}

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: Color(0xFFD77FA1),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: Colors.white,
              textStyle: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              this.callback();
            },
            child: Text(
              this.text,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
