import 'dart:io' show Platform;

///LAYOUT & ANIMATION
const double kTabletStartWidth = 600.0;
const double kTabletMaxDynamicWidth = 1000.0;
const int kListAnimateDuration = 200;
const int kBeforeNextAnimate = 10;
const int kMaxMember = 10;
const int kSessionIdLength = 10;
const double kButtonMinHeight = 45;

///Config
// String kVersion = Platform.isIOS ? '1.0.2' : '1.0.4';
String kVersion = Platform.isIOS ? '1.1.0' : '1.1.0';
const String kHeroLogo = 'logo';
// const Duration kClockInPeriod = Duration(milliseconds: 15000);
// const int kClockInCheckPeriod = 20000; //in millisec.
///TODO: change back
const Duration kClockInPeriod = Duration(days: 15000);
const int kClockInCheckPeriod = 200000000000; //in millisec.

///Device's Shared Preferences
const String kDelayPref = 'delay';
const String kModePref = 'mode';
const String kNamePref = 'name';
const String kMasterRemindPref = 'remind_master';

///PageID
const String kLandingId = 'landing_screen';
const String kMainMenuId = 'main_menu';
const String kLocalId = 'local_screen';
const String kOnlineLobbyId = 'online_lobby';
const String kOnlineRoomId = 'online_room';

///Google and Room config.
///CHECK FIRESTORE RULES WHEN UPDATE !!
const String kFireStoreCollection = 'notero_mirror';
const String kFireStoreMessageCol = 'messages';
const String kFireStoreMessageDoc = 'message';
const String kFireStoreMemberCol = 'members';
const String kFireStoreStudentMessageCol = 'student_messages';
const String kPrefix = 'https://noteromirror.page.link';
const String kDisplayUrl = 'https://notero.app';
const String kBundle = 'co.notero.everlong';
const int kAndroidMinVer = 1;
const String kAppStoreMinVer = '1.0.0';
const String kAppStoreId = '1593845953';

///Main Menu
const String kOr = '   -   ';
const String kMainPageName = '/main_menu_page';

/// Database name and Table name.
const String kDbName = 'midi_device.db'; //Database name
const String kDbDeviceName = 'device_name'; //Table name

/// String to store in static when there is no host.
const String kNoMaster = 'N/A';

///FUNCTIONING
///
/// Period for send note to target device to keep device awake.
const Duration kKeepAwakeDuration = Duration(seconds: 60);

/// Initial bluetooth scan timeout.
const Duration kScanDuration = Duration(milliseconds: 2000);

/// Bluetooth scan timeout.
const Duration kReScanDuration = Duration(milliseconds: 4000);

/// Bluetooth scan timeout when auto-rescan after connection failed.
const Duration kAutoReScanDuration = Duration(milliseconds: 500);

const Duration kDiscoverServiceTimeout = Duration(milliseconds: 4000);
const Duration kConnectTimeout = Duration(milliseconds: 5000);

/// Duration between each ping sound and light.
/// [kNotifyTimes] Is number of sound and light per each ping.
const int kNotifyTimes = 3;
const int kNotifyDurationInt = 1000;
const Duration kNotifyDuration = Duration(milliseconds: kNotifyDurationInt);
const Duration kNotifyLightDuration = Duration(milliseconds: 520);

/// Duration for color tween animation for ping's icon.
const double _tweenDouble = (kNotifyDurationInt / 2) - 40;
final int _tweenInt = _tweenDouble.toInt();
final Duration kPingColorTweenDuration = Duration(milliseconds: _tweenInt);
final Duration kPingColorTweenSlowDuration = Duration(milliseconds: 800);
