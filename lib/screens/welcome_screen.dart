import '../models/data_model.dart';
import 'package:shimmer/shimmer.dart';

import '../screens/signup_screen.dart';

import 'package:flutter/material.dart';

//  Welcome screen if user isn't authenticated to take user to signup screen
class WelcomeScreen extends StatelessWidget {
  static const routeName = "/welcome_screen";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.red,
              highlightColor: Colors.orange,
              period: Duration(seconds: 2),
              child: Image.asset(
                "assets/images/logo_transparent.png",
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 1),
              child: Shimmer.fromColors(
                baseColor: Colors.red,
                highlightColor: Colors.orange,
                period: Duration(seconds: 2),
                child: Text(
                  DataModel.WELCOME_TO_KIRANA_MART,
                  style: TextStyle(
                      color: Colors.orange[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
            Text(
              DataModel.APP_TAGLINE,
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
                    // mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Spacer(),
                      Text(
                        DataModel.GET_STARTED,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
