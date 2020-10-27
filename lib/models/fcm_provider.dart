import 'dart:async';
import 'dart:convert';

import '../models/data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

//  Provider for all the noifications
class FcmProvider with ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<Message> _messages = [];

  List<Message> get getMessages {
    return [..._messages];
  }

  //  Function to fetch all the notifications of a user (latest first)
  Future<void> reloadMessages() async {
    var _fetchedMessages = List<Message>();
    FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("MyMessages")
        .orderBy("dateTime", descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        _fetchedMessages.add(
          Message(
            title: element.data()["title"],
            body: element.data()["body"],
            dateTime: DateTime.parse(
              element.data()["dateTime"],
            ),
            error: element.data()["error"],
          ),
        );
      });
      _messages = _fetchedMessages;
      notifyListeners();
    });
  }

  //  Initialization for FCM
  Future initialize() async {
    print("INITIALIZED");
    //  Initialization for Ios
    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    _firebaseMessaging.subscribeToTopic("all");

    _firebaseMessaging.configure(
      //  called when app is in foreground and we receive push notification
      //  no notification shown by default, so we show a toast
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage : $message");
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          backgroundColor: Colors.yellow[700],
          textColor: Colors.black,
          msg: message["notification"]["title"],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      },
      //  called when app has been closed completely and it's opened from push notification
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch : $message");
      },
      //  called when app is in the background and it's opened from the push notification
      onResume: (Map<String, dynamic> message) async {
        print("onResume : $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
      ),
    );
  }

  //  Send message to retailer when their product was accepted & save message to firestore
  Future sendProductAcceptedMessage(
      String retailerId, String productTitle) async {
    String title = "Congratulations, product added";
    String body = "$productTitle was successfully added to our store";
    var collectionSnapshot = await FirebaseFirestore.instance
        .collection("User")
        .doc(retailerId)
        .collection("MyData")
        .get();
    String token = collectionSnapshot.docs.first.data()["fcmToken"];
    print(token);
    await sendMessage(token, title, body);
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(retailerId)
        .collection("MyMessages")
        .add({
      "title": title,
      "body": body,
      "dateTime": DateTime.now().toIso8601String(),
      "error": false,
    });
  }

  //  Send message to retailer when their product modifications were accepted & save message to firestore
  Future sendProductModifiedMessage(
      String retailerId, String productTitle) async {
    String title = "Congratulations, product modified";
    String body =
        "Details of $productTitle were successfully modified in our store";
    var collectionSnapshot = await FirebaseFirestore.instance
        .collection("User")
        .doc(retailerId)
        .collection("MyData")
        .get();
    String token = collectionSnapshot.docs.first.data()["fcmToken"];
    await sendMessage(token, title, body);
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(retailerId)
        .collection("MyMessages")
        .add({
      "title": title,
      "body": body,
      "dateTime": DateTime.now().toIso8601String(),
      "error": false,
    });
  }

//  Send message to retailer when their product modifications/ submisson was rejected
  Future sendProductRejectionReason(
      String retailerId, String productTitle, String reason) async {
    String title = "Sorry, $productTitle was rejected";
    String body = "Your product was not accepted because: $reason";
    var collectionSnapshot = await FirebaseFirestore.instance
        .collection("User")
        .doc(retailerId)
        .collection("MyData")
        .get();
    String token = collectionSnapshot.docs.first.data()["fcmToken"];
    await sendMessage(token, title, body);
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(retailerId)
        .collection("MyMessages")
        .add({
      "title": title,
      "body": body,
      "dateTime": DateTime.now().toIso8601String(),
      "error": true,
    });
  }

  //  Message to be sent to admin in case someone updates/adds a product
  Future<void> sendMessageToAdmin(String productTitle) async {
    String title = "You have a new product to approve";
    String body = "A retailer added $productTitle for review";
    String token;
    String adminId;
    await FirebaseFirestore.instance
        .collection("Admin")
        .doc(DataModel.adminEmail)
        .get()
        .then((value) {
      token = value.data()["fcmToken"];
      adminId = value.data()["adminId"];
    });
    await sendMessage(token, title, body);
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(adminId)
        .collection("MyMessages")
        .add({
      "title": title,
      "body": body,
      "dateTime": DateTime.now().toIso8601String(),
      "error": false,
    });
  }

  //  Message to notify seller whenever a purchase is made
  Future sendSaleMessageToRetailer(
      String productId, int quantity, double cost, bool upi) async {
    String buyerAddress = "";
    String buyerNumber = "";
    String buyerName = "";
    String productName = "";

    await FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("MyData")
        .get()
        .then((value) {
      buyerAddress = value.docs.first.data()["address"];
      buyerNumber = value.docs.first.data()["mobileNumber"];
      buyerName = value.docs.first.data()["name"];
    });

    String retailerId = "";
    String retailerUpi = "";

    String token;
    //  Fetch retailerId from productId
    await FirebaseFirestore.instance
        .collection("Products")
        .doc(productId)
        .get()
        .then((value) {
      retailerId = value.data()["retailerId"];
      productName = value.data()["title"];
    });
    //  Fetch retailer fcm token using retailerId
    await FirebaseFirestore.instance
        .collection("User")
        .doc(retailerId)
        .collection("MyData")
        .get()
        .then((value) {
      token = value.docs.first.data()["fcmToken"];
      retailerUpi = value.docs.first.data()["upi"];
    });
    String title = "$buyerName bought your product $productName";
    //  If payment was done by upi, show Cost as paid, else show cost to retailer
    String body = upi == true
        ? "Sale details: $quantity $productName ordered.\nDelivery address: $buyerAddress\nNumber: $buyerNumber\nCost: Paid(Upi)"
        : "Sale details: $quantity $productName ordered.\nDelivery address: $buyerAddress\nNumber: $buyerNumber\nCost: $cost";
    await sendMessage(token, title, body);
    await FirebaseFirestore.instance
        .collection("User")
        .doc(retailerId)
        .collection("MyMessages")
        .add({
      "title": title,
      "body": body,
      "dateTime": DateTime.now().toIso8601String(),
      "error": false,
    });

    //  If upi was true, send notification to admin to re-direct the given amount to mentioned upi address of retailer
    if (upi == true) {
      await sendPaymentMessageToAdmin(retailerUpi, cost);
    }
  }

  //  Message to be sent to admin in case he needs to do a payment to a retailer
  Future<void> sendPaymentMessageToAdmin(
      String retailerUpi, double cost) async {
    String title = "You have a new payment to complete";
    String body = "Pay $cost to retailer with upiId: $retailerUpi";
    String token;
    String adminId;
    await FirebaseFirestore.instance
        .collection("Admin")
        .doc(DataModel.adminEmail)
        .get()
        .then((value) {
      token = value.data()["fcmToken"];
      adminId = value.data()["adminId"];
    });
    await sendMessage(token, title, body);
    return await FirebaseFirestore.instance
        .collection("User")
        .doc(adminId)
        .collection("MyMessages")
        .add({
      "title": title,
      "body": body,
      "dateTime": DateTime.now().toIso8601String(),
      "error": true,
    });
  }

  //  General message to send to a user with user token, title and body
  Future<void> sendMessage(String token, String title, String body) async {
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${DataModel.fcmServerKey}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': '$body', 'title': '$title'},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    );
  }
}

//  Message/notification class
class Message {
  final String title;
  final String body;
  final DateTime dateTime;
  final bool error;
  const Message(
      {@required this.title,
      @required this.body,
      @required this.dateTime,
      @required this.error});
}
