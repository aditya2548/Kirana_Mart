import '../screens/favorites_screen.dart';
import '../screens/products_list_screen.dart';
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
            bottom: TabBar(tabs: <Widget>[
              Tab(
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_rounded),
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
                    Text(
                      "Fav",
                    )
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
