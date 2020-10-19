import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  //  Method to add a order,
  //  Using current datetime converted to Iso8601String for easy retreival
  //  Document containing totalAmount, date, collection of cartitems

  Future<void> addOrder(List<CartItem> productsList, double amount) async {
    print("add order");
    try {
      final CollectionReference c = FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("MyOrders");
      var docRef = await c.add(
        {
          "amount": amount,
          "dateTime": DateTime.now().toIso8601String(),
        },
      );

      productsList.forEach((element) {
        c.doc(docRef.id).collection("productsList").add(
          {
            "id": element.id,
            "title": element.title,
            "quantity": element.quantity,
            "pricePerUnit": element.pricePerUnit,
            "productId": element.productId,
          },
        );
      });
    }
    //  throw the error to the screen/widget using the method
    catch (error) {
      throw error;
    }

    // _ordersList.insert(
    //   0,
    //   OrderItem(
    //       id: DateTime.now().toString(),
    //       amount: amount,
    //       productsList: productsList,
    //       dateTime: DateTime.now()),
    // );
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: "Order placed successfully :)",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER);
    // notifyListeners();
  }

  //  Function to reload orders from firestore and storing fetched orders to our list of orders
  //  Used for pull down to refresh and when orders screen is opened
  Future<void> reloadOrders() async {
    try {
      final CollectionReference c = FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("MyOrders");

      final value = await c.get();
      final List<OrderItem> _fetchedOrders = [];
      value.docs.forEach(
        (element) {
          List<CartItem> _fetchedCartItems = [];
          c.doc(element.id).collection("productsList").get().then(
            (value) {
              value.docs.forEach((element) {
                _fetchedCartItems.add(
                  CartItem(
                    id: element.data()["id"],
                    title: element.data()["title"],
                    quantity: element.data()["quantity"],
                    pricePerUnit: element.data()["pricePerUnit"],
                    productId: element.data()["productId"],
                  ),
                );
              });
            },
          ).then(
            (value) {
              _fetchedOrders.add(
                OrderItem(
                  id: element.id,
                  amount: element.data()["amount"],
                  dateTime: DateTime.parse(element.data()["dateTime"]),
                  productsList: _fetchedCartItems,
                ),
              );
              _ordersList = _fetchedOrders;
              //  Sorting the orders so that the ost recent order appears first
              _ordersList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
              notifyListeners();
            },
          );
        },
      );
    } catch (error) {
      throw error;
    }
  }

  //  Function to get last 7 days orders, used to create the chart
  List<OrderItem> get getLastWeekOrders {
    return _ordersList
        .where(
          (element) => element.dateTime.isAfter(
            DateTime.now().subtract(
              Duration(days: 7),
            ),
          ),
        )
        .toList();
  }
}
