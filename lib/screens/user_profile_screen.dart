import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = "/user_profile_screen";

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User _user;
  String _mobileNumber = "";
  String _address = "";
  String _name = "";
  @override
  void initState() {
    super.initState();

    _user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("User")
        .doc(_user.uid)
        .collection("MyData")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        print(element.data());
        _mobileNumber = element.data()["mobileNumber"];
        _address = element.data()["address"];
        _name = element.data()["name"];
        setState(() {});
      });
    });
    print("here");
  }

  @override
  Widget build(BuildContext context) {
    print("builddd");
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
      ),
      body: _mobileNumber == ""
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  Text(_user.email),
                  Text(_user.emailVerified.toString()),
                  Text(_address),
                  Text(_name),
                  Text(_mobileNumber),
                ],
              ),
            ),
    );
  }
}
