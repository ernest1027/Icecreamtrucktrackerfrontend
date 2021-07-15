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
