import 'package:flutter/material.dart';

enum LoadingStatus { LOADING, NOTLOADING }

//  Widget to implement lazy loading
class LazyLoading extends StatefulWidget {
  //  widget whose data we're listening to
  final Widget child;
  // function to be called when child reaches the end of the list (determined by the off-set)
  final Function onEndOfPage;
  // Off-set after which lazy loading is triggered
  final int offSet;
  //  To determine that loading of future data is done or not
  final bool isLoading;

  @override
  State<StatefulWidget> createState() => LazyLoadingState();

  LazyLoading({
    @required this.child,
    @required this.onEndOfPage,
    this.isLoading = false,
    this.offSet = 100,
  });
}

class LazyLoadingState extends State<LazyLoading> {
  LoadingStatus loadMoreStatus = LoadingStatus.NOTLOADING;

  //  To change the load more status accordingly to not loading if
  //  widget's isLoading is false
  @override
  void didUpdateWidget(LazyLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading) {
      loadMoreStatus = LoadingStatus.NOTLOADING;
    }
  }

  @override
  Widget build(BuildContext context) {
    //  wrapping our child list/grid in a notification listener to listen to
    //  notifications from the child
    return NotificationListener(
        child: widget.child,
        onNotification: (notification) {
          //  if user scrolls the page, we get this notification
          //  Check ->
          //    max scroll extent is greater than current scroll position and
          //    the difference between them is less than or equal to the offset
          //    If that's true, we know that we need more data,
          //    but load more only when loading status was false, to avoid repeated calling for data
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.maxScrollExtent >
                    notification.metrics.pixels &&
                notification.metrics.maxScrollExtent -
                        notification.metrics.pixels <=
                    widget.offSet) {
              if (loadMoreStatus != null &&
                  loadMoreStatus == LoadingStatus.NOTLOADING) {
                loadMoreStatus = LoadingStatus.LOADING;
                widget.onEndOfPage();
              }
            }
            return true;
          }

          //  if user has reached the end of max scroll extent
          //  if overscroll is >0 -> user trying to fetch more products at end of list
          //  if not loading already, try to fetch more products
          //  And set moreAvailable to false
          if (notification is OverscrollNotification) {
            if (notification.overscroll > 0) {
              if (loadMoreStatus != null &&
                  loadMoreStatus == LoadingStatus.NOTLOADING) {
                loadMoreStatus = LoadingStatus.LOADING;
                widget.onEndOfPage();
              }
            }
            return true;
          }
          return false;
        });
  }
}
