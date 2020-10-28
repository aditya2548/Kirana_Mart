import '../dialog/custom_dialog.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import '../models/product_provider.dart';
import '../widgets/product_item.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  var _moreAvailable = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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

    Future.delayed(Duration(milliseconds: 1500)).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //  Fetch product list using Provider
    final productListProvider = Provider.of<ProductsProvider>(context);
    final favProductList = productListProvider.getFavoriteProductItems;
    return Column(
      children: [
        if (isLoading) LinearProgressIndicator(),
        LazyLoadScrollView(
          onEndOfPage: () => _loadMore(),
          child: RefreshIndicator(
            onRefresh: () {
              return productListProvider.fetchProductsRealTime();
            },
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
        ),
      ],
    );
  }
}
