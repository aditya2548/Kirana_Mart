import 'package:Kirana_Mart/screens/cart_screen.dart';
import 'package:Kirana_Mart/screens/user_products_screen.dart';

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
          Divider(
            thickness: 2,
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag_rounded),
            title: Text("Home"),
            onTap: () {
              checkAndPush("Home", "/");
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
        ],
      ),
    );
  }
}
