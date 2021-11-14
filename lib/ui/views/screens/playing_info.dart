import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';

class PlayingInfo extends StatelessWidget {
  const PlayingInfo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: EdgeInsets.all(0),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.baseline,
          //     textBaseline: TextBaseline.alphabetic,
          //     children: [
          //       SizedBox(
          //         width: 70,
          //         child: Align(
          //           alignment: Alignment.centerRight,
          //           child: Text('Key: ',
          //               style: TextStyle(
          //                   fontSize: 18,
          //                   fontWeight: FontWeight.w500,
          //                   color: Colors.black)),
          //         ),
          //       ),
          //       Text('C Major',
          //           style: TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.w500,
          //               color: kRed1)),
          //     ],
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 70,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Note(s): ',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black)),
                  ),
                ),
                Flexible(
                  child: Text(
                      context.watch<Classroom>().piano.pressingKeys(
                          context.watch<Classroom>().piano.pressingKeyList),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: kRed1)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: kAllBorderRadius,
                  border: Border.all(
                    color: kRed1,
                    width: 1,
                  )
                  // color: Color(0xFFF9BD24),
                  ),
              child:
                  // Text(Piano.pressingChord,
                  Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                    context.watch<Classroom>().piano.pressingChord == ''
                        ? '-'
                        : context.watch<Classroom>().piano.pressingChord,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        color: kRed1)),
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(0),
          //   child: Row(
          //     // crossAxisAlignment: CrossAxisAlignment.baseline,
          //     // textBaseline: TextBaseline.alphabetic,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       SizedBox(
          //         width: 70,
          //         child: Padding(
          //           padding: const EdgeInsets.only(top: 15),
          //           child: Align(
          //             alignment: Alignment.centerRight,
          //             child: Text('Chord: ',
          //                 style: TextStyle(
          //                     fontSize: 18,
          //                     fontWeight: FontWeight.w500,
          //                     color: Colors.black)),
          //           ),
          //         ),
          //       ),
          //       Container(
          //         child: Text(Piano.pressingChord,
          //             overflow: TextOverflow.ellipsis,
          //             style: TextStyle(
          //                 fontSize: 55,
          //                 fontWeight: FontWeight.w500,
          //                 color: kRed)),
          //       ),
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.all(0),
          //   child: Row(
          //     children: [
          //       Text('Chord: ',
          //           style: TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.w500,
          //               color: Colors.black)),
          //       Text('C',
          //           style: TextStyle(
          //               fontSize: 60,
          //               fontWeight: FontWeight.w500,
          //               color: kRed)),
          //       // Text(Piano.pressingChord,
          //       //     style: TextStyle(
          //       //         fontSize: 30,
          //       //         fontWeight: FontWeight.w900,
          //       //         color: kRed)),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
