import '../models/product_provider.dart';
import '../widgets/product_item.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProductsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kirana Mart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ProductGrid(),
    );
  }
}

//  ProductGrid seperated into seperate grid so that only this portion updates
//  when there is any updates in the ProductProvider

class ProductGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //  Fetch product list using Provider
    final productList = Provider.of<ProductsProvider>(context).getProductItems;
    //  Individual product item
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      //  Not using ChangeNotifierProvider with builder method because in that case,
      //  Widgets get recycled, we are changing the widget data in recycling
      //  Here widget gets attached to changing data instead of provider being attahced to changing data
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: productList[index],
        child: ProductItem(),
      ),
      padding: const EdgeInsets.all(10),
      itemCount: productList.length,
    );
  }
}
