import '../models/fcm_provider.dart';

import '../models/product_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ProductCategory {
  CookingEssentials,
  PackagedFoods,
  Beverages,
  HouseHold,
  PersonalCare,
}

//  Review class with stars and description
class Review {
  @required
  String username;
  @required
  final String description;
  @required
  final int stars;
  @required
  final DateTime dateTime;
  Review({this.username, this.description, this.stars, this.dateTime});
}

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final ProductCategory productCategory;
  final String retailerId;
  final int quantity;
  bool isFav;
  //  Map of reviews user-email as the key (dummy reviews)
  List<Map<String, Review>> _reviews = [];

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    @required this.productCategory,
    @required this.retailerId,
    this.quantity = 0,
    this.isFav = false,
  });

  static String productCattoString(ProductCategory c) {
    switch (c) {
      case ProductCategory.Beverages:
        return "Beverage";
      case ProductCategory.CookingEssentials:
        return "Cooking Essential";
      case ProductCategory.HouseHold:
        return "Household";
      case ProductCategory.PackagedFoods:
        return "Packaged Food";
      case ProductCategory.PersonalCare:
        return "Personal Care";
      default:
        return " ";
    }
  }

  static ProductCategory stringtoProductCat(String c) {
    switch (c) {
      case "Beverage":
        return ProductCategory.Beverages;
      case "Cooking Essential":
        return ProductCategory.CookingEssentials;
      case "Household":
        return ProductCategory.HouseHold;
      case "Packaged Food":
        return ProductCategory.PackagedFoods;
      case "Personal Care":
        return ProductCategory.PersonalCare;
      default:
        return ProductCategory.HouseHold;
    }
  }

//  function to toggle favourite status and to notify to all the listeners of product
//  We inverted the fav status in the product item itself
//  Also subscribe to topic(product ID), when added to fav, and un-subscribe if removed from fav
  Future<void> toggleFav(BuildContext context) async {
    if (isFav == false) {
      Provider.of<ProductsProvider>(context, listen: false).removeFav(id);
      await Provider.of<FcmProvider>(context, listen: false)
          .unsubscribeFromTopic(id);
    } else {
      Provider.of<ProductsProvider>(context, listen: false).addFav(id);
      await Provider.of<FcmProvider>(context, listen: false)
          .subscribeToTopic(id);
    }
    try {
      // final DocumentReference docRef =
      //     FirebaseFirestore.instance.collection("Products").doc(id);
      final CollectionReference collectionReference = FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("MyFav");
      await collectionReference.doc(id).set(
        {
          "isFav": isFav,
        },
      );
      Provider.of<ProductsProvider>(context, listen: false).fetchFavsRealTime();
    } catch (error) {
      throw error;
    }
  }

  //  Function to get average star rating of a product
  double get getAverageRating {
    double rating = 0;
    int count = 0;
    for (var item in _reviews) {
      rating += item.values.toList()[0].stars;
      count++;
    }
    if (count == 0) return 5;
    return rating / count;
  }

  //  Function to get the count of reviews
  int get getReviewCount {
    return _reviews.length;
  }

  //  Function to get the review's list
  List<Map<String, Review>> get getReviews {
    return [..._reviews];
  }

  //  Function to fetch reviews from firestore
  Future fetchAllReviews() async {
    _reviews = [];
    var snapshot = await FirebaseFirestore.instance
        .collection("Products")
        .doc(id)
        .collection("Reviews")
        .get();
    print(snapshot.docs.length);
    snapshot.docs.forEach((element) {
      _reviews.add({
        element.id: Review(
          dateTime: DateTime.parse(element.data()["dateTime"]),
          username: element.data()["username"],
          stars: element.data()["stars"],
          description: element.data()["description"],
        ),
      });
    });
    notifyListeners();
  }
}
