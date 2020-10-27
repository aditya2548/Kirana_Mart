import '../models/fcm_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/pending_payment_item.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PendingPaymentsAdminScreen extends StatefulWidget {
  static const routeName = "/pending_payments_admin_screen";

  @override
  _PendingPaymentsAdminScreenState createState() =>
      _PendingPaymentsAdminScreenState();
}

class _PendingPaymentsAdminScreenState
    extends State<PendingPaymentsAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pending Payments"),
      ),
      body: FutureBuilder(
        future: Provider.of<FcmProvider>(context, listen: false)
            .reloadPendingPayments(),
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularProgressIndicator(),
                    Text("Please wait"),
                    DelayedDisplay(
                        delay: Duration(seconds: 5),
                        child: Text(
                          "Please connect to internet.\nChanges will be reflected after internet connection is regained",
                          style: TextStyle(fontSize: 7),
                          textAlign: TextAlign.center,
                        ))
                  ],
                ),
              ),
            );
          } else if (dataSnapShot.hasError) {
            return Center(
              child: Text("Something went wrong\n Please try again later."),
            );
          } else {
            //  Using consumer here as if we use provider here, whole stateless widget gets
            //  re-rendered again, and we enter an infinite loop
            return Consumer<FcmProvider>(
              builder: (ctx, paymentsData, child) =>
                  paymentsData.getPendingPayments.length == 0
                      ? Container(
                          alignment: Alignment.center,
                          child: Text("No notifications for you now"),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              Provider.of<FcmProvider>(context, listen: false)
                                  .reloadPendingPayments(),
                          child: ListView.builder(
                            itemCount: paymentsData.getPendingPayments.length,
                            itemBuilder: (ctx, index) => PendingPaymentItem(
                              paymentsData: paymentsData,
                              index: index,
                            ),
                          ),
                        ),
            );
          }
        },
      ),
      drawer: AppDrawer("Pending Payments"),
    );
  }
}
