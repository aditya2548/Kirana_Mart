import 'dart:math';
import 'dart:ui';

import '../models/data_model.dart';

import '../dialog/custom_dialog.dart';
import '../models/cart_provider.dart';
import '../models/key_data_model.dart';
import '../models/orders_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:upi_pay/upi_pay.dart';

//  Screen to show the available payment options (UPI and cash on delivery)
class PaymentScreen extends StatefulWidget {
  static const routeName = '/temp';

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  //  Amount to be paid
  String amount;
  //  upi address of kiranamart
  String upiAddress = KeyDataModel.adminUpi;

  Future<List<ApplicationMeta>> _appsFuture;

  Widget _myAnimatedWidget;
  bool _switch;
  CartProvider cartData;
  bool _progressBar;

  @override
  void initState() {
    super.initState();
    _appsFuture = UpiPay.getInstalledUpiApplications();
    _myAnimatedWidget = Container(
      height: 300,
      alignment: Alignment.center,
      key: Key(DataModel.cod),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton.icon(
              onPressed: () {
                codPayment();
              },
              icon: Icon(Icons.monetization_on),
              label: Text(DataModel.confirmPurchase),
            ),
          ),
        ],
      ),
    );
    _switch = false;
    cartData = Provider.of<CartProvider>(context, listen: false);
    _progressBar = false;
    amount = cartData.getTotalCartAmount.toString();
  }

  //  Method to pay using upi
  //  Method successfully places order on cash on delivery and if payment was successful in case of UPI
  //  In case of COD -> The seller is notified of the purchase
  //  In case of UPI -> admin receives cash and the notification to pay the respective retailers
  //  Also the transaction data of upi is stored inside the user data
  Future<UpiTransactionResponse> _upiPayment(ApplicationMeta app) async {
    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");
    UpiTransactionResponse response;
    try {
      response = await UpiPay.initiateTransaction(
        amount: amount,
        app: app.upiApplication,
        receiverName: 'Kirana Mart',
        receiverUpiAddress: upiAddress,
        transactionRef: transactionRef,
      );
    } catch (error) {
      Fluttertoast.showToast(msg: DataModel.somethingWentWrong);
    } finally {
      //  Save transaction details and send payment details notification to admin, only if transaction was successful
      if (response.status != UpiTransactionStatus.failure) {
        await FirebaseFirestore.instance
            .collection("User")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("MyPayments")
            .add({
          "approvalRefNo": response.approvalRefNo,
          "rawResponse": response.rawResponse,
          "responseCode": response.responseCode,
          "status": response.status.toString(),
          "txnId": response.txnId,
          "txnRef": response.txnRef,
        });
        //  add order with bool upi set to true
        await Provider.of<OrdersProvider>(context, listen: false).addOrder(
          cartData.getCardItemsList,
          cartData.getTotalCartAmount,
          context,
          true,
        );
        //  Clear cart after placing order
        cartData.clearCart();
        Future.delayed(Duration(seconds: 2), () => Navigator.of(context).pop());
      }
    }
    return response;
  }

  void codPayment() async {
    //  Change widget state to loading spinner
    setState(() {
      _progressBar = true;
    });
    //  listen->false as no need to listen to changes in orders data over here
    try {
      await Provider.of<OrdersProvider>(context, listen: false).addOrder(
          cartData.getCardItemsList,
          cartData.getTotalCartAmount,
          context,
          false);
      //  Change widget state back to button
      setState(() {
        _progressBar = false;
      });
      //  Clear cart after placing order
      cartData.clearCart();
      Future.delayed(
          Duration(
            seconds: 2,
          ),
          () => Navigator.of(context).pop());
    } catch (error) {
      await CustomDialog.generalErrorDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    //  Widget for cash on delivery payment
    Widget _codWidget = Container(
      height: 300,
      alignment: Alignment.center,
      key: Key(DataModel.cod),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton.icon(
                onPressed: () {
                  codPayment();
                },
                icon: Icon(Icons.monetization_on),
                label: Text(DataModel.confirmPurchase),
              )),
        ],
      ),
    );
    //  Widget for upi payment
    Widget _upiWidget = Container(
      key: Key(DataModel.upi),
      child: FutureBuilder<List<ApplicationMeta>>(
        future: _appsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container();
          }
          return Container(
            height: 300,
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Spacer(),
                if (snapshot.data.length == 0) Text(DataModel.noUpiAppError),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  childAspectRatio: 1,
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data
                      .map(
                        (it) => Container(
                          height: 20,
                          width: 20,
                          key: ObjectKey(it.upiApplication),
                          child: IconButton(
                            onPressed: () async {
                              await _upiPayment(it);
                            },
                            icon: Image.memory(
                              it.icon,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                Spacer(),
              ],
            ),
          );
        },
      ),
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(DataModel.payment),
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        body: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.all(20),
          elevation: 15,
          color: Theme.of(context).primaryColor,
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 45),
                padding: EdgeInsets.all(20),
                color: Theme.of(context).primaryColorDark,
                alignment: Alignment.center,
                child: Text(
                  "Total amount: $amount",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              if (_progressBar) LinearProgressIndicator(),
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DataModel.cash),
                    Switch(
                      value: _switch,
                      onChanged: (value) {
                        if (value == false) {
                          setState(() {
                            _switch = value;
                            _myAnimatedWidget = _codWidget;
                          });
                        } else {
                          setState(() {
                            _switch = value;
                            _myAnimatedWidget = _upiWidget;
                          });
                        }
                      },
                    ),
                    Text(DataModel.upi),
                  ],
                ),
              ),
              //  aminmated switcher for transition between upi and cod
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(child: child, scale: animation),
                child: _myAnimatedWidget,
              )
            ],
          ),
        ),
      ),
    );
  }
}
