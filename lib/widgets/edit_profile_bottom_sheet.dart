import 'package:upi_pay/upi_pay.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//  Stateful widget to store the details of profile edits in a bottom sheet
//  and then save then to the corresponding user's profile data
class EditProfile extends StatefulWidget {
  final String address;
  final String mobileNumber;
  final String upi;
  EditProfile({this.address, this.mobileNumber, this.upi});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //  form key(used to save review)
  final _formKey = GlobalKey<FormState>();

  String _newAddress;
  String _newMobileNumber;
  String _newUpi;

  //  To save changes
  Future _submitProfileEdit() async {
    final isValid = _formKey.currentState.validate();
    if (isValid) {
      //  trigger onSaved
      _formKey.currentState.save();
      try {
        String docid;
        await FirebaseFirestore.instance
            .collection("User")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("MyData")
            .get()
            .then((value) {
          docid = value.docs.first.id;
        });

        await FirebaseFirestore.instance
            .collection("User")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("MyData")
            .doc(docid)
            .update({
          "address": _newAddress,
          "upi": _newUpi,
          "mobileNumber": _newMobileNumber,
        });
      } catch (error) {
        print(error);
        Fluttertoast.cancel();
        Fluttertoast.showToast(
            msg: "Some error occured, please try again later");
      } finally {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          color: Theme.of(context).primaryColorDark,
          padding: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          child: Container(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 5,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "NOTE: Changes will take a little time to reflect in your profile",
                        style: TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.address,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                          labelText: "Address",
                          errorStyle: TextStyle(fontSize: 10)),
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.trim() == "") {
                          return 'Please enter your address';
                        } else if (value.length <= 10) {
                          return 'Address must be atleast 10 characters long';
                        }
                        return null;
                      },
                      onSaved: (address) => _newAddress = address,
                    ),
                    TextFormField(
                      initialValue: widget.mobileNumber,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                          labelText: "Mobile Number",
                          errorStyle: TextStyle(fontSize: 10)),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.length == 0) {
                          return 'Please enter mobile number';
                        } else if (!RegExp(r'(^(?:[+0]9)?[0-9]{10,10}$)')
                            .hasMatch(value)) {
                          return 'Please enter valid mobile number';
                        }
                        return null;
                      },
                      onSaved: (mobile) => _newMobileNumber = mobile,
                    ),
                    TextFormField(
                      initialValue: widget.upi,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                          labelText: "Upi",
                          errorStyle: TextStyle(fontSize: 10)),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (upi) {
                        if (upi == null || upi.trim() == "") {
                          return "Please provide upi";
                        } else if (!UpiPay.checkIfUpiAddressIsValid(upi)) {
                          return "Please provide valid upi-id (kirana@example)";
                        }
                        return null;
                      },
                      onSaved: (upi) => _newUpi = upi,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      child: Text(
                        "Save changes",
                      ),
                      onPressed: () {
                        _submitProfileEdit();
                      },
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}