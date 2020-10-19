import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//  Provider which gives all the functionalities to create id, login, signout, change id details
class AuthProvider {
  final FirebaseAuth _firebaseAuth;
  AuthProvider(this._firebaseAuth);

  //  If we get a user, we go to homepage, else to welcome page
  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  //  Method to login with email and password
  Future<String> loginWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      // notifyListeners();
      return "Logged In";
    } on FirebaseAuthException catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message,
            style: TextStyle(fontSize: 9),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return e.message;
    }
  }

  //  Method to sign-out user
  Future<void> signOutUser() async {
    await _firebaseAuth.signOut();
    // notifyListeners();
  }

  //  Method to sign-up with email and password
  //  Store other details of the user in firestore
  Future<String> signUpWithEmailAndPassword(
      Map<String, String> _authData, BuildContext context) async {
    try {
      UserCredential userId =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: _authData["email"], password: _authData["password"]);
      // print(userId.user.uid);
      try {
        final CollectionReference collectionReference = FirebaseFirestore
            .instance
            .collection("User")
            .doc(userId.user.uid)
            .collection("MyData");
        await collectionReference.add(
          {
            "name": _authData["name"],
            "mobileNumber": _authData["mobileNumber"],
            "address": _authData["address"],
          },
        );
      }
      //  throw the error to the screen/widget using the method
      catch (error) {
        throw error;
      }

      // notifyListeners();
      return "Signed Up";
    } on FirebaseAuthException catch (e) {
      // print(e.message);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message,
            style: TextStyle(fontSize: 9),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return e.message;
    }
  }
}
