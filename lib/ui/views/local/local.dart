import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/bluetooth.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/ui/views/global_top_menu.dart';
import 'package:everlong/ui/views/local/local_bottom_menu.dart';
import 'package:everlong/ui/views/local/set_master_reminder.dart';
import 'package:everlong/ui/views/device/devices_list.dart';
import 'package:everlong/ui/views/screens/screen.dart';
import 'package:everlong/ui/views/local/local_record_view.dart';
import 'package:everlong/ui/views/local/local_info_bar.dart';
import 'package:everlong/ui/views/device/no_device.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/constants.dart';

class LocalPage extends StatefulWidget {
  static const id = kLocalId; //for route.
  @override
  _LocalPageState createState() => new _LocalPageState();
}

class _LocalPageState extends State<LocalPage>
    with SingleTickerProviderStateMixin {
  ///For bluetooth scanning subscribe
  var _scanSub;

  Padding _deviceList() => Padding(
      padding: EdgeInsets.only(left: Setting.isTablet() ? 10 : 0),
      child: DeviceAnimatedList());

  Padding _recorder() => Padding(
        padding: EdgeInsets.only(left: Setting.isTablet() ? 10 : 0, top: 0),
        child: LocalRecordView(),
      );

  ///Empty area
  SizedBox _empty = SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    _scanSub = context
        .read<BluetoothControl>()
        .collectScanResult()
        .listen((result) => result ? setState(() {}) : setState(() {}));
    // .listen((result) => result ? setState(() {}) : null);
    Setting.currentContext = context;
    context.read<Classroom>().resetClass();
    Future.delayed(Duration(seconds: 1), () => _setMaster());
  }

  ///Display set master device dialog when entered local session screen.
  ///Check [Setting.notRemindMaster] if user had selected to not show again.
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

  void dispose() {
    _scanSub?.cancel();
    Setting.sessionMode = SessionMode.none;
    Setting.currentContext = null;
    super.dispose();
  }

  ///User can swipe in main area to switch between music notation view only
  ///and music notation and device's list view.
  GestureDetector _mainArea(bool showList, bool hasDevice, bool showRecorder) {
    return GestureDetector(
      onHorizontalDragEnd: _swiper,
      child: Padding(
        padding: kMainArea,
        child: Row(
          children: [
            showList && !Setting.isTablet()
                ? _empty
                : Expanded(flex: 1, child: Screen()),
            showList
                ? Expanded(
                    flex: 1,
                    // child: Stack(
                    //   alignment: Alignment.bottomCenter,
                    //   children: [
                    //     hasDevice ? _deviceList() : NoDeviceDisplay(),
                    //     _recorder(),
                    //   ],
                    // ),
                    child: Column(children: [
                      Expanded(
                          child: hasDevice ? _deviceList() : NoDeviceDisplay()),
                      showRecorder ? _recorder() : _empty,
                    ]),
                  )
                : _empty,
          ],
        ),
      ),
    );
  }

  ///Set flag when user swipe to change view mode.
  void _swiper(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      context.read<Classroom>().toggleListDisplay(forceShow: false);
    } else if (details.primaryVelocity! < 0) {
      context.read<Classroom>().toggleListDisplay(forceShow: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Setting.deviceWidth = MediaQuery.of(context).size.width;
    Setting.deviceHeight = MediaQuery.of(context).size.height;
    bool _showList = context.watch<Classroom>().showList;
    bool _hasDevice = context.watch<Classroom>().bluetoothDevices.isNotEmpty;
    bool _showRecorder = context.watch<Classroom>().showRecorder;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kLocalAccentColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(gradient: kBGGradient(kLocalBG)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlobalTopMenu(),
                localInfoBar(context.watch<Classroom>().masterName),
                Expanded(
                    child: _mainArea(_showList, _hasDevice, _showRecorder)),
                // LocalBottomMenu(onScanPressed: () => setState(() {})),
                LocalBottomMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
