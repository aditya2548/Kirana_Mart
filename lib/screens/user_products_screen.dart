import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/edit_user_product_screen.dart';

import '../widgets/app_drawer.dart';

import '../models/product_provider.dart';
import '../widgets/user_products_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  Contains a list of all the products provided by the user
//  Instead of using a stateful widget with initState to fetch data and show loading screen,
//  FutureBuilder used with a steteless widget
class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user_products_screen";
  @override
  Widget build(BuildContext context) {
    //  Don't allow adding products if email is not verified
    if (!FirebaseAuth.instance.currentUser.emailVerified) {
      return Scaffold(
        body: Center(
          child: Container(
            child: Text(
              "Please verify email to\nstart selling products",
              style: TextStyle(color: Theme.of(context).errorColor),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("My products"),
        actions: [
          IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                    msg:
                        "New products and modifications are visible after approval by admin",
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Theme.of(context).accentColor,
                    toastLength: Toast.LENGTH_LONG);
              }),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context)
                .pushNamed(EditUserProductScreen.routeName),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () =>
            Navigator.of(context).pushNamed(EditUserProductScreen.routeName),
      ),
      //  RefreshIndicator to re-fetch the products list
      body: FutureBuilder(
        future: Provider.of<ProductsProvider>(context, listen: false)
            .reloadProducts(),
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularProgressIndicator(),
                    Text("Please wait"),
                    DelayedDisplay(
                        delay: Duration(seconds: 5),
                        child: Text(
                          "Please connect to internet.\nChanges will be reflected after internet connection is regained",
                          style: TextStyle(fontSize: 7),
                          textAlign: TextAlign.center,
                        ))
                  ],
                ),
              ),
            );
          } else if (dataSnapShot.hasError) {
            return Center(
              child: Text("Something went wrong\n Please try again later."),
            );
          } else {
            //  Using consumer here as if we use provider here, whole stateless widget gets
            //  re-rendered again, and we enter an infinite loop
            return Consumer<ProductsProvider>(
              builder: (ctx, ordersData, child) => RefreshIndicator(
                onRefresh: () {
                  return Provider.of<ProductsProvider>(context, listen: false)
                      .reloadProducts();
                },
                child: ListView.builder(
                  itemCount: ordersData.getMyProducts().length,
                  itemBuilder: (ctx, index) => UserProductItem(
                    id: ordersData.getMyProducts()[index].id,
                    title: ordersData.getMyProducts()[index].title,
                    description: ordersData.getMyProducts()[index].description,
                    imageUrl: ordersData.getMyProducts()[index].imageUrl,
                    price: ordersData.getMyProducts()[index].price,
                    productCategory:
                        ordersData.getMyProducts()[index].productCategory,
                  ),
                ),
              ),
            );
          }
        },
      ),
      drawer: AppDrawer("My Products"),
    );
  }
}
