import '../widgets/custom_app_bar_title.dart';

import '../widgets/chart.dart';
import 'package:delayed_display/delayed_display.dart';

import '../widgets/app_drawer.dart';

import '../widgets/my_orders_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/orders_provider.dart';

//  Screen to show all the user orders, sorted on the basis of time of purchase
//  Instead of using a stateful widget with initState to fetch data and show loading screen,
//  FutureBuilder used with a steteless widget
class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";

  @override
  Widget build(BuildContext context) {
    //  for fetching device size
    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: CustomAppBarTitle(
        name: "My Orders",
        icondata: Icons.request_page,
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: FutureBuilder(
        future:
            Provider.of<OrdersProvider>(context, listen: false).reloadOrders(),
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
            return Consumer<OrdersProvider>(
              builder: (ctx, ordersData, child) => Column(
                children: [
                  Container(
                    height: (mediaQuery.size.height -
                            appBar.preferredSize.height -
                            mediaQuery.padding.top) *
                        0.3,
                    child: Chart(ordersData.getLastWeekOrders),
                  ),
                  Flexible(
                    child: RefreshIndicator(
                      onRefresh: () {
                        return Provider.of<OrdersProvider>(context,
                                listen: false)
                            .reloadOrders();
                      },
                      child: ListView.builder(
                        itemCount: ordersData.getOrdersList.length,
                        itemBuilder: (ctx, index) => MyOrdersItem(
                            ordersData.getOrdersList.toList()[index]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      drawer: AppDrawer("My Orders"),
    );
  }
}
