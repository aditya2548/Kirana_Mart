import '../screens/product_desc_screen.dart';
import '../models/product.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  Single card of a product item to be displayed in the product grid

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Product product = Provider.of<Product>(context);
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      child: GridTile(
        child: GestureDetector(
          //  To go to product details when a product is clicked
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProductDescription.routeName, arguments: product.id);
          },
          //  Image of the product fetched through the image url
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.fill,
          ),
        ),
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
                  product.toggleFav();
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
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "Rs. ${product.price.toString()}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 6,
                    ),
                  ),
                ],
              )),
              IconButton(
                icon: Icon(Icons.add_shopping_cart_rounded),
                onPressed: () {},
                color: Theme.of(context).accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
