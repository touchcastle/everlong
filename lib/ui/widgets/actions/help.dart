import 'package:flutter/material.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/ui/views/tutorial.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3.0,
              ),
            ],
          ),
          // color: Colors.green,
          child: Icon(
            Icons.help,
            color: kYellowMain,
            size: 25,
          )),
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
            transitionDuration: kTransitionDur,
            transitionsBuilder: kPageTransition,
            pageBuilder: (_, __, ___) => Tutorial()));
      },
    );
    // return Button(
    //   elevation: 3,
    //   isVertical: false,
    //   icon: svgIcon(
    //     name: kHelpIcon,
    //     width: kIconWidth,
    //     color: kYellowMain,
    //   ),
    //   onPressed: () {
    //     Navigator.of(context).push(PageRouteBuilder(
    //         transitionDuration: kTransitionDur,
    //         transitionsBuilder: kPageTransition,
    //         pageBuilder: (_, __, ___) => Tutorial()));
    //   },
    // );
  }
}
