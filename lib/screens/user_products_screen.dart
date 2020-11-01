import 'package:Kirana_Mart/models/lazy_load.dart';

import '../models/data_model.dart';

import '../widgets/custom_app_bar_title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:upi_pay/upi_pay.dart';

import '../screens/edit_user_product_screen.dart';

import '../widgets/app_drawer.dart';

import '../models/product_provider.dart';
import '../widgets/user_products_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  Contains a list of all the products provided by the user
//  Instead of using a stateful widget with initState to fetch data and show loading screen,
//  FutureBuilder used with a steteless widget
class UserProductsScreen extends StatefulWidget {
  static const routeName = "/user_products_screen";

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  String retailerUpiId = "";
  var _moreAvailable = true;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    Provider.of<ProductsProvider>(context, listen: false)
        .listenToProductsRealTime();
    FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("MyData")
        .get()
        .then((value) {
      setState(() {
        retailerUpiId = value.docs.first.data()["upi"];
      });
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
    //  Don't allow adding products if email is not verified or retailer hasn't mentioned his upi id
    if (!FirebaseAuth.instance.currentUser.emailVerified) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Container(
              child: Text(
                DataModel.VERIFY_MAIL_TO_SELL,
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
            ),
          ),
        ),
      );
    }
    //  If upiId not mentioned/ invalid, don't allow the user to sell anything
    if (retailerUpiId.trim() == "" ||
        !UpiPay.checkIfUpiAddressIsValid(retailerUpiId)) {
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  DataModel.VALID_UPI_TO_SELL,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: -5,
          title: CustomAppBarTitle(
            name: DataModel.MY_PRODUCTS,
            icondata: Icons.edit_outlined,
          ),
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
        body: Stack(
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
            Consumer<ProductsProvider>(
              builder: (ctx, myproductsData, child) => Column(
                children: [
                  Container(
                      color: Colors.amber,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      alignment: Alignment.center,
                      child: Text(
                        DataModel.PRODUCTS_VISIBLE_AFTER_ADMIN_VERIFICATION,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      )),
                  Flexible(
                    child: LazyLoading(
                      onEndOfPage: () => _loadMore(),
                      child: RefreshIndicator(
                        onRefresh: () {
                          return Provider.of<ProductsProvider>(context,
                                  listen: false)
                              .reloadProducts();
                        },
                        child: ListView.builder(
                          itemCount: myproductsData.getMyProducts().length,
                          itemBuilder: (ctx, index) => UserProductItem(
                            id: myproductsData.getMyProducts()[index].id,
                            title: myproductsData.getMyProducts()[index].title,
                            description: myproductsData
                                .getMyProducts()[index]
                                .description,
                            imageUrl:
                                myproductsData.getMyProducts()[index].imageUrl,
                            price: myproductsData.getMyProducts()[index].price,
                            productCategory: myproductsData
                                .getMyProducts()[index]
                                .productCategory,
                            quantity:
                                myproductsData.getMyProducts()[index].quantity,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: AppDrawer(DataModel.MY_PRODUCTS),
      ),
    );
  }
}
