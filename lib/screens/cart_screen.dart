import '../models/cart_provider.dart';
import '../widgets/my_cart_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  Cart screen to display total price and individual tiles of products
//  with a button to place order
class CartScreen extends StatelessWidget {
  static const routeName = "/cart_screen";

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            elevation: 10,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  stops: [
                    0.01,
                    0.5,
                  ],
                  colors: [
                    Theme.of(context).primaryColorDark,
                    Theme.of(context).primaryColor,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Text(" Total: "),
                  Text("Rs. ${cartData.getTotalCartAmount}"),
                  Spacer(),
                  FlatButton.icon(
                    onPressed: () {},
                    color: Theme.of(context).primaryColor,
                    icon: Icon(Icons.assignment_turned_in),
                    label: Text(
                      "PLACE ORDER",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cartData.getCartItemCount,
              itemBuilder: (ctx, index) => MyCartItem(
                productId: cartData.getCardItemsList.keys.toList()[index],
                id: cartData.getCardItemsList.values.toList()[index].id,
                price: cartData.getCardItemsList.values
                    .toList()[index]
                    .pricePerUnit,
                quantity:
                    cartData.getCardItemsList.values.toList()[index].quantity,
                title: cartData.getCardItemsList.values.toList()[index].title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
