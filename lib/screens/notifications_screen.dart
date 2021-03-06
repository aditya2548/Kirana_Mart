import 'dart:ui';

import '../models/data_model.dart';

import '../models/fcm_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar_title.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = "/noifications_screen";
  @override
  Widget build(BuildContext context) {
    // var messagesList = Provider.of(context)
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            titleSpacing: -5,
            title: CustomAppBarTitle(
              icondata: Icons.notification_important,
              name: DataModel.MY_NOTIFICATIONS,
            )),
        body: FutureBuilder(
          future:
              Provider.of<FcmProvider>(context, listen: false).reloadMessages(),
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
                            DataModel.CONNECT_TO_INTERNET_WARNING_FOR_CHANGES,
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
                builder: (ctx, messageData, child) => messageData
                            .getMessages.length ==
                        0
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
                          Container(
                            alignment: Alignment.center,
                            child: Text(DataModel.NO_NOTIFICATIONS),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            Provider.of<FcmProvider>(context, listen: false)
                                .reloadMessages(),
                        child: Stack(
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
                            ListView.builder(
                              itemCount: messageData.getMessages.length,
                              itemBuilder: (ctx, index) => Container(
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  color: messageData.getMessages[index].error ==
                                          true
                                      ? Colors.pink[900]
                                      : Theme.of(context).primaryColor,
                                ),
                                child: ExpansionTile(
                                  tilePadding: EdgeInsets.all(5),
                                  childrenPadding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  title: Container(
                                      child: Text(
                                    messageData.getMessages[index].title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  subtitle: Text(
                                    DateFormat("dd MMM yyyy, HH:mm").format(
                                        messageData
                                            .getMessages[index].dateTime),
                                  ),
                                  children: [
                                    Text(messageData.getMessages[index].body)
                                  ],
                                  leading:
                                      messageData.getMessages[index].error ==
                                              true
                                          ? Icon(Icons.warning)
                                          : Icon(Icons.tag_faces),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            }
          },
        ),
        drawer: AppDrawer(DataModel.MY_NOTIFICATIONS),
      ),
    );
  }
}
