import '../dialog/custom_dialog.dart';

import '../models/cart_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/my_cart_item.dart';
import '../models/orders_provider.dart';
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
        title: Text("My Cart"),
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
                  Text("Rs. ${cartData.getTotalCartAmount.toStringAsFixed(2)}"),
                  Spacer(),
                  OrderButton(cartData: cartData),
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
      drawer: AppDrawer("My Cart"),
    );
  }
}

//  Order Button extracted as a widget outside as it will bw stateful
//  Button converts to loading spinner when placing order
class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cartData,
  }) : super(key: key);

  final CartProvider cartData;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _progressBar = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      onPressed:
          //  if cart amount is <=0 or placing order, disable button
          (widget.cartData.getTotalCartAmount <= 0 || _progressBar == true)
              ? null
              : () async {
                  //  Change widget state to loading spinner
                  setState(() {
                    _progressBar = true;
                  });
                  //  listen->false as no need to listen to changes in orders data over here
                  try {
                    await Provider.of<OrdersProvider>(context, listen: false)
                        .addOrder(
                      widget.cartData.getCardItemsList.values.toList(),
                      widget.cartData.getTotalCartAmount,
                    );
                  } catch (error) {
                    await CustomDialog.generalErrorDialog(context);
                  }
                  //  Change widget state back to button
                  setState(() {
                    _progressBar = false;
                  });
                  //  Clear cart after placing order
                  widget.cartData.clearCart();
                },
      color: Theme.of(context).primaryColor,
      icon: Icon(Icons.assignment_turned_in),
      label: _progressBar == true
          ? CircularProgressIndicator()
          : Text(
              "PLACE ORDER",
              style: TextStyle(fontSize: 12),
            ),
    );
  }
}
