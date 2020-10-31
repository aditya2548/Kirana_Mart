import '../models/lazy_load.dart';
import '../dialog/custom_dialog.dart';

import '../widgets/custom_app_bar_title.dart';

import '../models/product.dart';
import '../models/product_provider.dart';
import '../widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsByCategoryScreen extends StatefulWidget {
  static const routeName = "/products_category_screen";

  @override
  _ProductsByCategoryScreenState createState() =>
      _ProductsByCategoryScreenState();
}

class _ProductsByCategoryScreenState extends State<ProductsByCategoryScreen> {
  var _moreAvailable = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<ProductsProvider>(context, listen: false)
        .listenToProductsRealTime()
        .then((_) {
      Future.delayed(Duration(milliseconds: 1000)).then((value) {
        if (this.mounted)
          setState(() {
            isLoading = false;
          });
      });
    }).catchError((error) {
      CustomDialog.generalErrorDialog(context);
    });
  }

  //  Load more products
  Future _loadMore() async {
    if (_moreAvailable == false) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _moreAvailable = Provider.of<ProductsProvider>(context, listen: false)
        .moreProductsAvailable();
    await Provider.of<ProductsProvider>(context, listen: false)
        .requestMoreData();

    Future.delayed(Duration(milliseconds: 1000)).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProductCategory _productCategory =
        ModalRoute.of(context).settings.arguments;
    final productsData = Provider.of<ProductsProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: -5,
          title: CustomAppBarTitle(
              name: Product.productCattoString(_productCategory),
              icondata: Icons.shopping_bag),
        ),
        body: productsData.getProductsByCategory(_productCategory).length <= 0
            ? Stack(
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
                  Center(
                      child: Text(
                    "Sorry, no products found in\n ${Product.productCattoString(_productCategory)} category",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).errorColor,
                    ),
                    textAlign: TextAlign.center,
                  )),
                ],
              )
            : Stack(
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
                    children: [
                      if (isLoading) LinearProgressIndicator(),
                      Flexible(
                        child: LazyLoading(
                          onEndOfPage: () => _loadMore(),
                          child: RefreshIndicator(
                            onRefresh: () => productsData.reloadProducts(),
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
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
                                value: productsData.getProductsByCategory(
                                    _productCategory)[index],
                                child: ProductItem(),
                              ),
                              padding: const EdgeInsets.all(10),
                              itemCount: productsData
                                  .getProductsByCategory(_productCategory)
                                  .length,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
