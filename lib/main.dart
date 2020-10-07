import './models/product_provider.dart';
import './screens/product_desc_screen.dart';
import './screens/products_list_screen.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //  change notifier for changes in ProdutsProvider(list of products)
    return ChangeNotifierProvider(
      create: (_) => ProductsProvider(),
      child: MaterialApp(
        title: "Kirana Mart",
        theme: ThemeData(
          primarySwatch: Colors.purple,
          brightness: Brightness.dark,
          accentColor: Colors.deepOrange,
          primaryColor: Colors.purple,
          fontFamily: "QuickSand",
        ),
        home: ProductsListScreen(),
        routes: {
          ProductDescription.routeName: (ctx) => ProductDescription(),
        },
      ),
    );
  }
}
