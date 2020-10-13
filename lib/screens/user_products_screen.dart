import '../screens/edit_user_product_screen.dart';

import '../widgets/app_drawer.dart';

import '../models/product_provider.dart';
import '../widgets/user_products_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Contains a list of all the products provided by the user
class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user_products_screen";
  @override
  Widget build(BuildContext context) {
    final myProductsData =
        Provider.of<ProductsProvider>(context).getProductItems;
    return Scaffold(
      appBar: AppBar(
        title: const Text("My products"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context)
                .pushNamed(EditUserProductScreen.routeName),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () =>
            Navigator.of(context).pushNamed(EditUserProductScreen.routeName),
      ),
      //  RefreshIndicator to re-fetch the products list
      body: RefreshIndicator(
        onRefresh: () => Provider.of<ProductsProvider>(context, listen: false)
            .reloadProducts(),
        child: ListView.builder(
          itemCount: myProductsData.length,
          itemBuilder: (ctx, index) => UserProductItem(
            id: myProductsData[index].id,
            title: myProductsData[index].title,
            description: myProductsData[index].description,
            imageUrl: myProductsData[index].imageUrl,
            price: myProductsData[index].price,
            productCategory: myProductsData[index].productCategory,
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
