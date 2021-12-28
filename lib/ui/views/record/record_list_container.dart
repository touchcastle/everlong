import 'package:flutter/material.dart';

class RecordListContainer extends StatelessWidget {
  final BoxDecoration decoration;
  final Widget child;
  final ScrollController controller;
  RecordListContainer({
    required this.decoration,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: decoration,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Scrollbar(controller: controller, child: child),
      ),
    );
  }
}
