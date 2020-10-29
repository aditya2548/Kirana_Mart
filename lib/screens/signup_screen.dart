import '../models/auth_provider.dart';
import '../screens/home_page_tabs_screen.dart';
import 'package:provider/provider.dart';

import '../screens/login_screen.dart';
import 'package:flutter/material.dart';

//  Sigup screen to create an id
class SignUpScreen extends StatelessWidget {
  static const routeName = "/signup_screen";
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
                    .pushReplacementNamed(LoginScreen.routeName);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                color: Theme.of(context).primaryColor,
                child: Text(
                  "Login ?",
                  style: TextStyle(
                    // fontSize: 20,
                    color: Theme.of(context).highlightColor,
                  ),
                ),
              ),
            ),
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
                  'Hello, friend!',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).highlightColor),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                child: Text(
                  "Let's get started",
                  style: TextStyle(color: Theme.of(context).highlightColor),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
                  child: SignupAuthCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupAuthCard extends StatefulWidget {
  const SignupAuthCard({
    Key key,
  }) : super(key: key);

  @override
  _SignupAuthCardState createState() => _SignupAuthCardState();
}

class _SignupAuthCardState extends State<SignupAuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  //  Map to store all user data
  Map<String, String> _authData = {
    'name': '',
    'email': '',
    'mobileNumber': '',
    'address': '',
    'password': '',
    'upi': '',
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
    // Sign user up
    final signUpResult = await context
        .read<AuthProvider>()
        .signUpWithEmailAndPassword(_authData, context);
    if (signUpResult == "Signed Up") {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(HomePageTabsScreen.routeName);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  //  All the TextFormFields inside a form with appropriate validations
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        margin: EdgeInsets.only(bottom: 80),
        child: Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8,
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                      // style: TextStyle(fontSize: 10),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        // errorStyle: TextStyle(fontSize: 8),
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null ||
                            value.trim() == "" ||
                            value.length < 3) {
                          return 'Invalid Name!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _authData['name'] = value;
                      },
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      // style: TextStyle(fontSize: 10),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'E-Mail',
                        // errorStyle: TextStyle(fontSize: 8),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                          return 'Invalid email!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _authData['email'] = value;
                      },
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      // style: TextStyle(fontSize: 10),
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        // errorStyle: TextStyle(fontSize: 8),
                      ),
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
                      onSaved: (value) {
                        _authData['mobileNumber'] = value;
                      },
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      // style: TextStyle(fontSize: 10),
                      decoration: InputDecoration(
                        labelText: 'Address',
                        // errorStyle: TextStyle(fontSize: 8),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      minLines: 1,
                      validator: (value) {
                        if (value == null || value.trim() == "") {
                          return 'Please enter your address';
                        } else if (value.length <= 10) {
                          return 'Address must be atleast 10 characters long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _authData['address'] = value;
                      },
                    ),
                    TextFormField(
                      // style: TextStyle(fontSize: 10),
                      decoration: InputDecoration(
                          labelText: 'Upi (kirana@example)',
                          hintText: 'Mandatory for retailers'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSaved: (value) {
                        _authData['upi'] = value;
                      },
                    ),
                    TextFormField(
                      // style: TextStyle(fontSize: 10),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        // errorStyle: TextStyle(fontSize: 8),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value.isEmpty || value.length < 6) {
                          return 'Password must be atleast 6 characters long!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _authData['password'] = value;
                      },
                    ),
                    TextFormField(
                      // style: TextStyle(fontSize: 10),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        // errorStyle: TextStyle(fontSize: 8),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match!';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(FocusNode()),
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
    ]);
  }
}
