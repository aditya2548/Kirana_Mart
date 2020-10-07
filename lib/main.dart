import './screens/home_page_tabs_screen.dart';
import './models/product_provider.dart';
import './screens/product_desc_screen.dart';

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
          primarySwatch: Colors.teal,
          brightness: Brightness.dark,
          accentColor: Colors.blue,
          primaryColor: Colors.teal[900],
          fontFamily: "QuickSand",
        ),
        home: HomePageTabsScreen(),
        routes: {
          ProductDescription.routeName: (ctx) => ProductDescription(),
        },
      ),
    );
  }
}
