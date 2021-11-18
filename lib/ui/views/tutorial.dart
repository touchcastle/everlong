import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/actions/exit.dart';
import 'package:everlong/utils/colors.dart';

class Tutorial extends StatefulWidget {
  @override
  _TutorialState createState() => new _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  bool _loaded = false;
  var imagePaths;

  Future _initImages() async {
    final String _type = Setting.isTablet() ? 'tablet' : 'mobile';
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    imagePaths = manifestMap.keys
        .where((String key) => key.contains('assets/images/tutorial/$_type/'))
        // .where((String key) => key.contains('.png'))
        .toList();
    setState(() => _loaded = true);
  }

  @override
  void initState() {
    _initImages();
    super.initState();
  }

  Widget _show() {
    return Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Image(image: AssetImage(imagePaths[index]));
        },
        itemCount: imagePaths.length,
        pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(

                ///TODO: Finalize color
                color: Colors.black26,
                activeColor: Color(0XFFE57373))),
        outer: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kGreenMain,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Exit(),
                Expanded(
                  child: _loaded ? _show() : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
