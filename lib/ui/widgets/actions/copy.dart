import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

/// Copy button
class Copy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Button(
        icon: svgIcon(
            name: kCopyIcon, width: kIconWidth, color: kOnlineInactiveLabel),
        onPressed: () async {
          await Clipboard.setData(
              ClipboardData(text: context.read<Online>().roomID));
          Snackbar.show(context,
              text:
                  'Session ID: "${context.read<Online>().roomID}" copied to clipboard',
              type: MessageType.info);
        });
  }
}
