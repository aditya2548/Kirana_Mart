import 'product.dart';
import 'package:flutter/material.dart';

class ProductsProvider with ChangeNotifier {
  //  private list of products(private so that anyone cannot alter it without notifying listeners)
  List<Product> _productItems = [
    Product(
      id: 'p1',
      title: 'Ketchup',
      description:
          "tomato ketchup tomato ketchup tomato ketchup tomato ketchup tomato ketchup tomato ketchup tomato ketchup",
      price: 50,
      imageUrl:
          'https://assets.sainsburys-groceries.co.uk/gol/3304846/1/640x640.jpg',
      productCategory: ProductCategory.PackagedFoods,
    ),
    Product(
      id: 'p2',
      title: 'Soap',
      description: 'herbal soap',
      price: 60,
      imageUrl:
          'https://rukminim1.flixcart.com/image/352/352/jyg5lzk0/soap/q/g/9/5-375-oil-clear-glow-soap-bar-75-gms-pack-of-5-pears-original-imafhmwfhus6hnzf.jpeg?q=70',
      productCategory: ProductCategory.PersonalCare,
    ),
    Product(
      id: 'p3',
      title: 'Coffee',
      description: 'freshly brewed coffee.',
      price: 150,
      imageUrl:
          'https://www.cancer.org/content/dam/cancer-org/images/photographs/single-use/espresso-coffee-cup-with-beans-on-table-restricted.jpg',
      productCategory: ProductCategory.Beverages,
    ),
    Product(
      id: 'p4',
      title: 'Kurkure',
      description: 'ready to eat snack',
      price: 20,
      imageUrl:
          'https://5.imimg.com/data5/WT/SB/MB/SELLER-77460638/kurkure-500x500.jpg',
      productCategory: ProductCategory.PackagedFoods,
    ),
  ];
  //  function to get a copy of list of products
  List<Product> get getProductItems {
    return [..._productItems];
  }

  //  function to get a copy of list of favorite products
  List<Product> get getFavoriteProductItems {
    return _productItems.where((element) => element.isFav).toList();
  }

  //  function to reload all the favorites
  void reloadFavorites() {
    notifyListeners();
  }

  //  function to get a product when id is provided
  Product getProductFromId(String id) {
    return _productItems.firstWhere((element) => element.id == id);
  }
}
