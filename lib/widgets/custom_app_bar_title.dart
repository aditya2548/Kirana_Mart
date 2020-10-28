import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

//  Custom app bar to show screen name with an icon and a shimmer effect
class CustomAppBarTitle extends StatelessWidget {
  final String name;
  final IconData icondata;
  CustomAppBarTitle({this.icondata, this.name});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: Colors.amber,
      period: Duration(seconds: 2),
      child: Row(
        children: [
          SizedBox(
            height: AppBar().preferredSize.height - 10,
            width: AppBar().preferredSize.height - 10,
            child: Icon(icondata),
          ),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
