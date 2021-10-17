import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:nanoid/nanoid.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:everlong/models/session_participants.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/services/authentication.dart';
import 'package:everlong/services/fire_store.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/views/online_room.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/midi.dart';
import 'package:everlong/utils/errors.dart';

enum LobbyType {
  create,
  join,
}

class Online extends ChangeNotifier {
  ///Room ID
  String roomID = '';

  ///Google FireStore
  FireStore _fireStore = FireStore();
  Classroom classroom;

  ///Authentication
  Auth _auth = Auth();
  late UserCredential? _user;

  ///Subscription to room message and command.
  dynamic _roomMessageSubscribe;
  bool isRoomHost = false;
  bool lostConnection = false;
  bool isMute = false;

  ///Just a flag for future purpose.
  ///Holding was already managed from host's key pressed stage.
  bool isHold = false;

  late int roomCreateTime;

  ///Device's UUID
  late String myID;

  ///Device's system name
  late String myDeviceName;

  ///Name in room
  late String myRoomName;

  // int sessionParticipants = 0;

  // /// Store room members retrieved from firestore
  // dynamic roomMembers = [];

  // Analytic analytic;
  // dynamic _connectivitySub;
  dynamic _memberSubscribe;
  List<SessionMember> membersList = [];

  ///Constructor.
  Online(
    this.classroom,
    // this.fireStore,
    // this.analytic,
  );

  ///Initialize firebase and prepare [myID] and [myDeviceName]
  Future init() async {
    await _fireStore.initializeFlutterFire();
    _auth.initAuth();
    _fireStore.col = _fireStore.getCollection();
    myID = await Setting.getId();
    myDeviceName = await Setting.getName();
  }

  ///Set connection state boolean
  void connectionSet({required bool lostConnection}) {
    lostConnection = lostConnection;
    notifyListeners();
  }

  String _nameSelector(String? fromTextField) {
    String _out;
    if (fromTextField != null && fromTextField != '') {
      _out = fromTextField;
      myRoomName = fromTextField;
      if (fromTextField != Setting.prefName) {
        Setting.prefName = fromTextField;
        Setting.saveString('name', fromTextField);
      }
    } else {
      _out = myDeviceName;
      myRoomName = myDeviceName;
    }
    return _out;
  }

  Future lobby(BuildContext context,
      {required LobbyType type,
      required String? name,
      required String? room}) async {
    name = _nameSelector(name);

    ///Navigate to online room screen when success.
    _toRoom() {
      _showInProgress(false);
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: kTransitionDur,
          transitionsBuilder: kPageTransition,
          pageBuilder: (_, __, ___) => OnlineRoom()));
    }

    _showInProgress(true);
    try {
      if (type == LobbyType.join) {
        _validateRoomInput(room);
        await _login();

        await _joinRoom(room!, name);

        _toRoom();
      } else if (type == LobbyType.create) {
        await _login();
        await _createRoom(name);
        _toRoom();
      }
    } catch (e) {
      _showInProgress(false);
      Snackbar.show(context,
          text: 'Error: \"$e\"', icon: kBluetoothIconDisconnected);
    }
  }

  /// Create a new session.
  Future _createRoom(String displayName) async {
    this.roomID = await _generateRoomID();
    try {
      ///Create firestore document by adding new member(self).
      await _fireStore.addMember(roomID, await Setting.getId(), displayName,
          isHost: true);

      ///Prepare room messages collection.
      await _fireStore.getMessageCol(roomID);

      ///Crate room command field.
      await _roomCommand('OPEN');

      ///Room create time. So, other member can display room's clock.
      await _fireStore.addColCustomField(
          roomID: this.roomID,
          fieldName: 'create_time',
          value: DateTime.now().millisecondsSinceEpoch,
          sender: myID);

      ///Add create by.
      await _fireStore.addColCustomField(
          roomID: this.roomID,
          fieldName: 'create_by',
          value: myID,
          sender: myID);

      ///When create, First set to mute.
      isMute = false;
      await _fireStore.addColCustomField(
          roomID: this.roomID, fieldName: 'mute', value: isMute, sender: myID);

      ///When create, First set to not hold.
      classroom.isHolding = false;
      await _fireStore.addColCustomField(
          roomID: this.roomID,
          fieldName: 'hold',
          value: classroom.isHolding,
          sender: myID);

      ///Mark as room host.
      _toggleRoomHost(true);

      await _onRoomEntered(id: this.roomID);
    } catch (e) {
      throw (kErr1005);
    }
  }

  void _showInProgress(bool inProgress) async {
    if (inProgress) {
      EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
      );
    } else {
      EasyLoading.dismiss();
    }
  }

  /// Join room >> check that input room ID is available first.
  /// Then check is myself is room host? (Found case when host minimize app
  /// for too long and OS kill the app.)
  Future _joinRoom(String id, String displayName) async {
    this.roomID = id;
    _validateRoomAvail(id);
    try {
      ///In case that host was kicked out for some reasons.(such as minimized
      ///app for too long while in room. -> app killed)
      ///When host re-join room, app need to know.
      String _roomHost = await _fireStore.getRoomData(
          sessionID: id, field: 'create_by', sender: myID);
      if (_roomHost == myID) _toggleRoomHost(true);

      ///Prepare room messages collection.
      await _fireStore.getMessageCol(roomID);

      ///Add member to room.
      await _fireStore.addMember(id, await Setting.getId(), displayName,
          isHost: this.isRoomHost);
      await _onRoomEntered(id: id);
    } catch (e) {
      throw (kErr1006);
    }
  }

  /// Function when entered room.
  Future _onRoomEntered({required String id}) async {
    ///For host, when entered online room. Listen to all connected device.
    ///for new connected device after entered the room, logic in connection
    ///state will know and auto listen to new device.
    if (isRoomHost) classroom.subscribeAllConnectedDevice();

    ///Subscribe to members document.
    _membersListener(id);

    Setting.inOnlineClass = true;

    ///Get room create time.
    roomCreateTime = await _fireStore.getRoomData(
        sessionID: id, field: 'create_time', sender: myID);

    ///Get current room mute mode.
    isMute = await _fireStore.getRoomData(
        sessionID: id, field: 'mute', sender: myID);

    ///Get current room hold mode.
    isHold = await _fireStore.getRoomData(
        sessionID: id, field: 'hold', sender: myID);
    if (isHold && !isRoomHost) _setHold(true);

    ///For children, listen to room messages and commands.
    if (!isRoomHost) _roomListener(id: id);

    notifyListeners();
  }

  void _toggleRoomHost(bool isHost) => this.isRoomHost = isHost;

  void toggleHoldCommand() async {
    _showInProgress(true);
    classroom.isHolding = !classroom.isHolding;
    notifyListeners();
    await _roomCommand(classroom.isHolding ? 'HOLD_ON' : 'HOLD_OFF');
    await _fireStore.addColCustomField(
      roomID: this.roomID,
      fieldName: 'hold',
      value: classroom.isHolding,
      sender: myID,
    );
    if (!classroom.isHolding) classroom.resetDisplay();
    _showInProgress(false);
  }

  Future<bool> toggleRoomMute() async {
    _showInProgress(true);
    isMute = !isMute;
    await _fireStore.addColCustomField(
        roomID: this.roomID, fieldName: 'mute', value: isMute, sender: myID);
    await _roomCommand(isMute ? 'MUTE_ON' : 'MUTE_OFF');
    notifyListeners();
    _showInProgress(false);
    return isMute;
  }

  /// Generate room ID via package 'nanoid'
  /// Re-generate if room number was taken(rare case).
  Future<String> _generateRoomID() async {
    late String _id;
    do {
      _id = customAlphabet('1234567890', kSessionIdLength);
    } while (await _fireStore.checkRoomAvail(_id));
    return _id;
  }

  /// to broadcast MIDI message via firestore service.
  void broadcastMessage(Uint8List raw) async {
    // if (raw.isNotEmpty && this.isRoomHost) {
    if (raw.isNotEmpty) {
      String _message = _messageEncryptor(raw: raw);
      bool holdingDup() => classroom.holdingKeys.contains(_message[kKeyPos]);
      if (!classroom.isHolding) {
        await _sendRoomMessage(_message);
      } else {
        if (raw[kSwitchPos] == kNoteOn && !holdingDup()) {
          await _sendRoomMessage(_message);
        }
      }
    }
  }

  /// Encrypt outgoing message from MIDI[Uint8List] to [double]
  /// Key's pressure as decimal place. (99 maximum)
  String _messageEncryptor({required Uint8List raw}) {
    int _switch = raw[kSwitchPos];
    int _note = raw[kKeyPos];
    late double _out;
    if (_switch == kNoteOn) {
      double _pressure = raw[kPressurePos] / 1000;
      _pressure >= 1 ? _pressure = 0.999 : _pressure = _pressure;
      _out = _switch + _note + _pressure;
    } else {
      _out = _note.roundToDouble();
    }
    return _out.toString();
  }

  /// To send out room command code (host's function).
  Future _roomCommand(String code) async {
    if (this.roomID != '')
      await _fireStore.addSessionMessageAndCtrl(
          this.roomID, 'CTRL', code, myID);
  }

  /// send MIDI message
  Future _sendRoomMessage(dynamic value) async => roomID != ''
      ? await _fireStore.addSessionMessageAndCtrl(
          roomID, 'message', value, myID)
      : null;

  /// <Currently closed> All members will listen to all MIDI message and room control
  /// but filter out own messages by checking sender = [myID].
  void _roomListener({required String id}) {
    this._roomMessageSubscribe =
        // _fireStore.col.doc(id).snapshots().listen((data) {
        _fireStore.messageCol
            .doc(kFireStoreMessageDoc)
            .snapshots()
            .listen((data) {
      switch (data['type']) {
        case 'message':
          if (data['sender'] != myID) {
            print('get message..........');
            classroom.sendLocal(
                _messageDecryptor(raw: double.parse(data['value'])),
                withLight: true,
                withSound: !this.isMute);
          }
          break;
        case 'CTRL':
          print('get control..........');
          _roomController(data['value']);
          break;
      }
    });
  }

  /// Decrypt incoming [double] message into MIDI([Uint8List])
  /// If message is NoteOn, value will greater than [kNoteOn] with
  /// key pressure as decimal place.
  Uint8List _messageDecryptor({required double raw}) {
    late int _switch;
    late int _note;
    late int _pressure;
    if (raw < kNoteOn) {
      //noteOff
      _switch = kNoteOff;
      _note = raw.floor();
      _pressure = 0;
    } else {
      //noteOn
      _switch = kNoteOn;
      _note = (raw - kNoteOn).floor();
      _pressure = ((raw - (raw.floor())) * 1000).floor();
      print('raw is: ${raw.toString()}');
      print('key is: ${_note.toString()}');
      print('pressure is: ${_pressure.toString()}');
    }
    return Uint8List.fromList([k128, k128, _switch, _note, _pressure]);
  }

  /// Receive room command function from cloud and do action.
  void _roomController(String value) {
    switch (value) {
      case 'CLOSE': //Room closed
        _onRoomExited();
        break;
      case 'MUTE_ON':
        print('listen mute got ON');
        isMute = true;
        // Setting.appListenMode = ListenMode.onMute;
        break;
      case 'MUTE_OFF':
        print('listen mute got OFF');
        isMute = false;
        // Setting.appListenMode = ListenMode.on;
        break;
      case 'HOLD_ON':
        _setHold(true);
        break;
      case 'HOLD_OFF':
        _setHold(false);

        break;
    }
  }

  void _setHold(bool hold) {
    this.isHold = hold;

    // ///When children got command from host to release hold. Reset all displaying
    // ///notes.(Staff, Piano, Light)

    //trigger [classroom.triggerHold(hold);] when got hold/release command also
    //work. but may have an issue if children got some [ON]music message before
    //got hold command which that music message will not stored in [holdingKeys]
    classroom.triggerHold(hold);
    // if (!hold) classroom.resetDisplay();
  }

  /// If host exit from room, room will close after
  Future roomExit(String id) async {
    _showInProgress(true);
    final int _members = membersList.length;
    await _fireStore.delMember(id, myID);
    if (isRoomHost || _members == 1) {
      await _roomCommand('CLOSE');
      await _fireStore.closeRoom(id);
      // _toggleRoomHost(false);
    }
    _onRoomExited();
    _showInProgress(false);
  }

  /// On exit event.
  void _onRoomExited() async {
    this._roomMessageSubscribe?.cancel();
    this._memberSubscribe?.cancel();
    _fireStore.cancelClockIn();
    roomID = '';
    Setting.inOnlineClass = false;
    isMute = false;
    if (isRoomHost) {
      await classroom.cancelDeviceSubscribe();
      _toggleRoomHost(false);
    } else {
      notifyListeners();
    }
  }

  void _membersListener(String sessionID) {
    _memberSubscribe = _fireStore.membersCol.snapshots().listen((data) {
      print('got update from members listener');
      final users = data.docs.map((doc) => doc.data()).toList();
      List<SessionMember> _preList = [];
      for (dynamic user in users) {
        _preList.add(SessionMember(
          id: user['id'],
          name: user['name'],
          isHost: user['host'],
          lastSeen: user['lastSeen'],
        ));
      }
      membersList.clear();
      membersList = _preList;
      notifyListeners();
    });
  }

  Future shareLink() async {
    _showInProgress(true);
    Uri _link = await _buildLink();
    await Share.share('Join MIDI Session at $_link/',
        subject: 'Invite to join MIDI session via Notero');
    _showInProgress(false);
  }

  Future<Uri> _buildLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: kPrefix,
        link: Uri.parse('$kDisplayUrl/join?$roomID/'),
        androidParameters: AndroidParameters(
          packageName: kBundle,
          minimumVersion: kAndroidMinVer,
        ),
        iosParameters: IosParameters(
          bundleId: kBundle,
          ipadBundleId: kBundle,
          minimumVersion: kAppStoreMinVer,
          appStoreId: kAppStoreId,
        ));
    // final Uri outUrl = await parameters.buildUrl();
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri outUrl = shortDynamicLink.shortUrl;
    return outUrl;
  }

  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///VALIDATION
  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  void _validateRoomInput(String? room) {
    if (room == null || room.length != kSessionIdLength) throw (kErr1001);
  }

  Future _validateRoomAvail(String room) async {
    if (await _fireStore.checkRoomAvail(room) == false) throw (kErr1003);
    if (await _fireStore.countMember(roomID) >= kMaxMember) throw (kErr1004);
  }

  Future _login() async {
    _user = await _auth.anonymousSignIn();
    if (_user == null) throw (kErr1002);
  }
}
