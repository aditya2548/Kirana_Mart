import 'dart:ui';

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

  UserProductItem({
    this.id,
    this.title,
    this.description,
    this.price,
    this.imageUrl,
    this.productCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 20,
      margin: EdgeInsets.all(10),
      color: Colors.teal[900],
      child: ExpansionTile(
        trailing: Icon(Icons.arrow_circle_down_outlined),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.only(bottom: 20),
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
