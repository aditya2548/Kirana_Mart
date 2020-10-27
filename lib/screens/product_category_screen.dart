import '../widgets/custom_app_bar_title.dart';

import '../models/product.dart';
import '../models/product_provider.dart';
import '../widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsByCategoryScreen extends StatelessWidget {
  static const routeName = "/products_category_screen";

  @override
  Widget build(BuildContext context) {
    final ProductCategory _productCategory =
        ModalRoute.of(context).settings.arguments;
    final productsData = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: CustomAppBarTitle(
            name: Product.productCattoString(_productCategory),
            icondata: Icons.shopping_bag),
      ),
      body: productsData.getProductsByCategory(_productCategory).length <= 0
          ? Center(
              child: Text(
              "Sorry, no products found in\n ${Product.productCattoString(_productCategory)} category",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).errorColor,
              ),
              textAlign: TextAlign.center,
            ))
          : RefreshIndicator(
              onRefresh: () => productsData.reloadProducts(),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                //  Not using ChangeNotifierProvider with builder method because in that case,
                //  Widgets get recycled, we are changing the widget data in recycling
                //  Here widget gets attached to changing data instead of provider being attahced to changing data
                itemBuilder: (ctx, index) =>
                    ChangeNotifierProvider<Product>.value(
                  value: productsData
                      .getProductsByCategory(_productCategory)[index],
                  child: ProductItem(),
                ),
                padding: const EdgeInsets.all(10),
                itemCount:
                    productsData.getProductsByCategory(_productCategory).length,
              ),
            ),
    );
  }
}
