import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';

import '../models/cart_provider.dart';
import '../screens/product_desc_screen.dart';
import '../models/product.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  Single card of a product item to be displayed in the product grid

class ProductItem extends StatefulWidget {
  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    final Product product = Provider.of<Product>(context);
    //  Function to get product header
    //  if it's quantity is less than 10
    //  or if it is out of stock
    Widget getHeader() {
      if (product.quantity <= 0) {
        return Container(
          color: Colors.red,
          alignment: Alignment.center,
          child: Text(
            "OUT OF STOCK",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
      } else if (product.quantity < 10) {
        return Container(
          color: Colors.yellow,
          alignment: Alignment.center,
          child: Text(
            "Only ${product.quantity} left",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
      }
      return null;
    }

    // cartprovider has listen false as no change of adding product on display screen
    final CartProvider cartItems =
        Provider.of<CartProvider>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      child: GridTile(
        child: GestureDetector(
          //  To go to product details when a product is clicked, but first fetch all the reviews
          onTap: () {
            Provider.of<Product>(context, listen: false)
                .fetchAllReviews()
                .then((value) {
              Navigator.of(context).pushNamed(ProductDescription.routeName,
                  arguments: product.id);
            });
          },
          //  Image of the product fetched through the image url
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.fill,
            //  Show loading spinner when fetching product
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Shimmer.fromColors(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 40, 40, 60),
                      child: Image.asset(
                        "assets/images/Kirana_mart_logo.png",
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  period: Duration(seconds: 1),
                  baseColor: Colors.red,
                  highlightColor: Colors.orange);
            },
          ),
        ),
        //  header to show unavailable if quantity <=0
        header: getHeader(),
        //  Row with children -> [Fav icon, (column of product title and price), add to cart icon]
        footer: Container(
          color: Colors.black87,
          child: Row(
            children: [
              IconButton(
                icon: Icon(product.isFav
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded),
                onPressed: () {
                  setState(() {
                    product.isFav = !product.isFav;
                  });
                  product.toggleFav(context);
                },
                color: Colors.red,
              ),
              Expanded(
                  child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      product.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "Rs. ${product.price.toString()}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        // fontSize: 6,
                        ),
                  ),
                ],
              )),
              IconButton(
                icon: Icon(Icons.add_shopping_cart_rounded),
                onPressed: () {
                  if (product.quantity < 1) {
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(
                        msg: "Sorry, product unavailable at the moment",
                        backgroundColor: Colors.red);
                    return;
                  }
                  cartItems.addItemWithQuantity(
                      product.id, product.price, product.title, 1, context);
                },
                color: Theme.of(context).accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
