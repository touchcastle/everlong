import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/ui/views/global_top_menu.dart';
import 'package:everlong/ui/views/online/online_bottom_menu.dart';
import 'package:everlong/ui/views/screens/screen.dart';
import 'package:everlong/ui/views/online/online_members.dart';
import 'package:everlong/ui/views/online/online_record_view.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/ui/views/online/session_ended_dialog.dart';
import 'package:everlong/ui/views/online/online_info_bar.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/constants.dart';

class OnlineRoom extends StatefulWidget {
  static const id = kOnlineRoomId; //for route.
  @override
  _OnlineRoomState createState() => new _OnlineRoomState();
}

class _OnlineRoomState extends State<OnlineRoom> {
  ///Subscribe to own internet connectivity
  dynamic _connectivitySub;

  ///If room was closed while user still inside.
  bool _roomClosed() =>
      context.watch<Online>().roomID == '' &&
      context.watch<Online>().roomClosed;

  @override
  void initState() {
    super.initState();
    Setting.currentContext = context;
    _myConnectivity();
  }

  ///When someone join created room, show session's clock since it was build.
  int _getElapsed() {
    DateTime _createTime = DateTime.fromMicrosecondsSinceEpoch(
        context.read<Online>().roomCreateTime * 1000);
    return DateTime.now().difference(_createTime).inSeconds;
  }

  ///Function to handle when lost internet connection during class.
  void _myConnectivity() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        // Lost connection.
        Snackbar.show(context, text: 'No Internet Connection');
        context.read<Online>().connectionSet(lostConnection: true);
      } else {
        // Connection restored.
        if (context.read<Online>().lostConnection) {
          context.read<Online>().connectionSet(lostConnection: false);
          context.read<Classroom>().resetDisplay();
        }
      }
    });
  }

  @override
  dispose() {
    _connectivitySub?.cancel();
    Setting.currentContext = null;
    super.dispose();
  }

  ///Empty area
  SizedBox _empty = SizedBox.shrink();

  ///Show music notation logic.
  bool _showNotation() =>
      !context.watch<Classroom>().showList ||
      (context.watch<Classroom>().showList && Setting.isTablet());

  bool _showList() => context.watch<Classroom>().showList;

  bool _showRecorder() => context.watch<Classroom>().showRecorder;

  // bool _showRecorder() =>
  //     context.watch<Classroom>().showRecorder &&
  //         context.watch<Online>().memberCount > 1;

  ///Set flag when user swipe to change view mode.
  ///New-Requirement to disable this function
  void _swiper(DragEndDetails details) {
    //Not swipe when resizing recorder view
    double _yVelocity = details.velocity.pixelsPerSecond.dy;
    double _xVelocity = details.velocity.pixelsPerSecond.dx;
    bool _notVerticalDrag() => _xVelocity.abs() > _yVelocity.abs();
    if (details.primaryVelocity! > 0 && _notVerticalDrag()) {
      context.read<Classroom>().toggleListDisplay(forceShow: false);
    } else if (details.primaryVelocity! < 0 && _notVerticalDrag()) {
      context.read<Classroom>().toggleListDisplay(forceShow: true);
    }
  }

  Padding _recorder() => Padding(
      padding: EdgeInsets.only(left: Setting.isTablet() ? 10 : 0, top: 0),
      child: OnlineRecordView());

  ///User can swipe in main area to switch between music notation view only
  ///and music notation and member's list view.
  GestureDetector _mainArea(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _swiper,
      child: Padding(
        padding: kMainArea,
        child: Row(
          children: [
            _showNotation() ? Expanded(flex: 1, child: Screen()) : _empty,
            _showList()
                ? Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(child: OnlineMemberList()),
                        _showRecorder() ? _recorder() : _empty,
                      ],
                    ))
                : _empty,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Setting.deviceWidth = MediaQuery.of(context).size.width;
    Setting.deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kOnlineAccentColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(gradient: kBGGradient(kOnlineBG)),
            child: Center(
              child: _roomClosed()
                  ? sessionEnded(onPressed: () {
                      context.read<Recorder>().stopAllActivities();
                      Navigator.popUntil(
                          context, ModalRoute.withName(kMainPageName));
                    })
                  : Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GlobalTopMenu(),
                        onlineInfoBar(createSecondAgo: _getElapsed()),
                        Expanded(
                          child: SizedBox.expand(child: _mainArea(context)),
                        ),
                        OnlineBottomMenu(
                            isRoomHost: context.read<Online>().isRoomHost),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
