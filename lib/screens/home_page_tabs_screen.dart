import '../models/data_model.dart';
import 'package:shimmer/shimmer.dart';

import '../screens/notifications_screen.dart';

import '../widgets/data_search.dart';

import '../dialog/custom_dialog.dart';
import '../models/product_provider.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_core/firebase_core.dart';

import '../widgets/app_drawer.dart';

import '../models/cart_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/products_list_screen.dart';

import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

//  Stateful main widget which then renders two tabs(Home and fav)
class HomePageTabsScreen extends StatefulWidget {
  static const routeName = "/home_page_tabs_screen";
  @override
  _HomePageTabsScreenState createState() => _HomePageTabsScreenState();
}

class _HomePageTabsScreenState extends State<HomePageTabsScreen> {
  //  Variable to determine whether progress bar must be shown or not
  bool _progressBar = true;

  //  Need to initialize firebase in initState, and then fetch user products list in real-time
  //  Show error dialog if any of the steps fail
  @override
  void initState() {
    setState(() {
      _progressBar = true;
    });
    Firebase.initializeApp().catchError((error) {
      CustomDialog.generalErrorDialog(context);
    }).whenComplete(() {
      setState(() {
        _progressBar = false;
      });
      // Provider.of<ProductsProvider>(context, listen: false)
      //     .listenToProductsRealTime()
      //     .then((_) {
      //   setState(() {
      //     _progressBar = false;
      //   });
      // }).catchError((error) {
      //   CustomDialog.generalErrorDialog(context);
      // });
    });
    Provider.of<CartProvider>(context, listen: false).fetchCartItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //  variable and method to get count of fav items to be shown as badge count
    int count;
    setState(() {
      count =
          Provider.of<ProductsProvider>(context).getFavoriteProductItems.length;
    });

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: -5, //  appicon closer to hamburger
            title: Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.amber,
              period: Duration(seconds: 2),
              child: Row(
                children: [
                  SizedBox(
                      height: AppBar().preferredSize.height - 10,
                      width: AppBar().preferredSize.height - 10,
                      child: Image.asset("assets/images/Kirana_mart_logo.png")),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      DataModel.kiranaMartTwoLined,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            //  cart option at top left in appbar
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.notification_important),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(NotificationsScreen.routeName);
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch());
                },
              ),
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
                    style: TextStyle(
                      color: Colors.white,
                      // fontSize: 10,
                    ),
                  ),
                  child: child,
                ),
                child: IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    }),
              ),
              // SizedBox(
              //   width: 10,
              // ),
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
                      DataModel.home,
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
                      DataModel.fav,
                    ),
                    // SizedBox(
                    //   width: 5,
                    // ),
                    // Badge(
                    //   badgeColor: Colors.green,
                    //   animationDuration: Duration(milliseconds: 200),
                    //   animationType: BadgeAnimationType.scale,
                    //   badgeContent: Text(
                    //     count.toString(),
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       // fontSize: 10,
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            ]),
          ),
          body: TabBarView(
            children: [
              //  If progressBar is true, that means products are loading
              //  So ahow a progress bar, else show products list screen
              _progressBar
                  ? Center(
                      child: Container(
                        height: 130,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CircularProgressIndicator(),
                            Text(DataModel.loadingProducts),
                            DelayedDisplay(
                                delay: Duration(seconds: 5),
                                child: Text(
                                  DataModel.connectToInternetWarningForProducts,
                                  style: TextStyle(fontSize: 7),
                                  textAlign: TextAlign.center,
                                ))
                          ],
                        ),
                      ),
                    )
                  : ProductsListScreen(),
              FavoritesScreen(),
            ],
          ),
          drawer: AppDrawer(DataModel.home),
        ),
      ),
    );
  }
}
