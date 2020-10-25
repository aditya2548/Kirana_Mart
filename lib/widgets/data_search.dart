import '../models/product.dart';
import '../models/product_provider.dart';
import '../widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  Class to show the search bar to search for products based on their names
class DataSearch extends SearchDelegate<Product> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Theme.of(context).primaryColor,
      primaryIconTheme: IconThemeData(
        color: Colors.white,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for appbar
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon for left
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // show when someone searches for something
    final List<Product> productList = query.isEmpty
        ? []
        : Provider.of<ProductsProvider>(context).getProductItemsOnSearch(query);
    return GridView.builder(
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
      itemBuilder: (ctx, index) => ChangeNotifierProvider<Product>.value(
        value: productList[index],
        child: ProductItem(),
      ),
      padding: const EdgeInsets.all(10),
      itemCount: productList.length,
    );
    // throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final List<Product> productList = query.isEmpty
        ? []
        : Provider.of<ProductsProvider>(context).getProductItemsOnSearch(query);
    return GridView.builder(
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
      itemBuilder: (ctx, index) => ChangeNotifierProvider<Product>.value(
        value: productList[index],
        child: ProductItem(),
      ),
      padding: const EdgeInsets.all(10),
      itemCount: productList.length,
    );
  }
}
