import 'package:firebase_auth/firebase_auth.dart';
import 'package:everlong/services/setting.dart';

class Auth {
  late FirebaseAuth auth;

  void initAuth() {
    auth = FirebaseAuth.instance;
  }

  Future<UserCredential?> anonymousSignIn() async {
    try {
      UserCredential _user = await auth.signInAnonymously();
      return _user;
    } on FirebaseAuthException catch (e) {
      print('authentication error: $e');
    }
  }
}
