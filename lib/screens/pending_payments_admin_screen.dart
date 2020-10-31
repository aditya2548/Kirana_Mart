import '../models/data_model.dart';

import '../widgets/custom_app_bar_title.dart';
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: -5,
          title: CustomAppBarTitle(
            name: DataModel.PENDING_PAYMENTS,
            icondata: Icons.timelapse,
          ),
        ),
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
            FutureBuilder(
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
                          Text(DataModel.PLEASE_WAIT),
                          DelayedDisplay(
                              delay: Duration(seconds: 5),
                              child: Text(
                                DataModel
                                    .CONNECT_TO_INTERNET_WARNING_FOR_CHANGES,
                                style: TextStyle(fontSize: 7),
                                textAlign: TextAlign.center,
                              ))
                        ],
                      ),
                    ),
                  );
                } else if (dataSnapShot.hasError) {
                  return Center(
                    child: Text(DataModel.SOMETHING_WENT_WRONG),
                  );
                } else {
                  //  Using consumer here as if we use provider here, whole stateless widget gets
                  //  re-rendered again, and we enter an infinite loop
                  return Consumer<FcmProvider>(
                    builder: (ctx, paymentsData, child) => paymentsData
                                .getPendingPayments.length ==
                            0
                        ? Container(
                            alignment: Alignment.center,
                            child: Text(DataModel.NO_NOTIFICATIONS),
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
          ],
        ),
        drawer: AppDrawer(DataModel.PENDING_PAYMENTS),
      ),
    );
  }
}
