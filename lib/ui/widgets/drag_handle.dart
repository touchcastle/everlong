import 'package:flutter/material.dart';

class DragHandle extends StatelessWidget {
  final double height;
  DragHandle({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 0),
      color: Colors.transparent,
      child: Icon(
        Icons.drag_handle,
        color: Colors.black12,
      ),
    );
  }
}
