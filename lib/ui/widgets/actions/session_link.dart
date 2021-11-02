import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

/// Link button
class SessionLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Button(
        icon: svgIcon(
          name: kLinkIcon,
          width: kIconWidth,
          color: kOnlineButton,
        ),
        onPressed: () async => await context.read<Online>().shareLink());
  }
}
