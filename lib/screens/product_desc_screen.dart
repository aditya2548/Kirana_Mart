import '../models/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDescription extends StatelessWidget {
  static const routeName = "/product_desc";
  @override
  Widget build(BuildContext context) {
    //  product id fetched through modalroute
    final productId = ModalRoute.of(context).settings.arguments as String;

    //  complete product fetched from provider using product id
    //  listen set to false as product description need not to be re-built when product list changes
    //  when notifyListener is being called
    final product = Provider.of<ProductsProvider>(context, listen: false)
        .getProductFromId(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        child: Card(
          elevation: 10,
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [],
          ),
        ),
      ),
    );
  }
}
