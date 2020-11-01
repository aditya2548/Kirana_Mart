import '../models/data_model.dart';

import '../models/lazy_load.dart';

import '../dialog/custom_dialog.dart';

import '../screens/product_category_screen.dart';

import '../models/product.dart';
import '../models/product_provider.dart';
import '../widgets/product_item.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProductsListScreen extends StatefulWidget {
  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  //  Variable to check if more products available or not
  bool _moreAvailable;
  //  variable to show progressIndicator while fetching products
  bool isLoading = true;

  //  Load the initial batch of products
  @override
  void initState() {
    super.initState();
    _moreAvailable = Provider.of<ProductsProvider>(context, listen: false)
        .moreProductsAvailable();
    Provider.of<ProductsProvider>(context, listen: false)
        .listenToProductsRealTime()
        .then((_) {
      Future.delayed(Duration(milliseconds: 1500)).then((value) {
        if (this.mounted)
          setState(() {
            isLoading = false;
          });
      });
    }).catchError((error) {
      CustomDialog.generalErrorDialog(context);
    });
  }

  //  Function to load more products
  Future _loadMore() async {
    if (_moreAvailable == false) {
      return;
    }
    _moreAvailable = Provider.of<ProductsProvider>(context, listen: false)
        .moreProductsAvailable();
    setState(() {
      isLoading = true;
    });
    await Provider.of<ProductsProvider>(context, listen: false)
        .requestMoreData();

    Future.delayed(Duration(milliseconds: 1500)).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          color: Colors.black,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.elliptical(1200, 2200),
            ),
            color: Colors.grey[900],
          ),
          width: MediaQuery.of(context).size.width - 1.5,
          height: double.maxFinite,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Progress indicator if fetching products
            if (isLoading) LinearProgressIndicator(),

            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                DataModel.CATEGORIES,
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
                        ProductCategory.PersonalCare, Icons.person, context),
                    headerCategoryItem(ProductCategory.Beverages,
                        Icons.emoji_food_beverage, context),
                    headerCategoryItem(ProductCategory.CookingEssentials,
                        Icons.food_bank, context),
                    headerCategoryItem(ProductCategory.PackagedFoods,
                        Icons.fastfood_rounded, context),
                    headerCategoryItem(ProductCategory.HouseHold,
                        Icons.house_outlined, context),
                  ],
                )),
            Container(
              margin: EdgeInsets.fromLTRB(8, 8, 10, 8),
              height: 2,
              color: Theme.of(context).accentColor,
            ),
            //  Using consumer instead of Provider as we don't need the complete widget to
            //  re-build everytime, just the products grid needs to be re-built

            Consumer<ProductsProvider>(
              builder: (ctx, productList, child) => Flexible(
                //  RefreshIndicator to re-fetch the products list
                child: LazyLoading(
                  isLoading: isLoading,
                  onEndOfPage: () => _loadMore(),
                  child: RefreshIndicator(
                    onRefresh: () =>
                        Provider.of<ProductsProvider>(context, listen: false)
                            .fetchProductsRealTime(),
                    child: GridView.builder(
                      // controller: _scrollController,
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
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//  (UI)Widget for category icons
Widget headerCategoryItem(
    ProductCategory productCategory, IconData icon, BuildContext context) {
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
              heroTag: Product.productCattoString(productCategory),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  ProductsByCategoryScreen.routeName,
                  arguments: productCategory,
                );
              },
              backgroundColor: Colors.white,
              child: Icon(icon, size: 35, color: Colors.black87),
            )),
        Text(
          Product.productCattoString(productCategory) + ' ›',
          style: TextStyle(
              // fontSize: 10,
              ),
          textAlign: TextAlign.center,
        )
      ],
    ),
  );
}
