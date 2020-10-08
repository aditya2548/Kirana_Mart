import '../models/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  A single item present in mycart
class MyCartItem extends StatelessWidget {
  @required
  final String productId;
  @required
  final String id;
  @required
  final String title;
  @required
  final double price;
  @required
  final int quantity;

  MyCartItem({this.productId, this.id, this.title, this.price, this.quantity});

  @override
  Widget build(BuildContext context) {
    //  Alert dialog that returns Future<true> if we click on delete
    Future<bool> confirmDelete() async {
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

    //  return dismissable so that we can swipe right and delete item completely
    //  or we also have + and - buttons to increase and decrease count
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        margin: EdgeInsets.all(10),
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete_forever,
          size: 30,
        ),
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (dir) => confirmDelete(),
      direction: DismissDirection.endToStart,
      child: Card(
        elevation: 20,
        margin: EdgeInsets.all(10),
        color: Colors.teal[900],
        child: ExpansionTile(
          trailing: Icon(Icons.arrow_circle_down_outlined),
          tilePadding: EdgeInsets.all(5),
          leading: Container(
            margin: EdgeInsets.all(5),
            decoration:
                BoxDecoration(color: Colors.teal, border: Border.all(width: 1)),
            padding: EdgeInsets.all(10),
            child: Text(
              "Rs. ${price * quantity}",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              title,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(
            "Price per item: Rs. $price ",
            style: TextStyle(fontSize: 10),
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Quantity:",
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.add_circle_outline_sharp,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false)
                            .addItemWithQuantity(productId, price, title, 1);
                      }),
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2), color: Colors.white),
                      child: Text(
                        "$quantity",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      )),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      if (quantity == 1)
                        confirmDelete();
                      else
                        Provider.of<CartProvider>(context, listen: false)
                            .decreaseItemCount(productId, quantity);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
