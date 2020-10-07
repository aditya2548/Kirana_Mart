import '../models/cart_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/products_list_screen.dart';

import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

//  Stateful main widget which then renders two tabs(Home and fav)
class HomePageTabsScreen extends StatefulWidget {
  @override
  _HomePageTabsScreenState createState() => _HomePageTabsScreenState();
}

class _HomePageTabsScreenState extends State<HomePageTabsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Kirana Mart",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            //  cart option at top left in appbar
            actions: <Widget>[
              //  Used consumer instead of provider as we don't need to update the whole widget
              //  We just need to update our badge count when an item is added to cart
              //  Also, we set the cart image as child in the Consumer so that we can access it
              //  without rebuilding every time
              Consumer<CartProvider>(
                builder: (ctx, cartData, child) => Badge(
                  position: BadgePosition.topEnd(top: 0, end: 2),
                  animationDuration: Duration(milliseconds: 200),
                  animationType: BadgeAnimationType.scale,
                  badgeContent: Text(
                    "${cartData.getCartItemCount}",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: child,
                ),
                child: IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    }),
              ),
              SizedBox(
                width: 10,
              ),
            ],
            bottom: TabBar(tabs: <Widget>[
              Tab(
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_filled),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Home",
                    )
                  ],
                ),
              ),
              Tab(
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_rounded),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Fav",
                    ),
                  ],
                ),
              ),
            ]),
          ),
          body: TabBarView(
            children: [
              ProductsListScreen(),
              FavoritesScreen(),
            ],
          ),
        ));
  }
}
