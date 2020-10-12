import '../models/product.dart';
import 'package:flutter/material.dart';

//  Widget to return a review intem with rating, username and review
class ProductReview extends StatelessWidget {
  final Review review;
  ProductReview(this.review);

  //  Function to fetch color as per rating
  Color getColor(int stars) {
    switch (stars) {
      case 0:
        return Colors.redAccent[700];
      case 1:
        return Colors.deepOrange;
      case 2:
        return Colors.amber;
      case 3:
        return Colors.lime;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green[800];
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              height: 40,
              margin: EdgeInsets.only(right: 15),
              width: 50,
              color: getColor(review.stars),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    review.stars.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Text(
                    "User: ${review.username}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 200,
                    child: Text(
                      review.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 15,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
