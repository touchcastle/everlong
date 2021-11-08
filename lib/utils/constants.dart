///LAYOUT & ANIMATION
const double kTabletStartWidth = 600.0;
const int kListAnimateDuration = 200;
const int kBeforeNextAnimate = 10;
const int kMaxMember = 10;
const int kSessionIdLength = 10;

///Config
const String kVersion = '1.0.0';
const String kHeroLogo = 'logo';
const Duration kClockInPeriod = Duration(milliseconds: 15000);
const int kClockInCheckPeriod = 20000; //in millisec.

/// String to store in static when there is no host.
const String kNoMaster = 'N/A';

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
const String kPrefix = 'https://noteromirror.page.link';
const String kDisplayUrl = 'https://notero.app';
const String kBundle = 'co.notero.everlong';
const int kAndroidMinVer = 1;
const String kAppStoreMinVer = '1.0.0';
const String kAppStoreId = '1593845953';

///Snackbar
const String kNoInternetMsg = 'NO INTERNET CONNECTION';
const String kNoMasterMsg = 'Please set master device.';
const String kNoConnectedMsg = 'No connected device.';
const String kNoChildMsg = 'Child\'s device not found.';

///Main Menu
const String kOr = '   -   ';
const String kMainPageName = '/main_menu_page';

///Online Lobby
const String kJoinHeader = 'Join Online Session';
const String kCreateHeader = 'Create Online Session';
const String kUserNameLabel = 'User Name';
const String kUserName = 'Name';
const String kUserNameLabel2 = 'Name will be remember automatically';
const String kSessionIdLabel = 'Session ID';
const String kSession = 'Session';

///Online Room
const String kParticipant = 'Participants: ';
const String kTime = 'Active Time: ';

/// Database name and Table name.
const String kDbName = 'midi_device.db'; //Database name
const String kDbDeviceName = 'device_name'; //Table name

///Local Screen
const String kMasterDevice = 'Master Device: ';
const String kInfoNoMaster = '(None)';

///Device
const String kNoDeviceText = 'Not found any \'Smart Piano\' in range.\n\n\n'
    'Apply re-scan or make sure that your piano(s) is already turned on\n'
    'and have bluetooth adapter integrated.';
const String kConnectedText = 'Connected';
const String kConnectingText = 'Connecting';
const String kDisconnectedText = 'Disconnected';
const String kDisconnectingText = 'Disconnecting';
const String kHost = ', Master';
const String kDevicesMng = 'Devices Manager';

///Button
const String kToHold = 'Hold';
const String kToUnHold = 'Release';
const String kResetLight = 'Reset Keys';
const String kResetting = 'Resetting';
const String kScan = 'Re-scan';
const String kIdentAll = 'Ping All';
const String kDeviceManager = 'Devices';
const String kBack = 'Back';
const String kSave = 'Save';
const String kOk = 'OK';
const String kJoin = 'Join';
const String kCreate = 'Create';
const String kMute = 'Mute';
const String kUnmute = 'Unmute';
const String kOnlineCreate = 'CREATE ONLINE SESSION';
const String kOnlineJoin = 'JOIN ONLINE SESSION';
const String kLocal = 'START LOCAL SESSION';

///Setting
const String kSettingLatency = 'Latency Adjustment';
const String kSettingLatencyLow1 = 'Lower Latency';
const String kSettingLatencyLow2 = 'Lower MIDI Stability';
const String kSettingLatencyHigh1 = 'Higher Latency';
const String kSettingLatencyHigh2 = 'Higher MIDI Stability';
const String kSettingMode = 'MODE';
const String kSettingModeOff = 'Off';
const String kSettingModeOn = 'Light & Sound (Higher Latency)';
const String kSettingModeOnTablet = 'Light & Sound\n(Higher Latency)';
const String kSettingModeOnMute = 'Light Only (Default)';
const String kSettingModeOnMuteTablet = 'Light Only\n(Default)';
const String kSettingModeOnBlind = 'Sound Only';

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
