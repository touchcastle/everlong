import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

/// Setting button
class ShowList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _isShow = context.watch<Classroom>().showList;
    return Button(
      isActive: _isShow,
      icon: svgIcon(
        name: kShowListIcon,
        width: kIconWidth,
        color: buttonLabelColor(isActive: _isShow),
      ),
      onPressed: () => context.read<Classroom>().toggleListDisplay(),
    );
  }
}
