import '../models/data_model.dart';

import '../models/key_data_model.dart';

import '../dialog/custom_dialog.dart';

import '../screens/admin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_provider.dart';
import '../screens/home_page_tabs_screen.dart';
import '../screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  Screen to login with email and password
class LoginScreen extends StatelessWidget {
  static const routeName = "/login_screen";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 5,
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(SignUpScreen.routeName);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    DataModel.signup,
                    style: TextStyle(
                      // fontSize: 13,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                )),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                child: Text(
                  DataModel.welcomeBack,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).highlightColor),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                child: Text(DataModel.howdyAuthenticate,
                    style: TextStyle(
                        // fontSize: 10,
                        color: Theme.of(context).highlightColor)),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
                  child: LoginAuthCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginAuthCard extends StatefulWidget {
  const LoginAuthCard({
    Key key,
  }) : super(key: key);

  @override
  _LoginAuthCardState createState() => _LoginAuthCardState();
}

class _LoginAuthCardState extends State<LoginAuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  //  Map to store all user data
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid data
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    // Login user
    final loginResult = await context
        .read<AuthProvider>()
        .loginWithEmailAndPassword(
            _authData["email"], _authData["password"], context);
    setState(() {
      _isLoading = false;
    });
    if (loginResult == "Logged In") {
      Navigator.pop(context);
      final _firebaseUser = context.read<User>();
      //  If user is admin
      if (_firebaseUser.email == KeyDataModel.adminEmail)
        Navigator.of(context).pushReplacementNamed(AdminScreen.routeName);
      else
        Navigator.of(context)
            .pushReplacementNamed(HomePageTabsScreen.routeName);
    }
  }

  @override
  //  All the TextFormFields inside a form with appropriate validations
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 80),
          child: Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        // style: TextStyle(fontSize: 10),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: DataModel.email,
                          // errorStyle: TextStyle(fontSize: 8),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (!RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                            return DataModel.invalidEmail;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _authData['email'] = value;
                        },
                      ),
                      TextFormField(
                        // style: TextStyle(fontSize: 10),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: DataModel.password,
                          // errorStyle: TextStyle(fontSize: 8),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value.isEmpty || value.length < 6) {
                            return DataModel.passwordMinLengthLimitError;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _authData['password'] = value;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Positioned(bottom: 15, right: 20, child: CircularProgressIndicator())
        else
          Positioned(
            bottom: 15,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                _submit();
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).highlightColor,
                size: 30,
              ),
            ),
          ),
        Positioned(
          bottom: 15,
          left: 5,
          child: FlatButton(
            onPressed: () {
              CustomDialog.resetPasswordDialog(context);
            },
            child: Text(
              DataModel.forgotPassword,
              style: TextStyle(
                  // fontSize: 12,
                  color: Theme.of(context).accentColor),
            ),
          ),
        ),
      ],
    );
  }
}
