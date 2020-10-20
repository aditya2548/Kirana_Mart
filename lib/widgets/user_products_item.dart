import 'dart:ui';

import '../models/product_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../dialog/custom_dialog.dart';

import '../models/product.dart';

import '../screens/edit_user_product_screen.dart';
import 'package:flutter/material.dart';

//  Product provided by the user
//  Contains an expansionTile with product title, price and product image
//  Upon expansion, we get product description and options to edit/delete the product
class UserProductItem extends StatelessWidget {
  @required
  final String id;
  @required
  final String title;
  @required
  final String imageUrl;
  @required
  final double price;
  @required
  final String description;
  @required
  final ProductCategory productCategory;
  @required
  final int quantity;

  UserProductItem({
    this.id,
    this.title,
    this.description,
    this.price,
    this.imageUrl,
    this.productCategory,
    this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    //  Controller for the stock amount
    TextEditingController quantityController = TextEditingController();

    void submitQuantity() {
      //  validate quantity first (non-zero positive integers accepted only)
      String updatedQuantity = quantityController.text;

      if (updatedQuantity == null ||
          updatedQuantity.trim() == "" ||
          int.tryParse(updatedQuantity) == null ||
          int.parse(updatedQuantity) <= 0) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: "Please provide a valid quantity");
        return;
      }
      Provider.of<ProductsProvider>(context, listen: false)
          .addProductQuantity(id, quantity + int.parse(updatedQuantity));
    }

    return Card(
      elevation: 20,
      margin: EdgeInsets.all(10),
      color: quantity <= 0 ? Colors.blueGrey[900] : Colors.teal[900],
      child: ExpansionTile(
        trailing: Icon(Icons.arrow_circle_down_outlined),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            title,
            style: TextStyle(
                color: quantity <= 0 ? Colors.red : Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Text(
          "Price per item: Rs. $price",
          style: TextStyle(fontSize: 10),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              "Product category:",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 15,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              Product.productCattoString(productCategory),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              "Product description:",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 15,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              description,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              children: [
                Text("Stock: $quantity"),
                Spacer(),
                SizedBox(
                  height: 20,
                  width: 70,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: quantityController,
                    onSubmitted: (_) {
                      submitQuantity();
                    },
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                FlatButton.icon(
                  onPressed: () {
                    submitQuantity();
                  },
                  icon: Icon(Icons.add),
                  label: Text("ADD"),
                  color: Colors.green,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton.icon(
                label: Text("Edit"),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Theme.of(context).primaryColorDark,
                icon: Icon(
                  Icons.edit,
                ),
                onPressed: () => Navigator.of(context)
                    //  Id passed so that the next screen knows we're editing a product and not adding one
                    .pushNamed(EditUserProductScreen.routeName, arguments: id),
              ),
              RaisedButton.icon(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                label: Text("Delete"),
                icon: Icon(
                  Icons.delete_forever,
                ),
                color: Theme.of(context).errorColor,
                onPressed: () {
                  CustomDialog.deleteProductDialogWithIdFromMyProducts(
                      id, context);
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
