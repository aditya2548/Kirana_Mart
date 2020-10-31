import '../models/orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chart extends StatelessWidget {
  final List<OrderItem> lastWeekOrders;
  Chart(this.lastWeekOrders);

  //  generates last 7 days total amount spent
  double get weeklyTotalSum {
    return groupedTransactionValues.fold(0.0, (sum, element) {
      return sum += element["amount"];
    });
  }

  //  Generates grouped transaction values for the last 7 days
  List<Map<String, Object>> get groupedTransactionValues {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(
        Duration(days: index),
      );
      double totalSum = 0.0;
      for (var i = 0; i < lastWeekOrders.length; i++) {
        if (lastWeekOrders[i].dateTime.day == weekDay.day &&
            lastWeekOrders[i].dateTime.month == weekDay.month &&
            lastWeekOrders[i].dateTime.year == weekDay.year) {
          totalSum += lastWeekOrders[i].amount;
        }
      }
      return {
        "day": DateFormat.E().format(weekDay).substring(0, 3),
        "amount": totalSum,
      };
    }).reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColorDark,
      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
      elevation: 6,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: groupedTransactionValues.map((data) {
            return Flexible(
              fit: FlexFit.tight,
              child: ChartBar(
                data["day"],
                data["amount"],
                weeklyTotalSum,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ChartBar extends StatelessWidget {
  final String label;
  final double amountSpent;
  final double totalAmountSpent;

  ChartBar(this.label, this.amountSpent, this.totalAmountSpent);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      return Column(
        children: <Widget>[
          Container(
            height: constraint.maxHeight * 0.15,
            child: FittedBox(
              child: Text("Rs.${this.amountSpent.toStringAsFixed(0)}",
                  style: TextStyle(
                      color: Theme.of(context).highlightColor, fontSize: 5)),
            ),
          ),
          SizedBox(
            height: constraint.maxHeight * 0.05,
          ),
          Container(
            height: constraint.maxHeight * 0.6,
            width: 15,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.pink[900],
                      width: 1,
                    ),
                    color: Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: totalAmountSpent != 0
                      ? amountSpent / totalAmountSpent
                      : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: constraint.maxHeight * 0.05,
          ),
          Container(
            height: constraint.maxHeight * 0.15,
            child: FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).highlightColor,
                  fontSize: 5,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
