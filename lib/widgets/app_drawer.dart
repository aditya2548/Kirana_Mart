import '../screens/home_page_tabs_screen.dart';
import '../models/data_model.dart';
import '../screens/pending_payments_admin_screen.dart';

import '../models/key_data_model.dart';
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
      } else if (parentName != DataModel.home) {
        //  Two times so that all the screens do not get stacked up on top of each other
        //  Only the home screen remains always at the bottom while using drawer
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(routeName);
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(routeName);
      }
    }

    return Drawer(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            color: Colors.black,
          ),
          Container(
            height: double.maxFinite,
            width: 251.5,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          Container(
            height: double.maxFinite,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey[900],
            ),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.black, width: 4)),
                  color: Theme.of(context).primaryColor,
                ),
                height: 50,
                child: Center(
                  child: Text(
                    DataModel.helloFriend,
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
                    DataModel.verifyEmailToUnlockFeatures,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text(DataModel.home),
                onTap: () {
                  checkAndPush(DataModel.home, HomePageTabsScreen.routeName);
                },
              ),
              Divider(
                thickness: 1,
                endIndent: 15,
                indent: 15,
              ),
              ListTile(
                leading: Icon(Icons.request_page),
                title: Text(DataModel.myOrders),
                onTap: () {
                  checkAndPush(DataModel.myOrders, OrdersScreen.routeName);
                },
              ),
              Divider(
                thickness: 1,
                endIndent: 15,
                indent: 15,
              ),
              ListTile(
                leading: Icon(Icons.shopping_bag_rounded),
                title: Text(DataModel.myCart),
                onTap: () {
                  checkAndPush(DataModel.myCart, CartScreen.routeName);
                },
              ),
              Divider(
                thickness: 1,
                endIndent: 15,
                indent: 15,
              ),
              ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text(DataModel.myProducts),
                onTap: () {
                  checkAndPush(
                      DataModel.myProducts, UserProductsScreen.routeName);
                },
              ),
              Divider(
                thickness: 1,
                endIndent: 15,
                indent: 15,
              ),
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text(DataModel.myProfile),
                onTap: () {
                  checkAndPush(
                      DataModel.myProfile, UserProfileScreen.routeName);
                },
              ),
              Divider(
                thickness: 1,
                endIndent: 15,
                indent: 15,
              ),
              if (FirebaseAuth.instance.currentUser.email ==
                  KeyDataModel.adminEmail)
                ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text(DataModel.APPROVE_PRODUCTS),
                  onTap: () {
                    checkAndPush(
                        DataModel.APPROVE_PRODUCTS, AdminScreen.routeName);
                  },
                ),
              if (FirebaseAuth.instance.currentUser.email ==
                  KeyDataModel.adminEmail)
                Divider(
                  thickness: 1,
                  endIndent: 15,
                  indent: 15,
                ),
              if (FirebaseAuth.instance.currentUser.email ==
                  KeyDataModel.adminEmail)
                ListTile(
                  leading: Icon(Icons.timelapse),
                  title: Text(DataModel.pendingPayments),
                  onTap: () {
                    checkAndPush(DataModel.pendingPayments,
                        PendingPaymentsAdminScreen.routeName);
                  },
                ),
              if (FirebaseAuth.instance.currentUser.email ==
                  KeyDataModel.adminEmail)
                Divider(
                  thickness: 1,
                  endIndent: 15,
                  indent: 15,
                ),
              ListTile(
                leading: Icon(Icons.notification_important),
                title: Text(DataModel.myNotifications),
                onTap: () {
                  checkAndPush(
                      DataModel.myNotifications, NotificationsScreen.routeName);
                },
              ),

              Divider(
                thickness: 1,
                endIndent: 15,
                indent: 15,
              ),
              ListTile(
                leading: Icon(Icons.mail),
                title: Text(DataModel.contactUs),
                onTap: () async {
                  var url =
                      "mailto:kirana.mart.grocery@gmail.com?subject=Kirana Mart Query&body=Please provide details regarding your problem.\nWe will contact you shortly.";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    Fluttertoast.showToast(msg: DataModel.somethingWentWrong);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
