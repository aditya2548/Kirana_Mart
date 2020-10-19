import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//  Class for a cart item (CartItem.productId != product.productId)
class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double pricePerUnit;
  final String productId;
  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.pricePerUnit,
    @required this.productId,
  });
}

//  Card provider class with a map of key->productId and value->cartItem
class CartProvider with ChangeNotifier {
  List<CartItem> _cardItemsList = [];

  //  getter to return copy of cardItems
  List<CartItem> get getCardItemsList {
    return [..._cardItemsList];
  }

  //  Function to listen to snapshot for any changes in cart data
  Future<void> fetchCartItems() async {
    final CollectionReference collectionReference = FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("MyCart");

    final List<CartItem> _fetchedCartItems = [];
    try {
      collectionReference.snapshots().listen((event) {
        if (event.docChanges == null) {
          return;
        }
        event.docChanges.forEach((element) {
          if (element.type == DocumentChangeType.added) {
            print("add");
            _fetchedCartItems.add(
              CartItem(
                id: element.doc.data()["id"],
                title: element.doc.data()["title"],
                pricePerUnit: element.doc.data()["pricePerUnit"],
                quantity: element.doc.data()["quantity"],
                productId: element.doc.id,
              ),
            );
          } else if (element.type == DocumentChangeType.modified) {
            final modifyIndex = _fetchedCartItems
                .indexWhere((el) => el.productId == element.doc.id);
            _fetchedCartItems[modifyIndex] = CartItem(
              id: element.doc.data()["id"],
              title: element.doc.data()["title"],
              pricePerUnit: element.doc.data()["pricePerUnit"],
              quantity: element.doc.data()["quantity"],
              productId: element.doc.id,
            );
          } else if (element.type == DocumentChangeType.removed) {
            _fetchedCartItems
                .removeWhere((el) => el.productId == element.doc.id);
          }
          print(_fetchedCartItems.length);
          _cardItemsList = _fetchedCartItems;
          notifyListeners();
        });
      });
    } catch (error) {
      throw error;
    }
  }

  //  method to add an item to the cart with given quantity with a toast message
  Future<void> addItemWithQuantity(
      String productId, double price, String title, int quantity) async {
    //  if product already in cart, just change quantity, else add item
    String toastText = "";
    // if (_cardItemsList.containsKey(productId)) {
    try {
      final DocumentReference documentReference = FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("MyCart")
          .doc(productId);
      documentReference.get().then((value) {
        if (value.exists) {
          toastText = "Added $quantity more $title to Cart :)";
          documentReference.update(
            {
              "quantity": FieldValue.increment(quantity),
            },
          );
        } else {
          toastText = "Added $quantity $title to Cart :)";
          documentReference.set({
            "id": DateTime.now().toIso8601String(),
            "pricePerUnit": price,
            "title": title,
            "quantity": quantity,
          });
        }
      }).then((value) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          msg: toastText,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green[100],
          textColor: Colors.black,
          fontSize: 12.0,
        );
        notifyListeners();
      });
    }
    //  throw the error to the screen/widget using the method
    catch (error) {
      throw error;
    }
  }

  //  getter to get the count of total distinct items in cart
  int get getCartItemCount {
    return _cardItemsList.length;
  }

  //  getter to get the total cost of items in the cart
  double get getTotalCartAmount {
    double cost = 0;
    if (_cardItemsList != null)
      _cardItemsList.forEach((value) {
        cost += value.pricePerUnit * value.quantity;
      });
    return cost;
  }

  //  Function to remove item from cart
  void removeItem(String productId) {
    try {
      final DocumentReference documentReference = FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("MyCart")
          .doc(productId);
      documentReference.delete();
    } catch (error) {
      throw error;
    }
  }

  //  Reduce count of item and if count == 1, remove complete item
  void decreaseItemCount(String productId, int quantity) {
    if (quantity == 1)
      removeItem(productId);
    else {
      try {
        final DocumentReference documentReference = FirebaseFirestore.instance
            .collection("User")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("MyCart")
            .doc(productId);
        documentReference.update(
          {
            "quantity": FieldValue.increment(-1),
          },
        );
      } catch (error) {
        throw error;
      }
    }
  }

  //  Method to empty our cart(used after the order is placed) from firestore collection
  void clearCart() {
    try {
      final CollectionReference collectionReference = FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("MyCart");

      collectionReference.get().then((value) {
        for (DocumentSnapshot ds in value.docs) {
          ds.reference.delete();
        }
      });
    } catch (error) {
      throw error;
    }
  }
}
