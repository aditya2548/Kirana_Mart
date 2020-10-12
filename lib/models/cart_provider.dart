import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//  Class for a cart item (CartItem.productId != product.productId)
class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double pricePerUnit;
  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.pricePerUnit,
  });
}

//  Card provider class with a map of key->productId and value->cartItem
class CartProvider with ChangeNotifier {
  Map<String, CartItem> _cardItemsList = {};

  //  getter to return copy of cardItems
  Map<String, CartItem> get getCardItemsList {
    return {..._cardItemsList};
  }

  //  method to add an item to the cart with given quantity with a toast message
  void addItemWithQuantity(
      String productId, double price, String title, int quantity) {
    //  if product already in cart, just change quantity, else add item
    String toastText = "";
    if (_cardItemsList.containsKey(productId)) {
      toastText = "Added $quantity more $title to Cart :)";
      _cardItemsList.update(
        productId,
        (oldItem) => CartItem(
            id: oldItem.id,
            title: oldItem.title,
            quantity: oldItem.quantity + quantity,
            pricePerUnit: oldItem.pricePerUnit),
      );
    } else {
      toastText = "Added $quantity $title to Cart :)";
      _cardItemsList.putIfAbsent(
        productId,
        () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            quantity: quantity,
            pricePerUnit: price),
      );
    }
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: toastText,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green[100],
      textColor: Colors.black,
      fontSize: 16.0,
    );
    notifyListeners();
  }

  //  getter to get the count of total distinct items in cart
  int get getCartItemCount {
    return _cardItemsList.length;
  }

  //  getter to get the total cost of items in the cart
  double get getTotalCartAmount {
    double cost = 0;
    _cardItemsList.forEach((key, value) {
      cost += value.pricePerUnit * value.quantity;
    });
    return cost;
  }

  //  Function to remove item from cart
  void removeItem(String productId) {
    _cardItemsList.remove(productId);
    notifyListeners();
  }

  //  Reduce count of item and if count == 1, remove complete item
  void decreaseItemCount(String productId, int quantity) {
    if (quantity == 1)
      removeItem(productId);
    else {
      _cardItemsList.update(
          productId,
          (value) => CartItem(
              id: productId,
              title: value.title,
              quantity: value.quantity - 1,
              pricePerUnit: value.pricePerUnit));
      notifyListeners();
    }
  }

  //  Method to empty our cart(used after the order is placed)
  void clearCart() {
    _cardItemsList = {};
    notifyListeners();
  }
}
