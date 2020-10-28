import '../models/fcm_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

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

  //  Stores documentSnashot of last fetched document(lazy loading)
  DocumentSnapshot _lastDocument;

  //   List of List of products that contain paged product lists
  //   so that we can update a particular previous page if needed
  List<List<Product>> _allPagedProducts = List<List<Product>>();

  //  boolean to know whether we have more products available or not
  bool _hasMoreProducts = true;

  //  number of products to be loaded at once
  int _productsPerPage = 8;

  //  List of all pending products for approval by admin
  List<Product> _pendingProducts = [];

  //  function to get a copy of list of products
  List<Product> get getProductItems {
    return [..._productItems];
  }

  //  Function for getting list of products based upon the search query
  List<Product> getProductItemsOnSearch(String search) {
    reloadProducts();
    return _productItems
        .where((element) =>
            element.title.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

//  To get the products provided by the user(using retailerId)
  List<Product> getMyProducts() {
    return _productItems
        .where((element) =>
            element.retailerId == FirebaseAuth.instance.currentUser.uid)
        .toList();
  }

  //  function to get a copy of list of favorite products
  List<Product> get getFavoriteProductItems {
    return getProductItems.where((element) => element.isFav).toList();
  }

  //  Remove a product from favs locally
  void removeFav(id) {
    getFavoriteProductItems.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  //  Add a product to favs locally
  void addFav(id) {
    getFavoriteProductItems.add(getProductFromId(id));
    notifyListeners();
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
          FirebaseFirestore.instance.collection("PendingProducts");
      await c.add(
        {
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "productCategory":
              Product.productCattoString(product.productCategory),
          // "isFav": product.isFav,
          "retailerId": product.retailerId,
        },
      );
      Fluttertoast.showToast(
          msg: "Product will be added after appoval by admin");
    }
    //  throw the error to the screen/widget using the method
    catch (error) {
      throw error;
    }
  }

  //  Function to freshly load the products list
  //  On formation on screen, or on refresh
  bool reloading = false;
  Future<void> fetchProductsRealTime() async {
    _hasMoreProducts = true;
    reloading = true;
    _lastDocument = null;
    await listenToProductsRealTime();
    reloading = false;
  }

  //  Request for more products if needed
  Future<void> requestMoreData() async {
    return await listenToProductsRealTime();
  }

  //  get data whether more products are available or not
  bool moreProductsAvailable() {
    return _hasMoreProducts;
  }

  //  Function to fetch products from firestore in real-time
  //  Add changes in update/add/delete products are handled here to show effect
  //  Also, changes to fav of any user are also shown
  //  Products fetched in pages of 20 products per page
  Future<void> listenToProductsRealTime() async {
    var pageProducts = FirebaseFirestore.instance
        .collection("Products")
        .orderBy("title")
        .limit(_productsPerPage);
    if (reloading) {
      return;
    }
    //  if requesting more products
    if (_lastDocument != null) {
      pageProducts = pageProducts.startAfterDocument(_lastDocument);
    }
    //  If no more data, return
    if (!_hasMoreProducts) {
      return false;
    }
    // if (reloading) {
    //   _allPagedProducts = List<List<Product>>();
    //   reloading = false;
    // }
    //  We got data to load now!!
    //  Index of page to be requested
    var _currentRequestIndex = _allPagedProducts.length;

    List<Product> _fetchedProducts = [];

    //  Listen and fetch products
    try {
      pageProducts.snapshots().listen((event) {
        if (event.docChanges == null || event.docs.isEmpty) {
          return;
        }
        List<Product> allProducts;
        event.docChanges.forEach((element) {
          if (element.type == DocumentChangeType.added) {
            _fetchedProducts.add(
              Product(
                id: element.doc.id,
                title: element.doc.data()["title"],
                description: element.doc.data()["description"],
                imageUrl: element.doc.data()["imageUrl"],
                price: element.doc.data()["price"],
                productCategory: Product.stringtoProductCat(
                    element.doc.data()["productCategory"]),
                retailerId: element.doc.data()["retailerId"],
                quantity: element.doc.data()["quantity"],
              ),
            );
          } else if (element.type == DocumentChangeType.modified) {
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
              retailerId: element.doc.data()["retailerId"],
              quantity: element.doc.data()["quantity"],
            );
          } else if (element.type == DocumentChangeType.removed) {
            _fetchedProducts.removeWhere((el) => el.id == element.doc.id);
          }

          //  If current request index is less than the length of allPagedProducts
          //  it means, we're modifying changes made to previous fetched product
          var pageExits = _currentRequestIndex < _allPagedProducts.length;

          if (pageExits) {
            _allPagedProducts[_currentRequestIndex] = _fetchedProducts;
          } else {
            _allPagedProducts.add(_fetchedProducts);
          }

          //  Fold to fetch all the products from the list of (paged list of products)
          allProducts = _allPagedProducts.fold<List<Product>>(List<Product>(),
              (initialValue, pageItems) => initialValue..addAll(pageItems));

          if (_currentRequestIndex == _allPagedProducts.length - 1) {
            _lastDocument = event.docs.last;
          }
          _hasMoreProducts = _fetchedProducts.length == _productsPerPage;

          // reloadProducts();
        });
        // _productItems = _fetchedProducts;
        print(
            "Lazy Loading fetched: ${_fetchedProducts.length}, total: ${allProducts.length}");
        _productItems = allProducts;
        fetchFavsRealTime();

        notifyListeners();
      });
    } catch (error) {
      throw error;
    }
    return true;
  }

  //  To listen to changes in fav
  Future<void> fetchFavsRealTime() async {
    final CollectionReference favReference = FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("MyFav");
    try {
      favReference.snapshots().listen((event) {
        if (event.docChanges == null) {
          return;
        }
        // reloadProducts();
        // fetchProductsRealTime();
        event.docChanges.forEach((element) {
          var index = _productItems
              .indexWhere((product) => product.id == element.doc.id);
          if (index != -1)
            _productItems[index].isFav = element.doc.data()["isFav"];
        });
        // requestMoreData();
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
      if (value.docs == null) {
        return;
      }
      List<String> isFav = [];
      await FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("MyFav")
          .get()
          .then((value) {
        value.docs.forEach((element) {
          if (element.data()["isFav"] == true) {
            isFav.add(element.id);
          }
        });
        // isFav.add(value)
      });
      value.docs.forEach((element) {
        _fetchedProducts.add(Product(
          id: element.id,
          title: element.data()["title"],
          description: element.data()["description"],
          imageUrl: element.data()["imageUrl"],
          price: element.data()["price"],
          productCategory:
              Product.stringtoProductCat(element.data()["productCategory"]),
          // isFav: element.data()["isFav"],
          isFav: isFav.contains(element.id),
          retailerId: element.data()["retailerId"],
          quantity: element.data()["quantity"],
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
  //  Need to fetch the product and the imageUrl associated with it, as user might be changing image
  //  So, we will need to update the image if needed & delete previous image
  //  The updated product is then sent to PendingProducts collection from where,
  //  it is sent to user products after approval from the admin
  Future<void> updateProduct(String id, Product product) async {
    try {
      final DocumentReference docRefApproval =
          FirebaseFirestore.instance.collection("PendingProducts").doc(id);

      await docRefApproval.set(
        {
          "title": product.title,
          "description": product.description,
          "imageUrl": product.imageUrl,
          "price": product.price,
          "productCategory":
              Product.productCattoString(product.productCategory),
          // "isFav": product.isFav,
          "retailerId": product.retailerId,
        },
      );
      Fluttertoast.showToast(
          msg: "Edits will be visible after approval by admin");
    } catch (error) {
      throw error;
    }
  }

  //  Function to delete product
  //  Also, delete the image associated with the product (by fetching it's reference from url)
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
            FirebaseStorage.instance
                .getReferenceFromUrl(value.data()["imageUrl"])
                .then(
              (imageRef) {
                imageRef.delete().then(
                  (_) {
                    docRef.delete();
                  },
                );
              },
            );
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

  //  Function to fetch product by category
  List<Product> getProductsByCategory(ProductCategory productCategory) {
    return _productItems
        .where((element) => element.productCategory == productCategory)
        .toList();
  }

  //  Function to reload products from firestore and storing fetched products to our list of products
  //  Used for pull down to refresh
  Future<void> reloadPendingProducts() async {
    final CollectionReference c =
        FirebaseFirestore.instance.collection("PendingProducts");

    List<Product> _fetchedProducts = [];
    try {
      c.snapshots().listen((event) {
        if (event.docChanges == null) {
          return;
        }
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
                retailerId: element.doc.data()["retailerId"],
                quantity: element.doc.data()["quantity"],
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
              // isFav: _fetchedProducts[modifyIndex].isFav,
              retailerId: element.doc.data()["retailerId"],
              quantity: element.doc.data()["quantity"],
            );
          } else if (element.type == DocumentChangeType.removed) {
            print("remove");
            _fetchedProducts.removeWhere((el) => el.id == element.doc.id);
          }
          print(_fetchedProducts.length);
          _pendingProducts = _fetchedProducts;
          notifyListeners();
          reloadProducts();
        });
      });
    } catch (error) {
      throw error;
    }
  }

  List<Product> get getPendingProductItems {
    return [..._pendingProducts];
  }

  //  Product approved by admin
  //  Add to all products, remove from pending products
  Future<void> approveProduct(String id, BuildContext context) async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection("Products").doc(id);

    //  flag to know whether product modified or added
    bool flag = true;

    final _updatedData = await FirebaseFirestore.instance
        .collection("PendingProducts")
        .doc(id)
        .get();
    docRef.get().then(
      (value) {
        //  If product was modified
        if (value.exists) {
          flag = false;
          String _fetchedImageUrl = value.data()["imageUrl"];

          docRef.set(
            {
              "title": _updatedData.data()["title"],
              "description": _updatedData.data()["description"],
              "imageUrl": _updatedData.data()["imageUrl"],
              "price": _updatedData.data()["price"],
              "productCategory": _updatedData.data()["productCategory"],
              // "isFav": _updatedData.data()["isFav"],
              "retailerId": _updatedData.data()["retailerId"],
              "quantity": value.data()["quantity"],
            },
          );
          //  if image is also modified, delete previous image from Firebase Storage
          if (_fetchedImageUrl != _updatedData.data()["imageUrl"]) {
            FirebaseStorage.instance
                .getReferenceFromUrl(value.data()["imageUrl"])
                .then(
              (imageRef) {
                imageRef.delete();
              },
            );
          }
        }
        //  If new product was added
        else {
          docRef.set(
            {
              "title": _updatedData.data()["title"],
              "description": _updatedData.data()["description"],
              "imageUrl": _updatedData.data()["imageUrl"],
              "price": _updatedData.data()["price"],
              "productCategory": _updatedData.data()["productCategory"],
              // "isFav": _updatedData.data()["isFav"],
              "retailerId": _updatedData.data()["retailerId"],
              "quantity": 0,
            },
          );
        }
        //  Remove the item from pendingProducts
        FirebaseFirestore.instance
            .collection("PendingProducts")
            .doc(id)
            .delete();
      },
    ).then((value) {
      var provider = Provider.of<FcmProvider>(context, listen: false);
      //  If product was added, send addition notification
      if (flag) {
        provider.sendProductAcceptedMessage(
            _updatedData.data()["retailerId"], _updatedData.data()["title"]);
      }
      //  else send modification notification
      else {
        provider.sendProductModifiedMessage(
            _updatedData.data()["retailerId"], _updatedData.data()["title"]);
      }
    });
  }

  //  Product declined by admin
  Future<void> declineProduct(String id, BuildContext context, String reason,
      String retailerId, String productTitle) async {
    //  Remove the item from pendingProducts and send notification to user
    //  First remove the image from firebase storage
    Provider.of<FcmProvider>(context, listen: false)
        .sendProductRejectionReason(retailerId, productTitle, reason);
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection("PendingProducts").doc(id);
    docRef.get().then(
      (value) {
        //  If that product is present in collection
        if (value.exists) {
          FirebaseStorage.instance
              .getReferenceFromUrl(value.data()["imageUrl"])
              .then(
            (imageRef) {
              imageRef.delete().then(
                (_) {
                  docRef.delete();
                },
              );
            },
          );
        }
        docRef.delete();
      },
    );
  }

  //  Function to add product stock
  Future<void> addProductQuantity(String productId, int oldQuantity,
      int addedQuantity, String title, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("Products")
        .doc(productId)
        .update(
      {"quantity": oldQuantity + addedQuantity},
    );
    if (oldQuantity == 0) {
      await Provider.of<FcmProvider>(context, listen: false)
          .sendProductInStockToSubscribers(productId, title);
    }
    notifyListeners();
  }
}
