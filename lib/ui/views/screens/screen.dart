import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:everlong/utils/styles.dart';
import 'package:flutter/widgets.dart';
import 'package:everlong/services/staff.dart' as staffService;
import 'package:everlong/services/setting.dart';
import 'package:everlong/models/staff.dart';
import 'package:everlong/ui/views/screens/playing_info.dart';
import 'package:everlong/ui/views/screens/staffs.dart';
import 'package:everlong/ui/views/screens/notes.dart';
import 'package:everlong/ui/views/screens/key_signature.dart';
import 'package:everlong/ui/widgets/actions/host_feedback_switch.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/images.dart';
import 'package:everlong/utils/icons.dart';

enum KeySig {
  f,
  g,
}

class Screen extends StatefulWidget {
  final double width;
  final double height;
  Screen({this.width = 0, this.height = 0});
  @override
  _ScreenState createState() => new _ScreenState();
}

class _ScreenState extends State<Screen> {
  // ui.Image? imageSharp;
  // ui.Image? imageFlat;
  DrawableRoot? sharpSvg;
  DrawableRoot? flatSvg;

  double _minHeight = 200;
  double _baseHeight = 200;
  double _height = 200;
  // final double _width = 300;

  final double _keySignatureLeftPadding = 10;

  // final EdgeInsetsGeometry _keyGImagePadding = EdgeInsets.only(top: 108);
  // final EdgeInsetsGeometry _keyFImagePadding = EdgeInsets.only(top: 1, left: 5);
  //
  // Widget _keyFImage() => svgIcon(name: kKeyFImage, width: 45);
  // Widget _keyGImage() => svgIcon(name: kKeyGImage, width: 33);

  // DrawableRoot? svgRoot;
//   final String rawSvg =
//       '''<svg width="32" height="24" viewBox="0 0 32 24" fill="none" xmlns="http://www.w3.org/2000/svg">
// <path fill-rule="evenodd" clip-rule="evenodd" d="M16 23C24.2843 23 31 18.0751 31 12C31 5.92487 24.2843 1 16 1C7.71573 1 1 5.92487 1 12C1 18.0751 7.71573 23 16 23ZM8.69291 16.125C10.5051 19.194 15.2457 19.8352 19.2812 17.557C23.3168 15.2788 25.1193 10.944 23.3071 7.875C21.4949 4.80596 16.7543 4.16483 12.7187 6.443C8.68315 8.72118 6.88072 13.056 8.69291 16.125Z" fill="#EC0F47"/>
// </svg>''';

  @override
  void initState() {
    // loadImage(kSharpSigImage, isSharp: true);
    // loadImage(kFlatSigImage, isSharp: false);
    loadSVG();
    super.initState();
  }

  Future loadSVG() async {
    sharpSvg = await svg.fromSvgString(kSharpIcon, kSharpIcon);
    flatSvg = await svg.fromSvgString(kFlatIcon, kFlatIcon);
  }

  double _width() {
    double _result = Setting.deviceWidth * 0.9;
    if (_result > 300) _result = 300;
    return _result;
  }

  // Future loadImage(String path, {required bool isSharp}) async {
  //   final data = await rootBundle.load(path);
  //   final bytes = data.buffer.asUint8List();
  //   final image = await decodeImageFromList(bytes);
  //   setState(() => isSharp ? this.imageSharp = image : this.imageFlat = image);
  // }

  Stack _musicNotationPainter(
    BuildContext context,
    List<StaffStore> _playing,
    Size _size, {
    required KeySig keySig,
  }) {
    return Stack(
      children: [
        Center(
          child: staffsPainter(
            context,
            keySig: keySig,
            width: _width(),
            height: _height,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: _keySignatureLeftPadding),
            keyImage(
              keySig: keySig,
              width: _width(),
              height: _height,
            ),
            notesPainter(
              _playing,
              _size,
              keySig: keySig,
              width: _width(),
              height: _height,
              // imageSharp: imageSharp,
              // imageFlat: imageFlat,
              svgSharp: sharpSvg,
              svgFlat: flatSvg,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext ct) {
    List<StaffStore> _playing = staffService.Staff.staffList;
    Size _size = MediaQuery.of(ct).size;
    ScrollController _controller = new ScrollController();
    return Container(
      decoration:
          BoxDecoration(borderRadius: kAllBorderRadius, color: kStaffArea),
      alignment: Alignment.center,
      child: Column(
        children: [
          // HostFeedbackSelect(),
          SizedBox(height: Setting.deviceHeight * 0.04),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                controller: _controller,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _musicNotationPainter(ct, _playing, _size,
                        keySig: KeySig.g),
                    _musicNotationPainter(ct, _playing, _size,
                        keySig: KeySig.f),
                  ],
                ),
              ),
            ),
          ),
          PlayingInfo(),
        ],
      ),
    );
  }
}
