import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/status_check.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/ui/widgets/logo.dart';
import 'package:everlong/ui/widgets/dialog_header_bar.dart';
import 'package:everlong/ui/widgets/actions/to_online_room.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/texts.dart';

class OnlineLobby extends StatefulWidget {
  static const id = kOnlineLobbyId; //for route.
  final String? roomID;
  final LobbyType lobbyType;
  OnlineLobby({this.lobbyType = LobbyType.create, this.roomID});

  @override
  _OnlineLobbyState createState() => new _OnlineLobbyState();
}

class _OnlineLobbyState extends State<OnlineLobby> {
  String? _roomToJoin;
  String? _nameToJoin;
  TextEditingController? _roomIdInputCtrl;
  TextEditingController? _nameInputCtrl;

  ///Lobby box width
  double _dialogRatio() =>
      Setting.isTablet() ? kTabletDialogRatio : kMobileDialogRatio;

  ///Logo width
  double _logoRatio() => Setting.isTablet() ? kLogoTablet : kLogoMobile;

  ///Lobby header text
  String _header() =>
      widget.lobbyType == LobbyType.join ? kJoinHeader : kCreateHeader;

  @override
  void initState() {
    super.initState();
    // ///Initialize online session variables and parameters.
    context.read<Online>().prepare();
    if (widget.roomID != null) {
      _roomToJoin = widget.roomID!;
      _roomIdInputCtrl = TextEditingController(text: _roomToJoin);
    }
    if (Setting.prefName != null) {
      _nameToJoin = Setting.prefName!;
      _nameInputCtrl = TextEditingController(text: _nameToJoin);
    }
    Check.internet(context);
  }

  ///Text field for username
  Column _usernameInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(kUserNameLabel, style: textFieldLabel(color: kTextColorLight)),
        Theme(
          data: Theme.of(context).copyWith(textSelectionTheme: kTextInputTheme),
          child: TextField(
            controller: _nameInputCtrl,
            style: kTextFieldStyle,
            decoration: kRenameTextDecor(kUserName),
            onChanged: (value) => _nameToJoin = value,
          ),
        ),
        Text(kUserNameLabel2,
            style: textFieldSubLabel2(color: kTextColorWhite)),
      ],
    );
  }

  ///Text field for session id
  Column _sessionIdInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Setting.deviceHeight * 0.01),
        Text(kSessionIdLabel, style: textFieldLabel(color: kTextColorLight)),
        Theme(
          data: Theme.of(context).copyWith(textSelectionTheme: kTextInputTheme),
          child: TextField(
            controller: _roomIdInputCtrl,
            maxLength: kSessionIdLength,
            keyboardType: TextInputType.number,
            style: kTextFieldStyle,
            decoration: kRenameTextDecor(kSession),
            // autofocus: _autoFocus(),
            onChanged: (value) => _roomToJoin = value,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Setting.deviceWidth = MediaQuery.of(context).size.width;
    Setting.deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: kGreenMain,
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: Setting.deviceHeight * 0.05),
                  logo(_logoRatio),
                  SizedBox(height: Setting.deviceHeight * 0.05),
                  Container(
                    decoration: kOnlineLobbyDialogDecor,
                    padding: kOnlineLobby,
                    constraints: BoxConstraints(
                      maxWidth: Setting.deviceWidth * _dialogRatio(),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        dialogHeaderBar(
                          barColor: kDarkOnlineBG,
                          exitIconAreaColor: kDarkOnlineBG,
                          title: _header(),
                          onExit: () async {
                            Setting.sessionMode = SessionMode.none;
                            Navigator.popUntil(
                                context, ModalRoute.withName(kMainPageName));
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Setting.deviceWidth * 0.07),
                          child: Column(
                            children: [
                              SizedBox(height: Setting.deviceHeight * 0.01),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _usernameInput(context),
                                  widget.lobbyType == LobbyType.join
                                      ? _sessionIdInput(context)
                                      : SizedBox.shrink(),
                                ],
                              ),
                              SizedBox(height: Setting.deviceHeight * 0.01),
                            ],
                          ),
                        ),
                        ToOnlineRoom(
                          inType: widget.lobbyType,
                          onPressed: () async {
                            if (await Setting.isConnectToInternet()) {
                              await context.read<Online>().lobby(context,
                                  type: widget.lobbyType,
                                  name: _nameToJoin,
                                  room: _roomToJoin);
                            } else {
                              Snackbar.show(
                                context,
                                text: kNoInternetMsg,
                                icon: kBluetoothIconDisconnected,
                                verticalMargin: false,
                                dialogWidth: true,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: Setting.deviceHeight * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
