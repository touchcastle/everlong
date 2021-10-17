import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/ui/views/online_lobby.dart';
import 'package:everlong/utils/constants.dart';

class UrlHandler {
  static bool _initialUriIsHandled = false;
  // static Uri? _initialUri;
  // static Uri? _latestUri;
  // static Object? _err;
  static StreamSubscription? uniLinkSub;

  static void handleIncomingLinks(BuildContext context) {
    // handleDynamicLink(context);
    // // It will handle app links while the app is already started - be it in
    // // the foreground or in the background
    // print('prepare to sub link');
    // uniLinkSub = uriLinkStream.listen((Uri? uri) {
    //   print('uri link: $uri');
    //   if (Setting.inOnlineClass == false) {
    //     _navigateToJoin(uri!.toString(), context);
    //   } else {
    //     Snackbar.show(context, text: 'Cannot join while in class.');
    //   }
    // }, onError: (Object err) {
    //   print('got err: $err');
    // });
  }

  static void cancel() => uniLinkSub?.cancel();

  static void handleDynamicLink(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;
      if (deepLink != null) {
        print('Dynamic link function : ${deepLink.toString()}');
        if (!Setting.inOnlineClass) {
          _navigateToJoin(deepLink.toString(), context);
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    print('init link');
    if (deepLink != null) {
      print('Dynamic initial link function: ${deepLink.toString()}');
      _navigateToJoin(deepLink.toString(), context);
    }
  }

  static void handleInitialUri(BuildContext context) async {
    // if (!_initialUriIsHandled) {
    //   _initialUriIsHandled = true;
    //   print('_handleInitialUri called');
    //   try {
    //     // _navigateToJoin('https1://pastel.com/join?123456789/', context,
    //     //     fromInit: false);
    //     final uri = await getInitialUri();
    //     if (uri == null) {
    //       print('no initial uri');
    //     } else {
    //       print('got initial uri: $uri');
    //       _navigateToJoin(uri.toString(), context, fromInit: false);
    //     }
    //   } catch (e) {
    //     print('failed to get initial uri: $e');
    //   }
    // }
  }

  static void _navigateToJoin(String url, BuildContext context,
      {bool fromInit = false}) {
    RegExp _regExp = RegExp(
      r"(?<=join\?)(.*?)(?=\s*\/)",
      caseSensitive: false,
      multiLine: false,
    );
    print(url);
    String joinID = _regExp.stringMatch(url).toString();
    print(joinID);
    if (Setting.sessionMode == SessionMode.online) {
      Navigator.popUntil(context, ModalRoute.withName(kMainPageName));
    } else if (Setting.sessionMode == SessionMode.offline) {
      print('pass offline');
      Navigator.popUntil(context, ModalRoute.withName(kMainPageName));
      Setting.sessionMode = SessionMode.online;
      // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //     settings: RouteSettings(name: "/main_menu_page"),
      //     builder: (BuildContext context) => MainMenu()));
    } else if (Setting.sessionMode == SessionMode.none) {
      print('pass none');
      Setting.sessionMode = SessionMode.online;
      // Navigator.of(context).push(MaterialPageRoute(
      //     settings: RouteSettings(name: "/online_menu_page"),
      //     builder: (BuildContext context) => MainMenu()));
    }

    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: kTransitionDur,
      transitionsBuilder: kPageTransition,
      pageBuilder: (_, __, ___) =>
          OnlineLobby(roomID: joinID, lobbyType: LobbyType.join),
      // fullscreenDialog: true,
    ));

    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (BuildContext context) =>
    //         OnlineLobby(roomID: joinID, inType: InType.join),
    //     fullscreenDialog: true));
  }
}
