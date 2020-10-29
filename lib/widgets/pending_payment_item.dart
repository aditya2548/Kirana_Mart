import '../models/data_model.dart';
import 'package:flutter/material.dart';
import '../models/fcm_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

//  Single ExpansionTile item to show upiId of retailer and amount to be paid
//  Tile is green if payment completed, else it's red
//  Also includes a checkbox to alter status after payment by admin
class PendingPaymentItem extends StatefulWidget {
  final FcmProvider paymentsData;
  final int index;
  PendingPaymentItem({this.paymentsData, this.index});

  @override
  _PendingPaymentItemState createState() => _PendingPaymentItemState();
}

class _PendingPaymentItemState extends State<PendingPaymentItem> {
  void toggleCompletedStatus(String id, bool incomplete) {
    FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("PendingPayments")
        .doc(id)
        .update({"incomplete": incomplete});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      color: widget.paymentsData.getPendingPayments[widget.index].incomplete ==
              true
          ? Colors.pink[900]
          : Theme.of(context).primaryColor,
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(5),
        childrenPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        title: Container(
          child: Text(
            "${widget.paymentsData.getPendingPayments[widget.index].retailerUpi} -> ${widget.paymentsData.getPendingPayments[widget.index].amount.toString()}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Text(
          DateFormat("dd MMM yyyy, HH:mm").format(
              widget.paymentsData.getPendingPayments[widget.index].dateTime),
        ),
        children: [
          widget.paymentsData.getPendingPayments[widget.index].incomplete ==
                  true
              ? Row(
                  children: [
                    Checkbox(
                        value: !widget.paymentsData
                            .getPendingPayments[widget.index].incomplete,
                        onChanged: (value) {
                          toggleCompletedStatus(
                              widget.paymentsData
                                  .getPendingPayments[widget.index].id,
                              !value);
                          setState(() {
                            widget.paymentsData.getPendingPayments[widget.index]
                                .incomplete = !value;
                          });
                        }),
                    Text(DataModel.completePayment),
                  ],
                )
              : Row(
                  children: [
                    Checkbox(
                        activeColor: Theme.of(context).primaryColorDark,
                        value: !widget.paymentsData
                            .getPendingPayments[widget.index].incomplete,
                        onChanged: (value) {
                          toggleCompletedStatus(
                              widget.paymentsData
                                  .getPendingPayments[widget.index].id,
                              !value);
                          setState(() {
                            widget.paymentsData.getPendingPayments[widget.index]
                                .incomplete = !value;
                          });
                        }),
                    Text(DataModel.paymentCompleted),
                  ],
                )
        ],
        leading:
            widget.paymentsData.getPendingPayments[widget.index].incomplete ==
                    true
                ? Icon(Icons.warning)
                : Icon(Icons.tag_faces),
      ),
    );
  }
}
