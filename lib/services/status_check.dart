import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/snackbar.dart';

class Check {
  static void internet(BuildContext context) async =>
      await Setting.isConnectToInternet() == false
          ? Snackbar.show(context, text: 'NO INTERNET CONNECTION')
          : null;
}
