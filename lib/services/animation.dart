import 'package:flutter/material.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/ui/views/device/device_box.dart';
import 'package:everlong/utils/constants.dart';

const Duration kTransitionDur = Duration(milliseconds: 500);
const Duration kLandingTransitionDur = Duration(milliseconds: 1500);

///Page Transition
RouteTransitionsBuilder kPageTransition =
    (context, animation, secondaryAnimation, child) {
  // const begin = Offset(1.0, 0.0);  //From center-right
  const begin = Offset(0.0, 1.0); //From center-bottom
  const end = Offset.zero;
  const curve = Curves.ease;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
};

/// Class for device's list re-order animation.
class ListAnimation {
  final GlobalKey<AnimatedListState> animateListKey = GlobalKey();

  /// Insert new item to target [index].
  void listViewInsert(int index) {
    if (animateListKey.currentState != null) {
      animateListKey.currentState!.insertItem(index,
          duration: Duration(milliseconds: kListAnimateDuration));
    }
  }

  /// Remove item from [index].
  void listViewRemove(int index, BLEDevice device) {
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return SizeTransition(sizeFactor: animation, child: DeviceBox(device));
    };
    animateListKey.currentState!.removeItem(index, builder,
        duration: Duration(milliseconds: kListAnimateDuration));
  }
}
