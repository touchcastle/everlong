import 'package:flutter/material.dart';

class RecordContainer extends StatelessWidget {
  final BoxDecoration decoration;
  final Widget child;
  final double height;
  RecordContainer({
    required this.decoration,
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: height,
      child: Container(
          decoration: decoration,
          height: height,
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: child),
    );
  }
}
