import 'package:flutter/material.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/actions/exit.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';

Container dialogHeaderBar({
  required Color barColor,
  required Color exitIconAreaColor,
  Color? exitIconColor,
  String? titleIconName,
  Color? titleIconColor,
  required String title,
  Color? titleColor,
  Function()? onExit,
}) {
  Color _defaultLabelColor = Colors.white;
  return Container(
    decoration: BoxDecoration(borderRadius: kTop, color: barColor),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            decoration:
                BoxDecoration(borderRadius: kTopLeft, color: exitIconAreaColor),
            child: Exit(
                color: exitIconColor,
                onPressed: onExit,
                borderRadius: kTopLeft)),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              titleIconName != null
                  ? Row(
                      children: [
                        SizedBox(width: 10),
                        svgIcon(
                            name: titleIconName,
                            width: kIconWidth,
                            color: titleIconColor ?? _defaultLabelColor),
                      ],
                    )
                  : SizedBox.shrink(),
              SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(title,
                      style: dialogHeader(
                          color: titleColor ?? _defaultLabelColor)),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
