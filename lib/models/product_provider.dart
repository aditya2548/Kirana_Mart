import '../dialog/custom_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'product.dart';
import 'package:flutter/material.dart';

class ProductsProvider with ChangeNotifier {
  //  private list of products(private so that anyone cannot alter it without notifying listeners)
  List<Product> _productItems = [
    // Product(
    //   id: 'p1',
    //   title: 'Ketchup',
    //   description:
    //       "tomato ketchup tomato ketchup tomato ketchup tomato ketchup tomato ketchup tomato ketchup tomato ketchup",
    //   price: 50,
    //   imageUrl:
    //       'https://assets.sainsburys-groceries.co.uk/gol/3304846/1/640x640.jpg',
    //   productCategory: ProductCategory.PackagedFoods,
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Soap',
    //   description: 'herbal soap',
    //   price: 60,
    //   imageUrl:
    //       'https://rukminim1.flixcart.com/image/352/352/jyg5lzk0/soap/q/g/9/5-375-oil-clear-glow-soap-bar-75-gms-pack-of-5-pears-original-imafhmwfhus6hnzf.jpeg?q=70',
    //   productCategory: ProductCategory.PersonalCare,
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Coffee',
    //   description: 'freshly brewed coffee.',
    //   price: 150,
    //   imageUrl:
    //       'https://www.cancer.org/content/dam/cancer-org/images/photographs/single-use/espresso-coffee-cup-with-beans-on-table-restricted.jpg',
    //   productCategory: ProductCategory.Beverages,
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Kurkure',
    //   description: 'ready to eat snack',
    //   price: 20,
    //   imageUrl:
    //       'https://5.imimg.com/data5/WT/SB/MB/SELLER-77460638/kurkure-500x500.jpg',
    //   productCategory: ProductCategory.PackagedFoods,
    // ),
  ];
  //  function to get a copy of list of products
  List<Product> get getProductItems {
    return [..._productItems];
  }

  //  function to get a copy of list of favorite products
  List<Product> get getFavoriteProductItems {
    return _productItems.where((element) => element.isFav).toList();
  }

  //  function to get a product when id is provided
  Product getProductFromId(String id) {
    return _productItems.firstWhere((element) => element.id == id);
  }

  //  Function to add a product to product list and firestore collection "Products"
  //  The id generated from there is used as product id
  //  wait for value from "await", then further code executed
  //  Product not added to local product-list -
  //  as we are listening to product changes in resl-time using fetchProductsRealTime
  Future<void> addProduct(Product product) async {
    print("add");
    try {
      final CollectionReference c =
          FirebaseFirestore.instance.collection("Products");
      await c.add(
        {
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "productCategory":
              Product.productCattoString(product.productCategory),
          "isFav": product.isFav,
        },
      );
    }
    //  throw the error to the screen/widget using the method
    catch (error) {
      throw error;
    }
  }

  //  Function to fetch products from firestore in real-time
  //  Add changes in update/add/delete products are handled here to show effect
  Future<void> fetchProductsRealTime() async {
    print("fetch");

    final CollectionReference c =
        FirebaseFirestore.instance.collection("Products");

    List<Product> _fetchedProducts = [];
    try {
      c.snapshots().listen((event) {
        event.docChanges.forEach((element) {
          if (element.type == DocumentChangeType.added) {
            print("add");
            _fetchedProducts.add(
              Product(
                id: element.doc.id,
                title: element.doc.data()["title"],
                description: element.doc.data()["description"],
                imageUrl: element.doc.data()["imageUrl"],
                price: element.doc.data()["price"],
                productCategory: Product.stringtoProductCat(
                    element.doc.data()["productCategory"]),
              ),
            );
          } else if (element.type == DocumentChangeType.modified) {
            print("modify");
            final modifyIndex =
                _fetchedProducts.indexWhere((el) => el.id == element.doc.id);
            _fetchedProducts[modifyIndex] = Product(
              id: element.doc.id,
              title: element.doc.data()["title"],
              description: element.doc.data()["description"],
              imageUrl: element.doc.data()["imageUrl"],
              price: element.doc.data()["price"],
              productCategory: Product.stringtoProductCat(
                  element.doc.data()["productCategory"]),
              isFav: _fetchedProducts[modifyIndex].isFav,
            );
          } else if (element.type == DocumentChangeType.removed) {
            print("remove");
            _fetchedProducts.removeWhere((el) => el.id == element.doc.id);
          }
          print(_fetchedProducts.length);
          _productItems = _fetchedProducts;
          notifyListeners();
          reloadProducts();
        });
      });
    } catch (error) {
      throw error;
    }
  }

  //  Function to reload products from firestore and storing fetched products to our list of products
  //  Used for pull down to refresh
  Future<void> reloadProducts() async {
    try {
      final CollectionReference c =
          FirebaseFirestore.instance.collection("Products");

      final value = await c.get();
      final List<Product> _fetchedProducts = [];
      value.docs.forEach((element) {
        _fetchedProducts.add(Product(
          id: element.id,
          title: element.data()["title"],
          description: element.data()["description"],
          imageUrl: element.data()["imageUrl"],
          price: element.data()["price"],
          productCategory:
              Product.stringtoProductCat(element.data()["productCategory"]),
          isFav: element.data()["isFav"],
        ));
      });
      _productItems = _fetchedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //  Function to update a product present in product list
  //  Product not modified in local product-list -
  //  as we are listening to product changes in resl-time using fetchProductsRealTime
  Future<void> updateProduct(String id, Product product) async {
    print("update");
    try {
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection("Products").doc(id);

      await docRef.update(
        {
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "productCategory":
              Product.productCattoString(product.productCategory),
          "isFav": product.isFav,
        },
      );
    } catch (error) {
      throw error;
    }
  }

  //  Function to delete product
  //  Also check whether product is present there,
  //  because .delete won't throw an exception even if product doesn't exist
  //  So, delete product only if it exists at specified location in firestore
  //  else show an error-dialog
  Future<void> deleteProduct(String id, BuildContext context) async {
    try {
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection("Products").doc(id);
      docRef.get().then(
        (value) {
          //  If that product is present in collection
          if (value.exists) {
            print("there");
            docRef.delete();
            Navigator.of(context).pop(true);
          }
          //  If product is not there, show error
          else {
            CustomDialog.generalErrorDialog(context)
                .then((value) => Navigator.of(context).pop(true));
          }
        },
      );
    } catch (error) {
      print(error);
    } finally {
      notifyListeners();
    }
  }
}
