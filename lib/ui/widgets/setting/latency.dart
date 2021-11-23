import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as image;
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/images.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/texts.dart';

class LatencySelect extends StatefulWidget {
  @override
  _LatencySelectState createState() => new _LatencySelectState();
}

class _LatencySelectState extends State<LatencySelect> {
  DrawableRoot? svgRoot;
  final String rawSvg = kSliderThumbIcon;
  bool _svgLoaded = false;

  @override
  void initState() {
    loadSVG();
    super.initState();
  }

  Future loadSVG() async {
    svgRoot = await svg.fromSvgString(rawSvg, rawSvg);
    setState(() {
      _svgLoaded = true;
    });
  }

  final EdgeInsets _latencyTextPadding =
      EdgeInsets.symmetric(horizontal: Setting.deviceWidth * 0.03);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: _latencyTextPadding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(kSettingLatency,
                style: dialogSubHeader(color: kTextColorRed)),
          ),
        ),
        SizedBox(height: Setting.deviceHeight * 0.01),
        SliderTheme(
          data: SliderThemeData(
            activeTickMarkColor: kOrangeMain,
            inactiveTickMarkColor: kOrangeMain,
            // tickMarkShape: ,
            // activeTrackColor: _activeTrackColor(),
            // inactiveTrackColor: _inactiveTrackColor(),
            activeTrackColor: kYellow2,
            inactiveTrackColor: kYellow2,
            thumbColor: kOrangeMain,
            trackHeight: 15,
            // trackShape: RectangularSliderTrackShape(),
            trackShape: RoundedRectSliderTrackShape(),
            // thumbShape: SliderThumbImage(thumbImage),
            thumbShape: _svgLoaded ? SliderThumbImage(svgRoot) : null,
          ),
          child: Slider(
            value: Setting.noteDelayScale,
            min: 0,
            max: 100,
            divisions: 5,
            onChanged: (double value) => setState(() {
              Setting.changeDelay(value);
              context.read<Classroom>().devicesIncrement();
              print(Setting.noteDelayScale);
            }),
          ),
        ),
        Padding(
          padding: _latencyTextPadding,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(kSettingLatencyLow1,
                      style: dialogDetail(color: kTextColorDark)),
                  Text(kSettingLatencyHigh1,
                      style: dialogDetail(color: kRed1),
                      textAlign: TextAlign.end)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(kSettingLatencyLow2, style: dialogDetail(color: kRed1)),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(kSettingLatencyHigh2,
                            style: dialogDetail(color: kTextColorDark),
                            textAlign: TextAlign.end),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SliderThumbImage extends SliderComponentShape {
  // final ui.Image? image;
  final DrawableRoot? image;

  SliderThumbImage(this.image);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(0, 0);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required Size sizeWithOverflow,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double textScaleFactor,
      required double value}) {
    final canvas = context.canvas;
    Size desiredSize = Size(60, 60);
    canvas.save();
// [center] below is the Offset of the center of the area where I want the Svg to be drawn
    canvas.translate(center.dx - desiredSize.width / 2,
        center.dy - desiredSize.height / 2.3);

    Size svgSize = image!.viewport.size;
    var matrix = Matrix4.identity();
    matrix.scale(
        desiredSize.width / svgSize.width, desiredSize.height / svgSize.height);
    canvas.transform(matrix.storage);
    image!.draw(canvas, Rect.zero);
    canvas.restore();
  }
}
