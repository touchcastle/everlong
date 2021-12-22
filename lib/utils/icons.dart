import 'package:everlong/ui/widgets/text_resp.dart';

// const String kBluetoothIconDisconnected =
//     'assets/icons/bluetooth_disconnected.svg';
// const String kBluetoothIconConnected = 'assets/icons/bluetooth_connected.svg';
const String kBluetoothIconDisconnected = 'assets/icons/disconnected.svg';
const String kBluetoothIconConnected = 'assets/icons/connected.svg';
const String kHelpIcon = 'assets/icons/help.svg';
const String kHostIcon = 'assets/icons/host.svg';
const String kHoldIcon = 'assets/icons/hold.svg';
const String kReleaseIcon = 'assets/icons/release.svg';
const String kResetIcon = 'assets/icons/reset.svg';
const String kPingIcon = 'assets/icons/ping.svg';
const String kRenameIcon = 'assets/icons/rename.svg';
const String kBackIcon = 'assets/icons/back.svg';
const String kOkIcon = 'assets/icons/ok.svg';
const String kCancelIcon = 'assets/icons/cancel.svg';
const String kNoteroIcon = 'assets/icons/notero_icon.svg';
const String kExitIcon = 'assets/icons/exit.svg';
const String kLinkIcon = 'assets/icons/link.svg';
const String kCopyIcon = 'assets/icons/copy.svg';
const String kDeviceManageIcon = 'assets/icons/device_manage.svg';
const String kHomeIcon = 'assets/icons/home.svg';
const String kSoundIcon = 'assets/icons/sound.svg';
const String kOnlineIcon = 'assets/icons/online.svg';
const String kErrorIcon = 'assets/icons/error.svg';
const String kJoinIcon = 'assets/icons/join.svg';
const String kSettingIcon = 'assets/icons/setting.svg';
const String kShowStaffIcon = 'assets/icons/show_staff.svg';
const String kShowListIcon = 'assets/icons/show_list.svg';
const String kArrowIcon = 'assets/icons/arrow2.svg';
const String kConfirmIcon = 'assets/icons/confirm.svg';
const String kSaveIcon = 'assets/icons/save.svg';
const String kCheckedIcon = 'assets/icons/checkbox_checked.svg';
const String kUncheckedIcon = 'assets/icons/checkbox_unchecked.svg';
const String kRedLightIcon = 'assets/icons/traffic_red.svg';
const String kGreenLightIcon = 'assets/icons/traffic_green.svg';
const String kAmberLightIcon = 'assets/icons/traffic_amber.svg';
const String kKeyGImage = 'assets/icons/g_clef.svg';
const String kKeyFImage = 'assets/icons/f_clef.svg';
const String kRecordIcon = 'assets/icons/recorder_menu.svg';
const String kRecStartIcon = 'assets/icons/rec_start.svg';
const String kRecStopIcon = 'assets/icons/rec_stop.svg';
const String kRecPlayIcon = 'assets/icons/rec_play.svg';
const String kRecDelIcon = 'assets/icons/rec_del.svg';
const String kRecRenameIcon = 'assets/icons/rec_rename.svg';
// double kIconWidth2 = textSizeResp(ratio: 15);
const double kIconWidth = 25;
double kIconWidth3 = textSizeResp(ratio: 20);
double kProgressWidth = textSizeResp(ratio: 45);
const String kSliderThumbIcon =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="45" height="45" viewBox="0 0 45 45">
  <g id="MelodyBar" transform="translate(37 4.183)">
    <g transform="matrix(1, 0, 0, 1, -37, -4.18)" filter="url(#Ellipse_11)">
      <circle id="Ellipse_11-2" data-name="Ellipse 11" cx="13.5" cy="13.5" r="13.5" transform="translate(9 6)" fill="#133433"/>
    </g>
    <path id="Notero" d="M25.677,16.067l-.009.008,1.485,2.572a4.192,4.192,0,0,1,0,4.223A4.475,4.475,0,0,1,23.4,24.956a4.014,4.014,0,0,1-3.455-1.978,2.819,2.819,0,0,1,.889-3.908,2.64,2.64,0,0,1,1.431-.409,2.8,2.8,0,0,1,2.4,1.3l.026-.015L23.61,18.083a.919.919,0,0,0-.787-.458,7.354,7.354,0,0,1-1.78.224A7.124,7.124,0,0,1,14,10.913v-.388a6.83,6.83,0,0,1,1.894-4.5.925.925,0,0,0,.129-1.089L15.6,4.2a2.813,2.813,0,0,1,0-2.8A2.692,2.692,0,0,1,17.965,0a2.944,2.944,0,0,1,2.359,1.2,2.789,2.789,0,0,1,.315,2.584l-.007.021h.022c.135-.008.271-.012.4-.012a6.9,6.9,0,0,1,6.094,3.647A6.938,6.938,0,0,1,25.677,16.067Zm-3.415-1.71a4.245,4.245,0,0,0,4.193-4.545,4.179,4.179,0,0,0-2.638-3.636l-.023-.009,0,.025a2.758,2.758,0,0,1-.642,2.228,2.948,2.948,0,0,1-2.182.958A2.648,2.648,0,0,1,18.6,7.992l-.013-.023-.013.023a4.122,4.122,0,0,0-.011,4.194A4.328,4.328,0,0,0,22.262,14.358Zm-3.907-12.8a.964.964,0,0,0-.346.332.9.9,0,0,0,0,.915l.681,1.18.011,0a1.376,1.376,0,0,0,.942-.782,1.377,1.377,0,0,0-.006-1.226c-.012-.026-.026-.055-.041-.082a.91.91,0,0,0-.777-.458A.964.964,0,0,0,18.356,1.556Z" transform="translate(-35.542 2.546)" fill="#14c287"/>
  </g>
</svg>
''';
const String kSharpIcon =
    '''<svg width="16" height="48" viewBox="0 0 16 48" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M5.21834 30.7062V18.8178L10.694 17.4227V29.2505L5.21834 30.7062ZM16 27.8301L12.2355 28.8259V16.9981L16 16.0276V11.1145L12.2355 12.085V0H10.694V12.4515L5.21834 13.9047V2.15327H3.76455V14.352L0 15.325V20.2482L3.76455 19.2777V31.0828L0 32.0507V36.9537L3.76455 35.9832V48H5.21834V35.5536L10.694 34.1636V45.8543H12.2355V33.7238L16 32.7508V27.8301Z" fill="#061928"/>
</svg>
''';
const String kFlatIcon =
    '''<svg width="14" height="48" viewBox="0 0 14 48" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M1.73278 0V23.318C1.73278 23.318 1.73278 24.8898 1.73278 28.0333C3.73215 26.0195 5.97588 24.988 8.46398 24.9389C10.019 24.9389 11.3519 25.6511 12.4627 27.0755C13.4402 28.4017 13.9511 29.8753 13.9956 31.4962C14.04 32.7733 13.7512 34.2468 13.1292 35.9169C12.907 36.6045 12.4183 37.3413 11.663 38.1272C11.0854 38.7166 10.4856 39.3306 9.86354 39.9691C6.57569 42.6215 3.28784 45.2985 0 48V0H1.73278ZM7.13107 29.6543C6.5979 28.9666 5.90923 28.6228 5.06506 28.6228C3.99873 28.6228 3.13234 29.2859 2.46588 30.6121C1.97715 31.6436 1.73278 34.0749 1.73278 37.9062V44.2424C1.77721 44.4389 3.02126 43.2355 5.46494 40.6322C6.79784 39.2569 7.66423 37.636 8.06411 35.7695C8.24183 35.0327 8.33069 34.296 8.33069 33.5592C8.33069 31.9383 7.93081 30.6366 7.13107 29.6543Z" fill="#061928"/>
</svg>
''';
