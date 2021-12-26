import 'package:firebase_analytics/firebase_analytics.dart';

class Analytic {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  Future<void> logSessionAnalytic({
    required String event,
    required String sessionID,
    required String? sender,
  }) async {
    await analytics.logEvent(
      name: event,
      parameters: <String, dynamic>{
        'session_id': sessionID,
        'by': sender ?? '',
      },
    );
  }

  // Future logShare() async => await analytics.logShare(
  //     contentType: 'test share content type',
  //     itemId: '12345',
  //     method: 'method');
}
