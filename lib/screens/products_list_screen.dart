import '../models/product_provider.dart';
import '../widgets/product_item.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProductsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //  Fetch product list using Provider
    final productList = Provider.of<ProductsProvider>(context).getProductItems;
    //  Individual product item
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "Categories",
          textAlign: TextAlign.left,
        ),
        SizedBox(
          height: 5,
        ),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [Text("A"), Text("A"), Text("A"), Text("A"), Text("A")],
            )),
        SizedBox(
          height: 10,
        ),
        Flexible(
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
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: productList[index],
              child: ProductItem(),
            ),
            padding: const EdgeInsets.all(10),
            itemCount: productList.length,
          ),
        ),
      ],
    );
  }
}
