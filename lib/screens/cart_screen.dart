import '../screens/payment_screen.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    // final cartData = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("My Cart"),
      ),
      body: FutureBuilder(
        future:
            Provider.of<OrdersProvider>(context, listen: false).reloadOrders(),
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularProgressIndicator(),
                    Text("Please wait"),
                    DelayedDisplay(
                        delay: Duration(seconds: 5),
                        child: Text(
                          "Please connect to internet.\nChanges will be reflected after internet connection is regained",
                          style: TextStyle(fontSize: 7),
                          textAlign: TextAlign.center,
                        ))
                  ],
                ),
              ),
            );
          } else if (dataSnapShot.hasError) {
            return Center(
              child: Text("Something went wrong\n Please try again later."),
            );
          } else {
            //  Using consumer here as if we use provider here, whole stateless widget gets
            //  re-rendered again, and we enter an infinite loop
            return Consumer<CartProvider>(
              builder: (ctx, cartData, child) => Column(
                children: [
                  if (!FirebaseAuth.instance.currentUser.emailVerified)
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text("Please verify email to place order"),
                      color: Theme.of(context).errorColor,
                    ),
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
                          Container(
                            child: Text(
                                "Rs. ${cartData.getTotalCartAmount.toStringAsFixed(0)}"),
                          ),
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
                        productId: cartData.getCardItemsList[index].productId,
                        id: cartData.getCardItemsList[index].id,
                        price: cartData.getCardItemsList[index].pricePerUnit,
                        quantity: cartData.getCardItemsList[index].quantity,
                        title: cartData.getCardItemsList[index].title,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
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
          //  if cart amount is <=0 or placing order or email not verified or any item is more than available, disable button
          (widget.cartData.getTotalCartAmount <= 0 ||
                  _progressBar == true ||
                  !FirebaseAuth.instance.currentUser.emailVerified ||
                  !Provider.of<CartProvider>(context, listen: false)
                      .allItemsValid(context))
              ? null
              : () {
                  Navigator.of(context).pushNamed(PaymentScreen.routeName);
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
