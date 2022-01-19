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
    final String _type = Setting.isTablet() ? 'tablet' : 'tablet';
    // final String _type = Setting.isTablet() ? 'tablet' : 'mobile';
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    imagePaths = manifestMap.keys
        .where((String key) =>
            key.contains('assets/images/tutorial/$_type/') &&
            (key.contains('.png') ||
                key.contains('.jpg') ||
                key.contains('.PNG') ||
                key.contains('.JPG')))
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
            space: 8,
            color: Colors.white,
            activeColor: kYellowMain,
          ),
        ),
        outer: true,
        scale: 0.9,
      ),
    );
  }

  ///Set flag when user swipe to change view mode.
  void _swiper(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      print('drag down');
      Navigator.pop(context);
    } else if (details.primaryVelocity! < 0) {
      print('drag up');
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kGreenMain,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: GestureDetector(
            onVerticalDragEnd: _swiper,
            child: Stack(
              children: [
                Exit(color: kYellowMain),
                _loaded
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Setting.deviceWidth * 0.08,
                            vertical: Setting.deviceHeight * 0.01),
                        child: _show(),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
