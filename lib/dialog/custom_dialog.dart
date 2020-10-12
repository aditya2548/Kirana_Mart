import '../models/cart_provider.dart';

import '../models/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  Class to store all the custom error-dialog to reduce boilerplate code
class CustomDialog {
  //  General error dialog if anything goes wrong
  static Future<void> generalErrorDialog(BuildContext context) {
    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Something went wrong"),
        content: Text("Please try again later"),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OKAY"),
          )
        ],
      ),
    );
  }

  //  Alert dialog that returns Future<true> if we click on delete and deletes product
  // with given id  *FROM MY PRODUCTS LIST*
  static Future<bool> deleteProductDialogWithIdFromMyProducts(
    String id,
    BuildContext context,
  ) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you wish to delete this product?"),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Provider.of<ProductsProvider>(context, listen: false)
                      .deleteProduct(id);
                  Navigator.of(context).pop(true);
                },
                child: const Text("DELETE")),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }

  //  Alert dialog that returns Future<true> if we click on delete
  //  And *DELETES PRODUCT FROM CART*
  static Future<bool> deleteProductDialogWithIdFromCart(
      String productId, BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you wish to delete this item?"),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false)
                      .removeItem(productId);
                  Navigator.of(context).pop(true);
                },
                child: const Text("DELETE")),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }
}
