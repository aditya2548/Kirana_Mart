import '../models/data_model.dart';

import '../widgets/custom_app_bar_title.dart';

import '../widgets/edit_profile_bottom_sheet.dart';
import 'package:flutter/rendering.dart';
import 'package:shimmer/shimmer.dart';

import '../models/auth_provider.dart';
import '../widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  String _upi = "";
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
        _upi = element.data()["upi"];
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: -5,
          title: CustomAppBarTitle(
              name: DataModel.myProfile, icondata: Icons.person_outline),
        ),
        body: _mobileNumber == ""
            ? Center(child: CircularProgressIndicator())
            : Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: SizedBox(
                            height: 70,
                            width: 70,
                            child: Shimmer.fromColors(
                              baseColor: Colors.red[900],
                              highlightColor: Colors.orange,
                              period: Duration(seconds: 2),
                              child: Image.asset(
                                  "assets/images/Kirana_mart_logo.png"),
                            )),
                      ),
                      if (_user.emailVerified == false)
                        RaisedButton(
                          onPressed: () {
                            FirebaseAuth.instance.currentUser
                                .reload()
                                .then((value) {
                              setState(() {});
                            });
                          },
                          child: Text(DataModel.refreshStatus),
                        ),
                      if (_user.emailVerified == false)
                        RaisedButton(
                          color: Theme.of(context).errorColor,
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false)
                                .verifyEmail();
                            setState(() {});
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            width: double.infinity,
                            alignment: Alignment.center,
                            color: Theme.of(context).errorColor,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                DataModel.emailNotVerified,
                                style: TextStyle(
                                  color: Theme.of(context).highlightColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_user.emailVerified == true)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          alignment: Alignment.center,
                          color: Colors.green,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              DataModel.emailVerified,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 50,
                      ),
                      Card(
                        elevation: 15,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Theme.of(context).primaryColor,
                        // width: double.infinity,
                        // alignment: Alignment.center,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Name: $_name"),
                        ),
                      ),
                      Card(
                        elevation: 15,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Theme.of(context).primaryColor,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Email: ${_user.email}"),
                        ),
                      ),
                      Card(
                        elevation: 15,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Theme.of(context).primaryColor,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Address: $_address"),
                        ),
                      ),
                      Card(
                        elevation: 15,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Theme.of(context).primaryColor,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Mobile Number: $_mobileNumber"),
                        ),
                      ),
                      Card(
                        elevation: 15,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Theme.of(context).primaryColor,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Upi: $_upi"),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: RaisedButton(
                              color: Theme.of(context).primaryColor,
                              child: Text(DataModel.editProfile),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (_) {
                                    return EditProfile(
                                      address: _address,
                                      mobileNumber: _mobileNumber,
                                      upi: _upi,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: RaisedButton(
                              color: Theme.of(context).errorColor,
                              child: Text(DataModel.signOut),
                              onPressed: () {
                                Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .signOutUser(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        drawer: AppDrawer(DataModel.myProfile),
      ),
    );
  }
}
