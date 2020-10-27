import '../widgets/custom_app_bar_title.dart';
import '../models/product_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/pending_user_product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//  Screen only visible to the admin
//  Admin can approve or decline pendingProducts
class AdminScreen extends StatefulWidget {
  static const routeName = '/admin_screen';

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProductsProvider>(context, listen: false)
        .reloadPendingProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomAppBarTitle(
            name: "Approve Products", icondata: Icons.done_all),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                Provider.of<ProductsProvider>(context, listen: false)
                    .reloadPendingProducts();
              })
        ],
      ),
      drawer: AppDrawer("Approve Products"),
      body: Consumer<ProductsProvider>(
        builder: (ctx, ordersData, child) => RefreshIndicator(
          onRefresh: () {
            return Provider.of<ProductsProvider>(context, listen: false)
                .reloadPendingProducts();
          },
          child: ordersData.getPendingProductItems.length <= 0
              ? Center(
                  child: Text("No Pending Products"),
                )
              : ListView.builder(
                  itemCount: ordersData.getPendingProductItems.length,
                  itemBuilder: (ctx, index) => PendingUserProductItem(
                    id: ordersData.getPendingProductItems[index].id,
                    title: ordersData.getPendingProductItems[index].title,
                    description:
                        ordersData.getPendingProductItems[index].description,
                    imageUrl: ordersData.getPendingProductItems[index].imageUrl,
                    price: ordersData.getPendingProductItems[index].price,
                    productCategory: ordersData
                        .getPendingProductItems[index].productCategory,
                    retailerId:
                        ordersData.getPendingProductItems[index].retailerId,
                  ),
                ),
        ),
      ),
    );
  }
}
