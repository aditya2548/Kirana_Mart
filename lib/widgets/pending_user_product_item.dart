import 'dart:ui';

import '../models/product_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';

import 'package:flutter/material.dart';

//  Pending Product provided by the user to admin for verification
//  Contains an expansionTile with product title, price and product image
//  Upon expansion, we get product description and options to approve or reject the product
class PendingUserProductItem extends StatefulWidget {
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
  final String retailerId;

  PendingUserProductItem({
    this.id,
    this.title,
    this.description,
    this.price,
    this.imageUrl,
    this.productCategory,
    this.retailerId,
  });

  @override
  _PendingUserProductItemState createState() => _PendingUserProductItemState();
}

class _PendingUserProductItemState extends State<PendingUserProductItem> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void sendRejectionReason() {
      String reason = myController.text;
      if (reason.trim() == "") {
        Fluttertoast.cancel();
        Fluttertoast.showToast(
            msg: "Please provide a reason for rejection",
            backgroundColor: Theme.of(context).errorColor,
            fontSize: 12);
        return;
      }
      Provider.of<ProductsProvider>(context, listen: false).declineProduct(
          widget.id, context, reason, widget.retailerId, widget.title);
    }

    return Card(
      elevation: 20,
      margin: EdgeInsets.all(10),
      color: Colors.teal[900],
      child: ExpansionTile(
        trailing: Icon(Icons.arrow_circle_down_outlined),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.imageUrl),
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            widget.title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Text(
          "Price per item: Rs. ${widget.price}",
          // style: TextStyle(fontSize: 10),
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
              Product.productCattoString(widget.productCategory),
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
              widget.description,
              textAlign: TextAlign.center,
            ),
          ),
          Divider(),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter a rejection reason',
            ),
            controller: myController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton.icon(
                  label: Text("Accept"),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Theme.of(context).primaryColorDark,
                  icon: Icon(
                    Icons.done_all,
                  ),
                  onPressed: () {
                    Provider.of<ProductsProvider>(context, listen: false)
                        .approveProduct(widget.id, context);
                  }),
              RaisedButton.icon(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                label: Text("Reject"),
                icon: Icon(Icons.highlight_remove),
                color: Theme.of(context).errorColor,
                onPressed: () {
                  sendRejectionReason();
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
