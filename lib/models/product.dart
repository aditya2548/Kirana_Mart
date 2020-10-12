import 'package:flutter/material.dart';

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
  Review({this.username, this.description, this.stars});
}

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final ProductCategory productCategory;
  bool isFav;
  //  Map of reviews user-email as the key (dummy reviews)
  List<Map<String, Review>> _reviews = [
    {"userId": Review(username: "Aman", stars: 5, description: "Good")},
    {"userId": Review(username: "Amit", stars: 2, description: "Average")},
    {"userId": Review(username: "Gaurav", stars: 1, description: "Good")},
  ];

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    @required this.productCategory,
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
  void toggleFav() {
    isFav = !isFav;
    notifyListeners();
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
}
