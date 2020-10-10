import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/cart_provider.dart';
import 'package:flutter/foundation.dart';

//  An individual order item containing
//    id, amount, list of products and date-time of purchase
class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> productsList;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.productsList,
    @required this.dateTime,
  });
}

//  Class to store all the orders
class OrdersProvider with ChangeNotifier {
  List<OrderItem> _ordersList = [];

  //  Getter to fetch a copy of the list of orders
  List<OrderItem> get getOrdersList {
    return [..._ordersList];
  }

  //  Method to add a order, using insert at 0 to insert new orders in beginning of list
  //  Using current datetime as string for id
  void addOrder(List<CartItem> productsList, double amount) {
    if (productsList.length <= 0) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
          msg: "Please add items to your cart to place an order",
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }
    _ordersList.insert(
      0,
      OrderItem(
          id: DateTime.now().toString(),
          amount: amount,
          productsList: productsList,
          dateTime: DateTime.now()),
    );
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: "Order placed successfully :)",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER);
    notifyListeners();
  }
}
