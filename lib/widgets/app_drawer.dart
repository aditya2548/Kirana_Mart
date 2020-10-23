import '../models/data_model.dart';
import '../screens/notifications_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/admin_screen.dart';
import '../screens/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/cart_screen.dart';
import '../screens/user_products_screen.dart';

import '../screens/orders_screen.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  //  Name of the page from where we opened the app drawer
  final String parentName;
  AppDrawer(this.parentName);

  @override
  Widget build(BuildContext context) {
    //  Function to go to the desired page, if not there already
    void checkAndPush(String name, String routeName) {
      if (parentName == name) {
        Navigator.of(context).pop();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Already in $name",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            backgroundColor: Theme.of(context).primaryColorDark,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(routeName);
      }
    }

    return Drawer(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(
                5, MediaQuery.of(context).padding.top + 5, 5, 2),
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            height: 50,
            child: Center(
              child: Text(
                "HELLO, FRIEND",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          //  If email isn't verified, show a red container on app bar
          if (FirebaseAuth.instance.currentUser.emailVerified == false)
            Container(
              margin: EdgeInsets.fromLTRB(5, 5, 5, 2),
              width: double.infinity,
              color: Theme.of(context).errorColor,
              height: 50,
              child: Text(
                "Email isn't verified.\nVerify to unlock features",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Divider(
            thickness: 2,
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              checkAndPush("Home", "/home_page_tabs_screen");
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: Icon(Icons.request_page),
            title: Text("My Orders"),
            onTap: () {
              checkAndPush("My Orders", OrdersScreen.routeName);
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag_rounded),
            title: Text("My Cart"),
            onTap: () {
              checkAndPush("My Cart", CartScreen.routeName);
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text("My Products"),
            onTap: () {
              checkAndPush("My Products", UserProductsScreen.routeName);
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text("My Profile"),
            onTap: () {
              checkAndPush("My Profile", UserProfileScreen.routeName);
            },
          ),
          Divider(
            thickness: 1,
          ),
          if (FirebaseAuth.instance.currentUser.email == DataModel.adminEmail)
            ListTile(
              leading: Icon(Icons.done_all),
              title: Text("Approve Products"),
              onTap: () {
                checkAndPush("Approve Products", AdminScreen.routeName);
              },
            ),
          if (FirebaseAuth.instance.currentUser.email == DataModel.adminEmail)
            Divider(
              thickness: 1,
            ),
          ListTile(
            leading: Icon(Icons.mail),
            title: Text("Contact Us"),
            onTap: () async {
              var url =
                  "mailto:kirana.mart.grocery@gmail.com?subject=Kirana Mart Query&body=Please provide details regarding your problem.\nWe will contact you shortly.";
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                Fluttertoast.showToast(
                    msg: "Sorry for the inconvenience\nPlease try again later");
              }
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: Icon(Icons.notification_important),
            title: Text("My notifications"),
            onTap: () {
              checkAndPush("My notifications", NotificationsScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
