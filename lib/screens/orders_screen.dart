import '../widgets/app_drawer.dart';

import '../widgets/my_orders_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/orders_provider.dart';

//  Screen to show all the user orders, sorted on the basis of time of purchase
class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";
  @override
  Widget build(BuildContext context) {
    final ordersList = Provider.of<OrdersProvider>(context).getOrdersList;
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: ordersList.length,
          itemBuilder: (ctx, index) => MyOrdersItem(ordersList.toList()[index]),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
