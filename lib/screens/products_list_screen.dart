import '../models/product.dart';
import '../models/product_provider.dart';
import '../widgets/product_item.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProductsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            "Categories",
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        //  Horizontal scroll view with different categories
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                headerCategoryItem(
                    Product.productCattoString(ProductCategory.Beverages),
                    Icons.emoji_food_beverage,
                    onPressed: () {}),
                headerCategoryItem(
                    Product.productCattoString(
                        ProductCategory.CookingEssentials),
                    Icons.food_bank,
                    onPressed: () {}),
                headerCategoryItem(
                    Product.productCattoString(ProductCategory.HouseHold),
                    Icons.house_outlined,
                    onPressed: () {}),
                headerCategoryItem(
                    Product.productCattoString(ProductCategory.PackagedFoods),
                    Icons.fastfood_rounded,
                    onPressed: () {}),
                headerCategoryItem(
                    Product.productCattoString(ProductCategory.PersonalCare),
                    Icons.person,
                    onPressed: () {}),
              ],
            )),
        Container(
            margin: EdgeInsets.fromLTRB(8, 8, 10, 8),
            height: 2,
            color: Theme.of(context).accentColor),
        //  Using consumer instead of Provider as we don't need the complete widget to
        //  re-build everytime, just the products grid needs to be re-built
        Consumer<ProductsProvider>(
          builder: (ctx, productList, child) => Flexible(
            //  RefreshIndicator to re-fetch the products list
            child: RefreshIndicator(
              onRefresh: () =>
                  Provider.of<ProductsProvider>(context, listen: false)
                      .reloadProducts(),
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
                  value: productList.getProductItems[index],
                  child: ProductItem(),
                ),
                padding: const EdgeInsets.all(10),
                itemCount: productList.getProductItems.length,
              ),
            ),
          ),
        )
      ],
    );
  }
}

//  (UI)Widget for category icons
Widget headerCategoryItem(String name, IconData icon, {onPressed}) {
  return Container(
    margin: EdgeInsets.only(left: 15),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: 10),
            width: 50,
            height: 50,
            child: FloatingActionButton(
              shape: CircleBorder(),
              heroTag: name,
              onPressed: onPressed,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 35, color: Colors.black87),
            )),
        Text(
          name + ' ›',
          style: TextStyle(
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        )
      ],
    ),
  );
}
