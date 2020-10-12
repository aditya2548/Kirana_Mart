import '../models/product_provider.dart';
import '../widgets/product_item.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //  Fetch product list using Provider
    final productListProvider = Provider.of<ProductsProvider>(context);
    final favProductList = productListProvider.getFavoriteProductItems;
    return Column(
      children: [
        FlatButton.icon(
            onPressed: () {
              productListProvider.reloadFavorites();
            },
            icon: Icon(Icons.refresh),
            label: Text("Reload favorites")),
        Flexible(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            //  Not using ChangeNotifierProvider with builder method because that case gets buggy when
            //  Widgets get recycled,as we are changing the widget data in recycling
            //  Here widget gets attached to changing data instead of provider being attahced to changing data
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: favProductList[index],
              child: ProductItem(),
            ),
            padding: const EdgeInsets.all(10),
            itemCount: favProductList.length,
          ),
        ),
      ],
    );
  }
}
