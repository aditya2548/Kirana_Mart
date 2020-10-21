import '../screens/signup_screen.dart';

import 'package:flutter/material.dart';

//  Welcome screen if user isn't authenticated to take user to signup screen
class WelcomeScreen extends StatelessWidget {
  static const routeName = "/welcome_screen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/logo_transparent.png",
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 1),
            child: Text(
              "WELCOME TO KIRANA MART",
              style: TextStyle(
                  color: Colors.orange[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
          Text(
            "~~ Your one stop smart shopping resource ~~",
            style: TextStyle(
                color: Colors.teal[100],
                fontStyle: FontStyle.italic,
                fontSize: 11),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(60, 60, 60, 20),
            child: RaisedButton(
                color: Theme.of(context).primaryColor,
                highlightColor: Colors.deepOrange[900],
                elevation: 10,
                padding: EdgeInsets.all(10),
                onPressed: () {
                  Navigator.of(context).pushNamed(SignUpScreen.routeName);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Get Started",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    Icon(Icons.arrow_forward_ios)
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
