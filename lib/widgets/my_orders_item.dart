import '../models/data_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/review_bottom_sheet.dart';
import 'package:intl/intl.dart';

import '../models/orders_provider.dart';
import 'package:flutter/material.dart';

//  A single item present in mycart containing
//    -> product name
//    -> quantity of product
//    -> price per unit
//    -> button to add/edit review
class MyOrdersItem extends StatelessWidget {
  @required
  final OrderItem order;

  MyOrdersItem(this.order);

  @override
  Widget build(BuildContext context) {
    String title = order.productsList.length == 1
        ? " ${order.productsList.length} product. Total cost: Rs.${order.amount}"
        : " ${order.productsList.length} products. Total cost: Rs.${order.amount}";
    return Card(
      elevation: 20,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Colors.teal[900],
      child: ExpansionTile(
        trailing: Icon(Icons.arrow_circle_down_outlined),
        tilePadding: EdgeInsets.all(5),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              // fontSize: 11,
            ),
          ),
        ),
        subtitle: Center(
          child: Text(
            "Date: ${DateFormat("dd MMM yyyy, HH:mm").format(order.dateTime)} ",
            // style: TextStyle(fontSize: 10),
          ),
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, index) => Container(
              child: Card(
                elevation: 10,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  dense: true,
                  title: Text(order.productsList.toList()[index].title),
                  subtitle: Text(
                      "Rs. ${order.productsList.toList()[index].pricePerUnit} x ${order.productsList.toList()[index].quantity}"),
                  trailing: FlatButton(
                    color: Theme.of(context).primaryColorDark,
                    onPressed: () {
                      //  Bottom sheet to add/update product review
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (_) {
                            return NewReview(
                                order.productsList.toList()[index].productId);
                          });
                    },
                    child: Text(DataModel.REVIEW),
                  ),
                  leading: IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () async {
                        var url =
                            "tel:${order.productsList.toList()[index].retailerNumber}";
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          Fluttertoast.showToast(
                              msg: DataModel.SOMETHING_WENT_WRONG);
                        }
                      }),
                ),
              ),
            ),
            itemCount: order.productsList.length,
          ),
        ],
      ),
    );
  }
}
