import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/bluetooth.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/views/global_top_menu.dart';
import 'package:everlong/ui/views/local_bottom_menu.dart';
import 'package:everlong/ui/views/set_master_reminder.dart';
import 'package:everlong/ui/views/device/devices_list.dart';
import 'package:everlong/ui/views/screens/screen.dart';
import 'package:everlong/ui/widgets/local_info_bar.dart';
import 'package:everlong/ui/widgets/device/no_device.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/constants.dart';

class LocalPage extends StatefulWidget {
  static const id = kLocalId; //for route.
  @override
  _LocalPageState createState() => new _LocalPageState();
}

class _LocalPageState extends State<LocalPage> {
  dynamic _scanSub;

  @override
  void initState() {
    super.initState();
    _scanSub = context
        .read<BluetoothControl>()
        .collectScanResult()
        .listen((result) => result ? setState(() {}) : setState(() {}));
    // .listen((result) => result ? setState(() {}) : null);
    Setting.currentContext = context;
    Future.delayed(Duration(seconds: 1), () => _setMaster());
  }

  Future _setMaster() async {
    if (!Setting.notRemindMaster)
      showDialog(
        context: context,
        builder: (BuildContext context) => dialogBox(
          smallerDialog: true,
          context: context,
          content: SetMasterReminder(),
        ),
      );
  }

  void _swiper(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      context.read<Classroom>().toggleListDisplay(forceShow: false);
    } else if (details.primaryVelocity! < 0) {
      context.read<Classroom>().toggleListDisplay(forceShow: true);
    }
  }

  void dispose() {
    _scanSub?.cancel();
    Setting.sessionMode = SessionMode.none;
    Setting.currentContext = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Setting.deviceWidth = MediaQuery.of(context).size.width;
    Setting.deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kLocalAccentColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(gradient: kBGGradient(kLocalBG)),
            child: Column(children: [
              GlobalTopMenu(),
              localInfoBar(context.watch<Classroom>().masterName),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: _swiper,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        context.watch<Classroom>().showList &&
                                !Setting.isTablet()
                            ? SizedBox.shrink()
                            : Expanded(
                                flex: 1,
                                child: Screen(),
                              ),
                        context.watch<Classroom>().showList
                            ? Expanded(
                                flex: 1,
                                child: context
                                        .watch<Classroom>()
                                        .bluetoothDevices
                                        .isNotEmpty
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            left: Setting.isTablet() ? 10 : 0),
                                        child: DeviceAnimatedList(),
                                      )
                                    : NoDeviceDisplay(),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
              // LocalBottomMenu(onScanPressed: () => setState(() {})),
              LocalBottomMenu(),
            ]),
          ),
        ),
      ),
    );
  }
}
