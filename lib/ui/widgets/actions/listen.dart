import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';

class Listen extends StatelessWidget {
  Listen({required this.memberId, required this.listenable});
  final String memberId;
  final bool listenable;

  @override
  Widget build(BuildContext context) {
    print('display as $listenable');
    return Button(
        icon: svgIcon(
          name: kHostIcon,
          color: listenable ? kOrangeMain : Colors.black38,
        ),
        onPressed: () async {
          await context.read<Online>().toggleMemberListenable(
              memberId: memberId, listenable: !listenable);
        });
  }
}
