import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/analytics.dart';
import 'package:everlong/utils/constants.dart';

class FireStore {
  /// Collection in firestore
  late CollectionReference col;

  /// Message collection
  late CollectionReference messageCol;

  /// Member collection
  late CollectionReference membersCol;

  /// Config collection
  // late CollectionReference configsCol;

  /// Periodic function for check member's state function.
  Timer? _clockIn;

  Analytic analytic = Analytic();

  // FireStore(this.analytic);

  Future initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('error initializeFlutterFire: $e');
    }
  }

  CollectionReference getCollection() =>
      FirebaseFirestore.instance.collection(kFireStoreCollection);

  Future prepareCollections(String roomID) async {
    messageCol = col.doc(roomID).collection(kFireStoreMessageCol);
    membersCol = col.doc(roomID).collection(kFireStoreMemberCol);
    // configsCol = col.doc(roomID).collection('configs');
  }

  /// For message and session control value.
  Future addSessionMessageAndCtrl(
      String roomID, String type, String value, String sender) async {
    if (await Setting.isConnectToInternet()) {
      // await col
      // .doc(roomID)
      print('write: $value');
      await messageCol
          .doc(kFireStoreMessageDoc)
          .set(
            {'type': type, 'value': value, 'sender': sender},
            SetOptions(merge: true),
          )
          .then((value) => print("Message sent"))
          .catchError((error) => print("Failed to add message: $error"));
      await analytic.logSessionAnalytic(
        event: type,
        sessionID: roomID,
        sender: sender,
      );
    }
  }

  /// For other custom value.
  Future addColCustomField(
      {required String roomID,
      required String fieldName,
      required dynamic value,
      required String sender}) async {
    if (await Setting.isConnectToInternet()) {
      print('Firebase write: Add custom field: $value');
      await col
          .doc(roomID)
          // await configsCol
          //     .doc(kFireStoreConfigDoc)
          .set({fieldName: value}, SetOptions(merge: true))
          .then((value) => print("Message sent"))
          .catchError((error) => print("Failed to add message: $error"));
      await analytic.logSessionAnalytic(
        event: 'room_info_add',
        sessionID: roomID,
        sender: sender,
      );
    }
  }

  /// Function to add member to room. and periodically update timestamp
  /// to cloud for check member's state function.
  Future addMember(String roomID, String memberID, String name,
      {required bool isHost}) async {
    // membersCol = col.doc(roomID).collection('members');
    await _setMember(roomID, memberID, name, isHost);

    _clockIn = Timer.periodic(kClockInPeriod,
        (Timer t) => _clockInMember(roomID, memberID, name, isHost));
  }

  /// Cloud set function for member
  Future _setMember(
      String roomID, String memberID, String name, bool isHost) async {
    if (await Setting.isConnectToInternet()) {
      print('Firebase write: Update member');
      await membersCol
          .doc(memberID)
          .set({
            'name': name,
            'id': memberID,
            'host': isHost,
            'lastSeen': DateTime.now().millisecondsSinceEpoch
          })
          .then((value) => print("member added"))
          .onError((error, stackTrace) => print("on error"))
          .catchError((error) => print("Failed to add member: $error"));
      await analytic.logSessionAnalytic(
        event: 'member_add',
        sessionID: roomID,
        sender: memberID,
      );
    }
  }

  Future _clockInMember(
      String roomID, String memberID, String name, bool isHost) async {
    if (await Setting.isConnectToInternet()) {
      await membersCol
          .doc(memberID)
          .update({'lastSeen': DateTime.now().millisecondsSinceEpoch})
          .then((value) => print("member clocked in"))
          .onError((error, stackTrace) => print("on error"))
          .catchError((error) => print("Failed to add member: $error"));
      await analytic.logSessionAnalytic(
        event: 'member_clock_in',
        sessionID: roomID,
        sender: memberID,
      );
    }
  }

  Future<int> countMember(String roomID) async {
    int _count = 0;
    print('aa');
    CollectionReference _memberCollection =
        col.doc(roomID).collection(kFireStoreMemberCol);
    print('bb');
    await _memberCollection.get().then((querySnapshot) {
      final _members = querySnapshot.docs.map((doc) => doc.data()).toList();
      _count = _members.length;
      print('Room member check: $_count');
    });
    return _count;
  }

  /// Cancel periodically update member timestamp.
  void cancelClockIn() => _clockIn?.cancel();

  /// Cloud delete function for member
  Future delMember(String roomID, String memberID) async {
    cancelClockIn();
    await membersCol
        .doc(memberID)
        .delete()
        .then((value) => print("member deleted"))
        .catchError((error) => print("Failed to delete member: $error"));
  }

  /// Delete room function
  /// 1. delete available member from room.
  /// 2. delete room(doc)
  Future closeRoom(String roomID) async {
    WriteBatch _batch = FirebaseFirestore.instance.batch();
    await membersCol.get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        _batch.delete(document.reference);
      });
    });
    await _batch.commit();
    await col
        .doc(roomID)
        .delete()
        .then((value) => print("room deleted"))
        .catchError((error) => print("Failed to delete member: $error"));
  }

  /// To check is room ID is available.
  Future<bool> checkRoomAvail(String id) async {
    bool _result = false;
    if (await Setting.isConnectToInternet()) {
      await col.doc(id).get().then((value) {
        if (value.data() == null) {
          print('Room not exist');
        } else {
          print('Room $id is available');
          print(value['create_by']);
          _result = true;
        }
      });
    }
    return _result;
  }

  /// To get room's field[field] data.
  Future<dynamic> getRoomConfig(
      {required String sessionID,
      required String field,
      required String sender}) async {
    dynamic _result;
    // if (await Setting.isConnectToInternet())
    await col
        .doc(sessionID)
        .get()
        .then((value) => value.data() != null ? _result = value[field] : null);
    // await configsCol
    //     .doc(kFireStoreConfigDoc)
    //     .get()
    //     .then((value) => value.data() != null ? _result = value[field] : null);
    await analytic.logSessionAnalytic(
      event: 'session_query',
      sessionID: sessionID,
      sender: sender,
    );
    return _result;
  }
}
