import 'package:Kirana_Mart/screens/cart_screen.dart';

import '../screens/orders_screen.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 30),
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            height: 30,
            child: Text("Hello user"),
          ),
          Divider(
            thickness: 2,
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag_rounded),
            title: Text("Home"),
            onTap: () {
              Navigator.of(context).pushNamed('/');
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: Icon(Icons.request_page),
            title: Text("My Orders"),
            onTap: () {
              Navigator.of(context).pushNamed(OrdersScreen.routeName);
            },
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag_rounded),
            title: Text("My Cart"),
            onTap: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
