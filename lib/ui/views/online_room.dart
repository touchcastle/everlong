import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/views/global_top_menu.dart';
import 'package:everlong/ui/views/online_bottom_menu.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/constants.dart';
import 'package:connectivity/connectivity.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/ui/widgets/online/session_ended_dialog.dart';
import 'package:everlong/ui/widgets/online/online_info_bar.dart';
import 'package:everlong/ui/views/screens/screen.dart';
import 'package:everlong/ui/views/online_members.dart';
import 'package:everlong/utils/colors.dart';

class OnlineRoom extends StatefulWidget {
  static const id = kOnlineRoomId; //for route.
  @override
  _OnlineRoomState createState() => new _OnlineRoomState();
}

class _OnlineRoomState extends State<OnlineRoom> {
  dynamic _connectivitySub;

  @override
  void initState() {
    super.initState();
    _myConnectivity();
  }

  void _myConnectivity() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // _myConnection = result;
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

  bool _isMobile(double width) => width < kTabletStartWidth;

  @override
  dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kOnlineAccentColor,
      // backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: kBGGradient(kOnlineBG),
              // borderRadius: kBoxBorderRadius,
            ),
            child: Center(
              child: context.watch<Online>().roomID != ''
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlobalTopMenu(),
                        onlineInfoBar(),
                        Expanded(
                          child: SizedBox.expand(
                            child: GestureDetector(
                              onHorizontalDragEnd: (DragEndDetails details) {
                                if (details.primaryVelocity! > 0) {
                                  context
                                      .read<Classroom>()
                                      .toggleListDisplay(forceShow: false);
                                } else if (details.primaryVelocity! < 0) {
                                  context
                                      .read<Classroom>()
                                      .toggleListDisplay(forceShow: true);
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 8, right: 8, bottom: 15, top: 8),
                                child: Row(
                                  children: [
                                    !context.watch<Classroom>().showList ||
                                            (context
                                                    .watch<Classroom>()
                                                    .showList &&
                                                !_isMobile(_screenWidth))
                                        ? Expanded(flex: 1, child: Screen())
                                        : SizedBox.shrink(),
                                    context.watch<Classroom>().showList
                                        ? Expanded(
                                            flex: 1, child: OnlineMemberList())
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        OnlineBottomMenu(
                            isRoomHost: context.read<Online>().isRoomHost),
                      ],
                    )
                  : sessionEnded(
                      onPressed: () => Navigator.popUntil(
                          context, ModalRoute.withName(kMainPageName))),
            ),
          ),
        ),
      ),
    );
  }
}
