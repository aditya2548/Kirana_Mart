import '../models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//  Stateful widget to store the details of new review in a bottom sheet
//  and then save then to the corresponding product's Reviews
class NewReview extends StatefulWidget {
  final String productID;
  NewReview(this.productID);
  @override
  _NewReviewState createState() => _NewReviewState();
}

class _NewReviewState extends State<NewReview> {
  Review _review;
  //  form key(used to save review)
  final _formKey = GlobalKey<FormState>();

  String initialReview;
  String initialStars;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    //  Set initial value of rating and review, if user edits a previous review
    setState(() {
      isLoading = true;
    });
    FirebaseFirestore.instance
        .collection("Products")
        .doc(widget.productID)
        .collection("Reviews")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      if (value.exists) {
        initialReview = value.data()["description"];
        initialStars = value.data()["stars"].toString();
      } else {
        initialReview = "";
        initialStars = "";
      }
      setState(() {
        isLoading = false;
      });
    });
    FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("MyData")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        _review = Review(
            username: element.data()["name"],
            description: "",
            stars: 5,
            dateTime: DateTime.now());
      });
    });
  }

  //  To save a review
  Future _submitReview() async {
    final isValid = _formKey.currentState.validate();
    if (isValid) {
      //  trigger onSaved
      _formKey.currentState.save();
      try {
        await FirebaseFirestore.instance
            .collection("Products")
            .doc(widget.productID)
            .collection("Reviews")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .set(
          {
            "dateTime": _review.dateTime.toIso8601String(),
            "stars": _review.stars,
            "username": _review.username,
            "description": _review.description,
          },
        );
      } catch (error) {
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
    //  till we're loading last review data for same product by same user
    if (isLoading == true) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: LinearProgressIndicator(),
      );
    }
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
                  TextFormField(
                    initialValue: initialStars,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        labelText: "Stars",
                        errorStyle: TextStyle(fontSize: 10)),
                    keyboardType: TextInputType.number,
                    validator: (rating) {
                      if (rating == null || rating.trim() == "") {
                        return "Please provide stars rating";
                      } else if (int.tryParse(rating) == null) {
                        return "Please provide valid rating";
                      } else if (int.parse(rating) < 1 ||
                          double.parse(rating) > 5) {
                        return "Please provide a rating between 1 and 5";
                      }
                      return null;
                    },
                    onSaved: (stars) => _review = Review(
                      dateTime: DateTime.now(),
                      username: _review.username,
                      stars: int.parse(stars),
                      description: _review.description,
                    ),
                  ),
                  TextFormField(
                    initialValue: initialReview,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        labelText: "Review",
                        errorStyle: TextStyle(fontSize: 10)),
                    keyboardType: TextInputType.multiline,
                    validator: (desc) {
                      if (desc == null || desc.trim() == "") {
                        return "Please provide review";
                      } else if (desc.length <= 5) {
                        return "Review should be > 5 characters";
                      }
                      return null;
                    },
                    onSaved: (desc) => _review = Review(
                      dateTime: DateTime.now(),
                      username: _review.username,
                      stars: _review.stars,
                      description: desc,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    child: Text(
                      "Add Review",
                    ),
                    onPressed: () {
                      _submitReview();
                    },
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
