import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as image;
import 'package:flutter/services.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/images.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/constants.dart';

class LatencySelect extends StatefulWidget {
  @override
  _LatencySelectState createState() => new _LatencySelectState();
}

class _LatencySelectState extends State<LatencySelect> {
  ui.Image? thumbImage;

  @override
  void initState() {
    loadImage(kSliderImage);
    super.initState();
  }

  Future loadImage(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);
    setState(() => this.thumbImage = image);
  }

  Future getUiImage(String imageAssetPath, int height, int width) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    image.Image? baseSizeImage =
        image.decodeImage(assetImageByteData.buffer.asUint8List());
    image.Image resizeImage =
        image.copyResize(baseSizeImage!, height: height, width: width);
    ui.Codec codec = await ui.instantiateImageCodec(
        Uint8List.fromList(image.encodePng(resizeImage)));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() => this.thumbImage = frameInfo.image);
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
            thumbShape: SliderThumbImage(thumbImage),
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
                  Text(kSettingLatencyHigh2,
                      style: dialogDetail(color: kTextColorDark),
                      textAlign: TextAlign.end)
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
  final ui.Image? image;

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
    final imageWidth = image!.width;
    final imageHeight = image!.height;

    Offset imageOffset = Offset(
      center.dx - (imageWidth / 2),
      center.dy - (imageHeight / 2),
    );

    Paint paint = Paint()..filterQuality = FilterQuality.high;

    canvas.drawImage(image!, imageOffset, paint);
  }
}
