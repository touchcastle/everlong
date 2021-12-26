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

  /// Student's Message collection
  late CollectionReference studentMessageCol;

  /// Room's files records
  late CollectionReference recordsCol;

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
    studentMessageCol = col.doc(roomID).collection(kFireStoreStudentMessageCol);
    recordsCol = col.doc(roomID).collection(kFireStoreRecordsCol);
    // configsCol = col.doc(roomID).collection('configs');
  }

  /// For message and session control value.
  Future addSessionMessageAndCtrl({
    required String roomID,
    required String type,
    required String value,
    required String sender,
    bool initialize = false,
  }) async {
    // if (await Setting.isConnectToInternet()) {
    // await col
    // .doc(roomID)
    initialize
        ? await messageCol.doc(kFireStoreMessageDoc).set(
            {'type': type, 'value': value, 'sender': sender},
            SetOptions(merge: true),
          )
        : type == 'CTRL'
            ? await messageCol.doc(kFireStoreMessageDoc).update(
                {'type': type, 'value': value, 'sender': sender},
              )
            : messageCol.doc(kFireStoreMessageDoc).update(
                {'type': type, 'value': value, 'sender': sender},
              );
    analytic.logSessionAnalytic(
      event: type,
      sessionID: roomID,
      sender: sender,
    );
    // }
  }

  /// For student send MIDI message
  Future addStudentMessage({
    required String roomID,
    required String type,
    required String value,
    required String sender,
    bool initialize = false,
  }) async {
    // if (await Setting.isConnectToInternet()) {
    initialize
        ? studentMessageCol.doc(kFireStoreMessageDoc).set(
            {'type': type, 'value': value, 'sender': sender},
            SetOptions(merge: true),
          )
        : studentMessageCol.doc(kFireStoreMessageDoc).update(
            {'type': type, 'value': value, 'sender': sender},
          );
    analytic.logSessionAnalytic(
      event: 'student_midi',
      sessionID: roomID,
      sender: sender,
    );
    // }
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
      analytic.logSessionAnalytic(
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
            'lastSeen': DateTime.now().millisecondsSinceEpoch,
            'listenable': false,
          })
          .then((value) => print("member added"))
          .onError((error, stackTrace) => print("on error"))
          .catchError((error) => print("Failed to add member: $error"));
      analytic.logSessionAnalytic(
        event: 'member_add',
        sessionID: roomID,
        sender: memberID,
      );
    }
  }

  Future _clockInMember(
      String roomID, String memberID, String name, bool isHost) async {
    // if (await Setting.isConnectToInternet()) {
    // await membersCol
    membersCol
        .doc(memberID)
        .update({'lastSeen': DateTime.now().millisecondsSinceEpoch})
        // .then((value) => print("member clocked in"))
        .onError((error, stackTrace) => print("clock in error"))
        .catchError((error) => print("Failed to add member: $error"));

    analytic.logSessionAnalytic(
      // await analytic.logSessionAnalytic(
      event: 'member_clock_in',
      sessionID: roomID,
      sender: memberID,
    );
    // }
  }

  Future toggleMemberListenable({
    required String memberId,
    required bool listenable,
  }) async {
    // if (await Setting.isConnectToInternet()) {
    membersCol.doc(memberId).update({'listenable': listenable});
    // }
  }

  Future<int> countMember(String roomID) async {
    int _count = 0;
    CollectionReference _memberCollection =
        col.doc(roomID).collection(kFireStoreMemberCol);
    await _memberCollection.get().then((querySnapshot) {
      final _members = querySnapshot.docs.map((doc) => doc.data()).toList();
      _count = _members.length;
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
    //Room's message
    await messageCol.doc(kFireStoreMessageDoc).delete();

    //Student's message
    await studentMessageCol.doc(kFireStoreMessageDoc).delete();

    //Members
    WriteBatch _batch = FirebaseFirestore.instance.batch();
    await membersCol.get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        _batch.delete(document.reference);
      });
    });

    //Records
    await recordsCol.get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        _batch.delete(document.reference);
      });
    });
    await _batch.commit();

    await col.doc(roomID).delete();
    // //Record delete
    // WriteBatch _recBatch = FirebaseFirestore.instance.batch();
    // await recordsCol.get().then((querySnapshot) {
    //   querySnapshot.docs.forEach((document) {
    //     _recBatch.delete(document.reference);
    //   });
    // });
    // await _recBatch.commit();
  }

  /// To check is room ID is available.
  Future<bool> checkRoomAvail(String id) async {
    bool _result = false;
    if (await Setting.isConnectToInternet()) {
      await col.doc(id).get().then((value) {
        if (value.data() == null) {
          print('Room not exist');
        } else {
          print('Room $id is existed');
          print(value['create_by']);
          _result = true;
        }
      });
    }
    return _result;
  }

  /// To check is record ID is available.
  Future<bool> checkRecordAvail(String id) async {
    bool _result = false;
    if (await Setting.isConnectToInternet()) {
      await recordsCol.doc(id).get().then((value) {
        if (value.data() == null) {
          print('Record not exist');
        } else {
          print('Record $id is existed');
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

  /// Share midi record to room.
  Future addRecord(
      {required String roomID,
      required String memberID,
      required String recordID,
      required String recordName,
      required String totalTimeSecText,
      required String data}) async {
    if (await Setting.isConnectToInternet()) {
      print('Firebase write: upload record');
      await recordsCol
          .doc(recordID)
          .set({
            'name': recordName,
            'id': recordID,
            'by': memberID,
            'totalTimeSecText': totalTimeSecText,
            'data': data,
          })
          .then((value) => print("record added"))
          .onError((error, stackTrace) => print("on error"))
          .catchError((error) => print("Failed to add record: $error"));
      await analytic.logSessionAnalytic(
        event: 'record_add',
        sessionID: roomID,
        sender: memberID,
      );
    }
  }

  /// upload midi record's name.
  Future renameRecord({required String recordID, required newName}) async {
    await recordsCol
        .doc(recordID)
        .update({'name': newName})
        .then((value) => print("record updated"))
        .catchError((error) => print("Failed to update record: $error"));
  }

  /// delete midi record.
  Future delRecord({required String recordID}) async {
    await recordsCol
        .doc(recordID)
        .delete()
        .then((value) => print("record deleted"))
        .catchError((error) => print("Failed to delete record: $error"));
  }
}
