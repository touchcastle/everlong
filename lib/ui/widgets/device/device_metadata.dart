import 'package:flutter/material.dart';
import 'package:everlong/utils/styles.dart';

class DeviceMetadata extends StatelessWidget {
  DeviceMetadata({required this.id, required this.name});
  final String id;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(this.name, style: kDeviceInfoName),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(this.id, style: kDeviceInfoId),
          ),
        ],
      ),
    );
  }
}
