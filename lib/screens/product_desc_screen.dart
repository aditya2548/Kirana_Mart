import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';

import '../models/cart_provider.dart';
import '../widgets/product_review.dart';
import '../models/product_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ProductDescription extends StatefulWidget {
  static const routeName = "/product_desc";

  @override
  _ProductDescriptionState createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  //  Quantity of items to be purchased
  int _quantity = 1;

  //  Fetch retailer details when screen is built for 1st time
  String retailerName = "";
  String retailerAddress = "";
  bool _firstFetch = true;

  @override
  Widget build(BuildContext context) {
    //  product id fetched through modalroute
    final productId = ModalRoute.of(context).settings.arguments as String;
    final CartProvider cartItems =
        Provider.of<CartProvider>(context, listen: false);

    //  complete product fetched from provider using product id
    //  listen set to false as product description need not to be re-built when product list changes
    //  when notifyListener is being called
    final product = Provider.of<ProductsProvider>(context, listen: false)
        .getProductFromId(productId);

    final productReviewList = product.getReviews;

    //  Function to add item to cart with specified quantity
    void addToCart() {
      cartItems.addItemWithQuantity(
          product.id, product.price, product.title, _quantity, context);
      setState(() {
        _quantity = 1;
      });
    }

    if (_firstFetch == true) {
      FirebaseFirestore.instance
          .collection("User")
          .doc(product.retailerId)
          .collection("MyData")
          .get()
          .then((value) {
        setState(() {
          retailerName = value.docs.first.data()["name"];
          retailerAddress = value.docs.first.data()["address"];
          _firstFetch = false;
        });
      });
    }
    //  Product details, containing:
    //    ->  product image
    //    ->  Alert text if stock is less than 10
    //    ->  product name
    //    ->  product price per unit
    //    ->  product rating(in stars) and total number of ratings
    //    ->  product description
    //    ->  product quantity to be added and an ADD TO CART button
    //    ->  product reviews if present
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Center(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Card(
                      elevation: 15,
                      margin: EdgeInsets.only(top: 100, bottom: 20),
                      color: Theme.of(context).primaryColor,
                      child: Container(
                        padding: EdgeInsets.only(top: 100, bottom: 30),
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (product.quantity <= 10 && product.quantity > 0)
                              Text(
                                "Hurry, only ${product.quantity} left in stock!!",
                                style: TextStyle(color: Colors.red),
                              ),
                            if (product.quantity == 0)
                              Text(
                                "Sorry, product out of stock :(",
                                style: TextStyle(color: Colors.red),
                              ),
                            Text(
                              product.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 25,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Rs. ${product.price}",
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Shimmer.fromColors(
                              baseColor: Colors.yellow[900],
                              highlightColor: Colors.yellow[100],
                              period: Duration(seconds: 1),
                              child: Container(
                                child: SmoothStarRating(
                                  isReadOnly: true,
                                  allowHalfRating: true,
                                  starCount: 5,
                                  rating: product.getAverageRating,
                                  size: 27.0,
                                  color: Colors.orange,
                                  borderColor: Colors.deepOrange,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(product.getReviewCount <= 1
                                ? "( ${product.getReviewCount} review found)"
                                : "( ${product.getReviewCount} reviews found)"),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              color: Theme.of(context).primaryColorDark,
                              child: Text("Retailer"),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                              child: Text(
                                retailerName.toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(retailerAddress),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 25),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    color: Theme.of(context).primaryColorDark,
                                    child: Text(
                                      'Quantity',
                                    ),
                                    margin: EdgeInsets.only(bottom: 15),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.green,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(
                                              () {
                                                if (_quantity >=
                                                    product.quantity) {
                                                  Fluttertoast.cancel();
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Sorry, limited stocks available",
                                                      backgroundColor:
                                                          Colors.red);
                                                  return;
                                                }
                                                _quantity += 1;
                                              },
                                            );
                                          },
                                          icon: Center(
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: Text(
                                          _quantity.toString(),
                                        ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.red,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(
                                              () {
                                                if (_quantity == 1) return;
                                                _quantity -= 1;
                                              },
                                            );
                                          },
                                          icon: Center(
                                            child: Icon(
                                              Icons.remove,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: 180,
                              child: RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  child: Text(
                                    "ADD TO CART",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    addToCart();
                                  }),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              color: Theme.of(context).primaryColorDark,
                              child: Text(
                                "Product Details:",
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: 260,
                              child: Card(
                                elevation: 15,
                                color: Colors.teal[800],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    product.description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              color: Theme.of(context).primaryColorDark,
                              child: Text(
                                "Reviews:",
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            product.getReviewCount == 0
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("No reviews found."),
                                  )
                                : Container(
                                    height: 200,
                                    child: ListView.builder(
                                      itemBuilder: (ctx, index) =>
                                          ProductReview(productReviewList[index]
                                              .values
                                              .toList()[0]),
                                      itemCount: product.getReviewCount,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Card(
                      elevation: 25,
                      child: Container(
                        color: Theme.of(context).primaryColorDark,
                        padding: EdgeInsets.all(8),
                        width: 200,
                        height: 160,
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
