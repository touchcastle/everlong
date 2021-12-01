import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/bluetooth.dart';
import 'package:everlong/services/database.dart';
import 'package:everlong/services/device_db.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/ui/views/landing.dart';
import 'package:everlong/ui/views/local.dart';
import 'package:everlong/ui/views/main_menu.dart';
import 'package:everlong/ui/views/online_lobby.dart';
import 'package:sizer/sizer.dart';
import 'package:everlong/utils/styles.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:everlong/utils/easy_loading_config.dart';
import 'package:everlong/utils/constants.dart';

void main() async {
  /// Database initialization and query.
  WidgetsFlutterBinding.ensureInitialized();

  DeviceDatabase db = DeviceDatabase();
  ListAnimation ui = ListAnimation();
  // Analytic analytic = Analytic();
  // FireStore fireStore = FireStore(analytic);
  Classroom classroom = Classroom(db, ui);
  // Online online = Online(classroom, fireStore, analytic);
  Online online = Online(classroom);
  Recorder recorder = Recorder(classroom);
  BluetoothControl bluetooth =
      BluetoothControl(classroom, online, recorder, db, ui);

  var provider = MultiProvider(
    providers: [
      ListenableProvider<BluetoothControl>(create: (_) => bluetooth),
      Provider<DeviceDatabase>(create: (_) => db),
      Provider<ListAnimation>(create: (_) => ui),
      ListenableProvider<Online>(create: (_) => online),
      ListenableProvider<Recorder>(create: (_) => recorder),
      ListenableProvider<Classroom>(create: (_) => classroom),
    ],
    child: Everlong(),
  );

  await DatabaseService.openDB();
  configLoading();
  runApp(provider);
}

class Everlong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: LandingScreen.id,
        theme: ThemeData(fontFamily: kPrimaryFontFamily),
        routes: {
          LandingScreen.id: (context) => LandingScreen(),
          LocalPage.id: (context) => LocalPage(),
          MainMenu.id: (context) => MainMenu(),
          OnlineLobby.id: (context) => OnlineLobby(),
        },
        builder: EasyLoading.init(),
      );
    });
  }
}
