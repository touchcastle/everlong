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
import 'package:everlong/ui/views/online/online_room.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/midi.dart';
import 'package:everlong/utils/errors.dart';
import 'package:everlong/utils/texts.dart';

enum LobbyType {
  create,
  join,
}

class RoomRecords {
  String id;
  String name;
  String by;
  String totalTimeSecText;
  String data;

  RoomRecords({
    required this.id,
    required this.name,
    required this.by,
    required this.totalTimeSecText,
    required this.data,
  });
}

class Online extends ChangeNotifier {
  ///Room ID
  String roomID = '';

  ///Google FireStore
  FireStore _fireStore = FireStore();

  Classroom classroom;

  ///Authentication
  Auth _auth = Auth();
  late UserCredential? user;

  ///Subscription to room message and command.
  dynamic _sessionMessageSubscribe;
  dynamic _studentMessageSubscribe;
  bool isRoomHost = false;
  bool imListenable = false;
  bool lostConnection = false;
  bool isMute = false;

  ///Just a flag for future purpose.
  ///Holding was already managed from host's key pressed stage.
  bool isHold = false;

  late int roomCreateTime;

  ///Device's UUID
  // late String myID;

  ///Device's system name
  late String myDeviceName;

  ///Name in room
  late String myRoomName;

  bool roomClosed = false;
  // bool memberSorted = false;

  dynamic _memberSubscribe;
  List<SessionMember> membersList = [];

  dynamic _recordSubscribe;
  List<RoomRecords> recordsList = [];

  int memberCount = 0;

  ///Constructor.
  Online(this.classroom);

  Future initFirebase() async {
    await _fireStore.initializeFlutterFire();
    myDeviceName = await Setting.getName();
  }

  Future init() async {
    _auth.initAuth();
    _fireStore.col = _fireStore.getCollection();
    await _login();
  }

  ///User ID (device uuid).
  String _uid() => user!.user!.uid;

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
        Setting.saveString(kNamePref, fromTextField);
      }
    } else {
      _out = myDeviceName;
      myRoomName = myDeviceName;
    }
    return _out;
  }

  ///To create or join session.
  Future lobby(BuildContext context,
      {required LobbyType type,
      required String? name,
      required String? room}) async {
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
      // ///Initialize online session variables and parameters.
      // await init();
      name = _nameSelector(name);
      if (type == LobbyType.join) {
        await _validateRoomInput(room);
        await _validateRoomAvail(room!);
        await _joinRoom(room, name);
        _toRoom();
      } else if (type == LobbyType.create) {
        await _createRoom(name);
        _toRoom();
      }
    } catch (e) {
      _showInProgress(false);
      print('$e');
      String _msg() => e.toString() != '' ? e.toString() : kGoogleError;
      Snackbar.show(
        context,
        text: '$kError: ${_msg()}',
        icon: kBluetoothIconDisconnected,
        actionLabel: kOk,
        verticalMargin: false,
        dialogWidth: true,
      );
    }
  }

  /// Create a new session.
  Future _createRoom(String displayName) async {
    this.roomID = await _generateRoomID();
    try {
      /// Close any existing room with same host.
      await _fireStore.closeExisting(uuid: _uid());

      ///Prepare room collections.
      await _fireStore.prepareCollections(roomID);

      ///Create firestore document by adding new member(self).
      await _fireStore.addMember(
        roomID,
        // await Setting.getId(),
        _uid(),
        displayName,
        isHost: true,
      );

      ///Crate room command field.
      await _roomCommand('OPEN', initialize: true);

      ///Room create time. So, other member can display room's clock.
      await _fireStore.addColCustomField(
          roomID: this.roomID,
          fieldName: 'create_time',
          value: DateTime.now().millisecondsSinceEpoch,
          sender: _uid());

      ///Add create by.
      await _fireStore.addColCustomField(
          roomID: this.roomID,
          fieldName: 'create_by',
          value: _uid(),
          sender: _uid());

      ///When create, First set to mute.
      isMute = false;
      await _fireStore.addColCustomField(
          roomID: this.roomID,
          fieldName: 'mute',
          value: isMute,
          sender: _uid());

      ///When create, First set to not hold.
      classroom.isHolding = false;
      await _fireStore.addColCustomField(
          roomID: this.roomID,
          fieldName: 'hold',
          value: classroom.isHolding,
          sender: _uid());

      ///Mark as room host.
      _toggleRoomHost(true);

      await _onRoomEntered(id: this.roomID);

      //reset joined session id when create.
      Setting.joinedSession('');
    } catch (e) {
      throw (kErr1005);
      // throw (e);
    }
  }

  void _showInProgress(bool inProgress) async {
    if (inProgress) {
      EasyLoading.show(
        status: 'Loading...',
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

    ///Prepare room messages collection.
    await _fireStore.prepareCollections(roomID);

    // _validateRoomAvail(id);
    try {
      ///In case that host was kicked out for some reasons.(such as minimized
      ///app for too long while in room. -> app killed)
      ///When host re-join room, app need to know.
      String _roomHost = await _fireStore.getRoomConfig(
          sessionID: id, field: 'create_by', sender: _uid());
      if (_roomHost == _uid()) {
        _toggleRoomHost(true);
      } else {
        _toggleRoomHost(false);
      }

      ///Add member to room.
      await _fireStore.addMember(
        id,
        // await Setting.getId(),
        user!.user!.uid,
        displayName,
        isHost: this.isRoomHost,
      );
      await _onRoomEntered(id: id);
      Setting.joinedSession(id);
    } catch (e) {
      throw (kErr1006);
    }
  }

  /// Function when entered room.
  Future _onRoomEntered({required String id}) async {
    ///when entered online room. Listen to all connected device.
    ///for new connected device after entered the room, logic in connection
    ///state will know and auto listen to new device.
    // if (isRoomHost) classroom.subscribeAllConnectedDevice();
    classroom.subscribeAllConnectedDevice();

    ///Subscribe to members document.
    _membersListener(id);

    ///Subscribe to records document.
    _recordsListener(id);

    Setting.inOnlineClass = true;
    roomClosed = false;

    ///Get room create time.
    roomCreateTime = await _fireStore.getRoomConfig(
        sessionID: id, field: 'create_time', sender: _uid());

    ///Get current room mute mode.
    isMute = await _fireStore.getRoomConfig(
        sessionID: id, field: 'mute', sender: _uid());

    ///Get current room hold mode.
    isHold = await _fireStore.getRoomConfig(
        sessionID: id, field: 'hold', sender: _uid());
    if (isHold && !isRoomHost) _setHold(true);

    ///For children, listen to room messages and commands.
    if (!isRoomHost) _sessionMessageListener(id: id);
    if (isRoomHost) _studentMessageListener();

    classroom.resetDisplay();

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
      sender: _uid(),
    );
    if (!classroom.isHolding) {
      classroom.resetDisplay();
      classroom.holdingKeys.clear();
    }
    _showInProgress(false);
  }

  void toggleResetCommand() async {
    // _showInProgress(true);
    await _roomCommand('RESET');
    // _showInProgress(false);
  }

  Future<bool> toggleRoomMute() async {
    _showInProgress(true);
    isMute = !isMute;
    await _fireStore.addColCustomField(
        roomID: this.roomID, fieldName: 'mute', value: isMute, sender: _uid());
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
      // String _message = _messageEncryptor(raw: raw);
      print('broadcast ${raw}');
      String _message = Setting.messageEncryptor(raw: raw);
      bool _holdingDup() => classroom.holdingKeys.contains(raw[kKeyPos]);
      bool _isNoteOnWhileHolding() =>
          classroom.isHolding && (raw[kSwitchPos] == kNoteOn && !_holdingDup());
      if (this.isRoomHost) {
        //Broadcast from room host.
        if (!classroom.isHolding || _isNoteOnWhileHolding()) {
          //check whether host want feedback from local or online
          if (!Setting.hostOnlineFeedback) {
            classroom.staffDisplay(raw);
          }
          if (classroom.isHolding) classroom.holdingKeys.add(raw[kKeyPos]);
          _sendRoomMessage(_message);
        }
      } else if (this.imListenable) {
        // Broadcast from student.
        // Student will broadcast message only between C3 and B5
        if (raw[kKeyPos] >= 48 && raw[kKeyPos] <= 83) {
          _sendStudentMessage(_message);
        }
      }
    }
  }

  /// To send out room command code (host's function).
  Future _roomCommand(String code, {bool initialize = false}) async {
    if (this.roomID != '') {
      try {
        await _fireStore.addSessionMessageAndCtrl(
            roomID: this.roomID,
            type: 'CTRL',
            value: code,
            sender: _uid(),
            initialize: initialize);
        if (initialize) {
          await _fireStore.addStudentMessage(
              roomID: this.roomID,
              type: 'CTRL',
              value: code,
              sender: _uid(),
              initialize: true);
        }
      } catch (e) {
        _showInProgress(false);
        print('$e');
        Snackbar.show(
          Setting.currentContext!,
          text: '$kError: $kGoogleError',
          icon: kBluetoothIconDisconnected,
          verticalMargin: false,
        );
      }
    }
  }

  /// send MIDI message
  Future _sendRoomMessage(dynamic value) async => roomID != ''
      ? _fireStore.addSessionMessageAndCtrl(
          roomID: roomID, type: 'message', value: value, sender: _uid())
      : null;

  /// send MIDI message by student
  Future _sendStudentMessage(dynamic value) async => roomID != ''
      ? _fireStore.addStudentMessage(
          roomID: roomID, type: 'message', value: value, sender: _uid())
      : null;

  void _sessionMessageListener(
      {required String id, bool hostFeedback = false}) {
    this._sessionMessageSubscribe = _fireStore.messageCol
        .doc(kFireStoreMessageDoc)
        .snapshots()
        .listen((data) {
      switch (data['type']) {
        case 'message':
          // if (data['sender'] != _uid()) {
          print('GOT ${data['value']}');
          classroom.sendLocal(
            Setting.messageDecryptor(raw: double.parse(data['value'])),
            withLight: true,
            withSound: hostFeedback ? false : !this.isMute,
          );
          // }
          break;
        case 'CTRL':
          _roomController(data['value']);
          break;
      }
    });
  }

  /// Receive room command function from cloud and do action.
  void _roomController(String value) {
    switch (value) {
      case 'CLOSE': //Room closed
        roomClosed = true;
        _onRoomExited();
        break;
      case 'MUTE_ON':
        isMute = true;
        // Setting.appListenMode = ListenMode.onMute;
        break;
      case 'MUTE_OFF':
        isMute = false;
        // Setting.appListenMode = ListenMode.on;
        break;
      case 'HOLD_ON':
        _setHold(true);
        break;
      case 'HOLD_OFF':
        _setHold(false);
        break;
      case 'RESET':
        classroom.resetKeyLight();
        classroom.resetDisplay();
        break;
    }
  }

  void _setHold(bool hold) {
    this.isHold = hold;
    classroom.triggerHold(hold);
  }

  /// If host exit from room, room will close after
  Future roomExit(String id) async {
    _showInProgress(true);
    if (isRoomHost) {
      await _roomCommand('CLOSE');
      _storeSubCancel();
      await _fireStore.closeRoom(id);
      _onRoomExited(withSubCancel: false);
    } else {
      await _fireStore.delMember(id, _uid());
      _onRoomExited();
    }
    _showInProgress(false);

    //1.1.0 logic
    // _showInProgress(true);
    // final int _members = membersList.length;
    // if (isRoomHost || _members == 1) {
    //   await _roomCommand('CLOSE');
    // }
    // await _fireStore.delMember(id, _uid());
    // if (isRoomHost || _members == 1) {
    //   _storeSubCancel();
    //   await _fireStore.closeRoom(id);
    // }
    // _onRoomExited();
    // _showInProgress(false);
  }

  /// On exit event.
  void _onRoomExited({bool withSubCancel = true}) async {
    if (withSubCancel) _storeSubCancel();
    _fireStore.cancelClockIn();
    roomID = '';
    Setting.inOnlineClass = false;
    if (isRoomHost) {
      await classroom.cancelDeviceSubscribe();
      _toggleRoomHost(false);
    } else {
      await classroom.cancelDeviceSubscribe();
      notifyListeners();
    }

    // Refresh room parameters
    isRoomHost = false;
    imListenable = false;
    lostConnection = false;
    isMute = false;
    isHold = false;
    roomCreateTime = 0;
    membersList.clear();
    recordsList.clear();
    Setting.hostOnlineFeedback = false;
  }

  void _storeSubCancel() {
    this._sessionMessageSubscribe?.cancel();
    this._memberSubscribe?.cancel();
    this._studentMessageSubscribe?.cancel();
    this._recordSubscribe?.cancel();
  }

  void toggleHostFeedback() {
    Setting.hostOnlineFeedback = !Setting.hostOnlineFeedback;
    if (Setting.hostOnlineFeedback) {
      _sessionMessageListener(id: roomID, hostFeedback: true);
    } else {
      this._sessionMessageSubscribe?.cancel();
    }
    notifyListeners();
  }

  ///Keep listen to change in members collection in firestore.
  ///Don't refresh all data but one-by-one compare instead to prevent
  ///student virtual piano being refresh.
  ///
  ///When will this snapshots got update?
  ///- New member
  ///- Member leave room
  ///- Member clock in
  ///- Host toggle member's listenable flag
  void _membersListener(String sessionID) {
    _memberSubscribe = _fireStore.membersCol.snapshots().listen((data) {
      final users = data.docs.map((doc) => doc.data()).toList();
      List<SessionMember> _preList = [];
      for (dynamic user in users) {
        _preList.add(SessionMember(
          id: user['id'],
          name: user['name'],
          isHost: user['host'],
          lastSeen: user['lastSeen'],
          listenable: user['listenable'],
        ));
        _updateMyListenable(
            memberId: user['id'], listenable: user['listenable']);
      }

      ///Modify current member list
      for (int _i = 0; _i < membersList.length; _i++) {
        int _avail = _preList.indexWhere((e) => e.id == membersList[_i].id);
        if (_avail >= 0) {
          membersList[_i].lastSeen = _preList[_avail].lastSeen;
          membersList[_i].name = _preList[_avail].name;
          membersList[_i].isHost = _preList[_avail].isHost;
          membersList[_i].listenable = _preList[_avail].listenable;
        } else {
          membersList[_i].isSignedOut = true;
        }
      }

      ///Delete signed out member
      membersList.removeWhere((e) => e.isSignedOut);

      ///Append new member
      if (_preList.length > 0) {
        for (int _i = 0; _i < _preList.length; _i++) {
          int _new = membersList.indexWhere((e) => e.id == _preList[_i].id);
          if (_new < 0) {
            _preList[_i].initPiano();
            membersList.add(_preList[_i]);
          }
        }
      }

      ///Show host first
      ///Only re-order when first member in list is not host
      // if (!memberSorted) {
      if (membersList.length > 0 && membersList[0].isHost == false) {
        membersList.sort((a, b) => a.isHost ? -1 : 1);
        // memberSorted = true;
      }

      memberCount = membersList.length;

      ///Change requirement to always show
      ///Close record's view when member less than 2
      // if (memberCount <= 1 && classroom.showRecorder)
      //   classroom.toggleRecordManagerDisplay();

      notifyListeners();
    });
  }

  void _recordsListener(String sessionID) {
    _recordSubscribe = _fireStore.recordsCol.snapshots().listen((data) {
      print('listing records');
      final records = data.docs.map((doc) => doc.data()).toList();
      print('got ${records.length} records');
      List<RoomRecords> _preList = [];
      for (dynamic record in records) {
        _preList.add(RoomRecords(
          id: record['id'],
          name: record['name'],
          by: record['by'],
          totalTimeSecText: record['totalTimeSecText'],
          data: record['data'],
        ));
      }

      ///Deleted
      recordsList
          .removeWhere((e) => _preList.indexWhere((p) => p.id == e.id) < 0);

      ///Modify current member list
      ///Still no case
      // for (int _i = 0; _i < recordsList.length; _i++) {
      //   int _avail = _preList.indexWhere((e) => e.id == recordsList[_i].id);
      //   if (_avail >= 0) {
      //     //do nothing if already avail.
      //   }
      // }

      ///Append new records
      if (_preList.length > 0) {
        for (int _i = 0; _i < _preList.length; _i++) {
          int _new = recordsList.indexWhere((e) => e.id == _preList[_i].id);
          if (_new < 0) {
            recordsList.add(_preList[_i]);
          }
        }
      }

      notifyListeners();
    });
  }

  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///MIRROR FROM STUDENT
  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///
  ///[Host's function]
  ///Toggle students listenable mode by set flag locally and update firestore.
  Future toggleMemberListenable(
      {required String memberId, required bool listenable}) async {
    // Not toggle myself.
    if (memberId != _uid()) {
      int _i = membersList.indexWhere((d) => d.id == memberId);
      if (_i >= 0) {
        await _fireStore.toggleMemberListenable(
            memberId: memberId, listenable: listenable);
        membersList[_i].toggleListenable(listenable);
        membersList[_i].piano.resetDisplay();
      }
      notifyListeners();
    }
  }

  ///[Student's function]
  ///Since all member listening to change in members collection on firestore,
  ///When got an update from firestore, locally check if listenable flag of
  ///myself is still the same? if not, then perform some action.
  void _updateMyListenable(
      {required String memberId, required bool listenable}) {
    if (!this.isRoomHost &&
        memberId == _uid() &&
        listenable != this.imListenable) {
      this.imListenable = listenable;
      // 29-JAN-2020: always listen to keyboard.
      // if (this.imListenable) {
      //   classroom.subscribeAllConnectedDevice();
      // } else {
      //   classroom.cancelDeviceSubscribe();
      // }
    }
  }

  ///Function to keep listen to student_message collection on firestore.
  void _studentMessageListener() {
    this._studentMessageSubscribe = _fireStore.studentMessageCol
        .doc(kFireStoreMessageDoc)
        .snapshots()
        .listen((data) {
      switch (data['type']) {
        case 'message':
          //Only display student's playing notes in on corresponding student's
          //virtual piano.
          int _i = membersList.indexWhere((d) => d.id == data['sender']);
          if (_i >= 0) {
            Uint8List _data =
                Setting.messageDecryptor(raw: double.parse(data['value']));
            // _messageDecryptor(raw: double.parse(data['value']));
            if (_data[kSwitchPos] == kNoteOn) {
              membersList[_i].piano.addPressing(_data[kKeyPos]);
              notifyListeners();
            } else if (_data[kSwitchPos] == kNoteOff) {
              membersList[_i].piano.removePressing(_data[kKeyPos]);
              notifyListeners();
            }
          }
          break;
      }
    });
  }

  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///DYNAMIC LINKS
  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
      ),
    );

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri outUrl = shortDynamicLink.shortUrl;
    return outUrl;
  }

  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///VALIDATION
  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Future _validateRoomInput(String? room) async {
    if (room == null || room.length != kSessionIdLength) throw (kErr1001);
  }

  Future _validateRoomAvail(String room) async {
    if (await _fireStore.checkRoomAvail(room) == false) throw (kErr1003);
    if (await _fireStore.countMember(room) >= kMaxMember) throw (kErr1004);
  }

  Future _login() async {
    user = await _auth.anonymousSignIn();
    if (user == null) throw (kErr1002);
  }

  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///SHARE RECORDS
  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///
  ///Upload record to firestore as [String]
  Future uploadRecord(
      {required String recordID,
      required String recordName,
      required String totalTimeSecText,
      required String data}) async {
    _showInProgress(true);

    // check whether record already uploaded?
    bool _existed = await _fireStore.checkRecordAvail(recordID);
    if (!_existed) {
      await _fireStore.addRecord(
          roomID: roomID,
          memberID: _uid(),
          recordID: recordID,
          recordName: recordName,
          totalTimeSecText: totalTimeSecText,
          data: data);
    } else {
      print('existed');
    }
    _showInProgress(false);
  }

  ///Delete record in firestore.
  Future delRecord({required String recordID}) async {
    _showInProgress(true);
    await _fireStore.delRecord(recordID: recordID);
    _showInProgress(false);
  }
}
