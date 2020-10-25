import '../dialog/custom_dialog.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

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
  //  Controller for gridview.builder
  // ScrollController _scrollController = ScrollController();
  //  variable to show progressIndicator while fetching products
  //  Variable to check if more products available or not
  var _moreAvailable = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<ProductsProvider>(context, listen: false)
        .listenToProductsRealTime()
        .then((_) {
      Future.delayed(Duration(milliseconds: 1500)).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    }).catchError((error) {
      CustomDialog.generalErrorDialog(context);
    });

    // Provider.of<ProductsProvider>(context, listen: false)
    //     .listenToProductsRealTime();

    //  Listener for scroll controller, to fetch more products when we have only 1/4th of available products left
    //  And only when more products are available
    //   _scrollController.addListener(() {
    //     var provider = Provider.of<ProductsProvider>(context, listen: false);
    //     double maxScroll = _scrollController.position.maxScrollExtent;
    //     double currentScroll = _scrollController.position.pixels;
    //     double delta = MediaQuery.of(context).size.height * 0.25;

    //     //  Show message at bottom that no more products available
    //     if (!provider.moreProductsAvailable()) {
    //       //  if at the end of list
    //       if (maxScroll - currentScroll == 0) {
    //         setState(() {
    //           _moreAvailable = false;
    //         });
    //       }
    //       //  If no more products available, but we go back above in the list
    //       else {
    //         setState(() {
    //           _moreAvailable = true;
    //         });
    //       }
    //     }
    //     //  request for more data when reaching the end of list
    //     if (maxScroll - currentScroll <= delta &&
    //         provider.moreProductsAvailable()) {
    //       setState(() {
    //         _isFetching = true;
    //       });
    //       provider.requestMoreData().then((value) {
    //         setState(() {
    //           _isFetching = false;
    //         });
    //       });
    //     }
    //   });
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

//  Disposing scrollController to prevent memory leaks
  // @override
  // void dispose() {
  //   super.dispose();
  //   _scrollController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                headerCategoryItem(ProductCategory.Beverages,
                    Icons.emoji_food_beverage, context),
                headerCategoryItem(ProductCategory.CookingEssentials,
                    Icons.food_bank, context),
                headerCategoryItem(
                    ProductCategory.HouseHold, Icons.house_outlined, context),
                headerCategoryItem(ProductCategory.PackagedFoods,
                    Icons.fastfood_rounded, context),
                headerCategoryItem(
                    ProductCategory.PersonalCare, Icons.person, context),
              ],
            )),
        Container(
            margin: EdgeInsets.fromLTRB(8, 8, 10, 8),
            height: 2,
            color: Theme.of(context).accentColor),

        // StreamBuilder(
        //   stream: FirebaseFirestore.instance
        //       .collection("Products")
        //       .orderBy("title")
        //       .snapshots(),
        //   builder: (ctx, snapshot) {
        //     if (snapshot.hasData) {
        //       // print(snapshot.data.documents[0]["title"]);
        //       // return Text("Fethed");
        //       return Container(
        //         height: 400,
        //         child: GridView.builder(
        //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //             crossAxisCount: 2,
        //             childAspectRatio: 1,
        //             crossAxisSpacing: 15,
        //             mainAxisSpacing: 15,
        //           ),
        //           itemBuilder: (ctx, index) {
        //             DocumentSnapshot product = snapshot.data.documents[index];
        //             return ChangeNotifierProvider.value(
        //               value: Product(
        //                 id: product.id,
        //                 title: product["title"],
        //                 description: product["description"],
        //                 imageUrl: product["imageUrl"],
        //                 price: product["price"],
        //                 productCategory: Product.stringtoProductCat(
        //                     product["productCategory"]),
        //                 retailerId: product["retailerId"],
        //               ),
        //               child: ProductItem(),
        //             );
        //           },
        //           // {
        //           //   DocumentSnapshot product = snapshot.data.documents[index];
        //           //   return Text(product["title"]);
        //           //   // return ProductItem();
        //           // },
        //           padding: const EdgeInsets.all(10),
        //           itemCount: snapshot.data.documents.length,
        //         ),
        //       );
        //     } else {
        //       return Text("LOoading");
        //     }
        //   },
        // ),

        //  Using consumer instead of Provider as we don't need the complete widget to
        //  re-build everytime, just the products grid needs to be re-built

        Consumer<ProductsProvider>(
          builder: (ctx, productList, child) => Flexible(
            //  RefreshIndicator to re-fetch the products list
            child: LazyLoadScrollView(
              scrollOffset: 20,
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
        //  To be shown at the bottm, only when we reach the bottom and no more products are available
        if (!_moreAvailable)
          Container(
            margin: EdgeInsets.only(top: 0),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("No More Products Available"),
            ),
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
