import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';

///COMPANY'S CI COLORS
///Orange
const Color kOrangeMain = Color(0xffF68800);
const Color kOrange2 = Color(0xffF6A33D);
const Color kOrange3 = Color(0xffF6BF7B);
const Color kOrange4 = Color(0xffF6DAB8);
const Color kOrange5 = Color(0xFFED6B3B);

///Yellow
const Color kYellowMain = Color(0xffF9BD24);
const Color kYellow2 = Color(0xffF9CC58);
const Color kYellow3 = Color(0xffF9DB8E);
const Color kYellow4 = Color(0xffF9EAC3);

///Green
const Color kGreenMain = Color(0xff266866);
const Color kGreen2 = Color(0xff1D4E4D);
const Color kGreen3 = Color(0xff133433);
const Color kGreen4 = Color(0xff0A1A1A);
const Color kGreen5 = Color(0xFF42A593);

///Red
const Color kRed1 = Color(0xFFEC0F47);
const Color kRed2 = Color(0xFF9F1A1A);
//==============================================================================

///USAGE
///
///ONLINE USAGE++++
///
///For dialog or button background that require darker than usual.
const Color kDarkOnlineBG = kGreen2;

///For Standing-by Button
const Color kOnlineInactiveLabel = kYellowMain;

///For Standing-by Button
const Color kOnlineDisabledLabel = kGreen3;

///For Room Info.Subject.
const Color kOnlineRoomSubject = kTextColorLight;

///For Room Info. Detail.
const Color kOnlineRoomDetail = kTextColorWhite;

///For Member's Box
const Color kMemberBox = kYellow3;

///For Member's information
const Color kMemberDetail = kTextColorDark;

///Color tween for button in online screen.
final ColorTween kOnlineColorTween =
    ColorTween(begin: kActiveLabel, end: kOnlineInactiveLabel);

/// Online screen accent color.
const Color kOnlineAccentColor = kGreenMain;

/// Online dialog bg color.
const Color kOnlineDialog = kGreenMain;

/// Background color gradient for online screen.
const List<Color> kOnlineBG = [kGreenMain, kGreen5];

/// Alternate Background color gradient for online screen.
const List<Color> kOnlineBG2 = [kGreenMain, kGreen2];

/// Background color gradient for session ended dialog.
const List<Color> kSessionEndedBG = [kGreen2, kGreen2];

///Virtual piano pressing key
const Color kPressingKey = kRed1;
//------------------------------------------------------------------------------

///LOCAL USAGE++++

///Connected device box.
const Color kConnectedBoxColor = kYellow3;

///For Standing-by Button
const Color kLocalInactiveLabel = kOrange3;

///Expanding device box.
const Color kExpandingBoxColor = kGreenMain;

///Disconnected device box.
const Color kDisconnectedBoxColor = kYellow2;

///Connected device info text.
const Color kConnectedTextColor = kTextColorDark;

///Disconnected device info text.
const Color kDisconnectedTextColor = kOrange5;

/// Color tween for specific device's ping.
final ColorTween kDevicePingColorTween =
    ColorTween(begin: kActiveLabel, end: kGreenMain);

/// Color tween for button in local screen.
final ColorTween kLocalColorTween =
    ColorTween(begin: kActiveLabel, end: kLocalInactiveLabel);
// ColorTween(begin: kActiveLabel, end: kLocalAccentColor);

/// Local screen accent color.
const Color kLocalAccentColor = kRed2;

/// Local dialog bg color.
const Color kLocalDialog = kYellowMain;

/// Background color gradient for local screen.
const List<Color> kLocalBG = [kOrangeMain, kYellowMain];

/// Alternate Background color gradient for local screen.
const List<Color> kLocalBG2 = [kYellowMain, kOrangeMain];

/// Background color gradient for setting screen.
const List<Color> kSettingBG = [kYellowMain, kOrangeMain];
//------------------------------------------------------------------------------

///COMMON USAGE++++
///

///For Active-by Button
const Color kActiveLabel = Colors.white;

///Text color
const Color kTextColorDark = kGreenMain;
const Color kTextColorLight = kYellowMain;
const Color kTextColorWhite = kYellow4;
const Color kTextColorRed = kRed2;

///Snackbox color
const Color kErrorSnackBoxBg = kOrange5;
const Color kErrorSnackBoxText = kOrange4;

///Music Notation
const Color kStaffArea = kTextColorWhite;
const Color kStaffColor = Colors.grey;
const Color kNoteColor = Colors.red;

///Button's label color.
Color buttonLabelColor(
        {bool isActive = false, Color? color, Color? activeColor}) =>
    color != null
        ? color
        : isActive
            ? activeColor != null
                ? activeColor
                : kActiveLabel
            : Setting.isOnline()
                ? kOnlineInactiveLabel
                : kLocalInactiveLabel;
//          : Setting.isOffline()
//              ? kLocalLabelColor
//              : Colors.white;
