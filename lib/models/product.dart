import 'package:flutter/material.dart';

enum ProductCategory {
  CookingEssentials,
  PackagedFoods,
  Beverages,
  HouseHold,
  PersonalCare,
}

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final ProductCategory productCategory;
  bool isFav;

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

//  function to toggle favourite status and to notify to all the listeners of product
  void toggleFav() {
    isFav = !isFav;
    notifyListeners();
  }
}
