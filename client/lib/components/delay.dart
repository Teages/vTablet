import 'package:flutter/material.dart';
import 'package:vtablet/services/connect.dart';

class DelayDialog extends Container {
  DelayDialog({
    Key? key,
    Function()? onClick,
  }) : super(
            key: key,
            child: ValueListenableBuilder(
              valueListenable: VTabletWS.delay,
              builder: (context, value, child) => ElevatedButton(
                onPressed: onClick ?? () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: getSignalColor(VTabletWS.delay.value),
                  foregroundColor: Colors.black,
                ),
                child: Text("${VTabletWS.delay.value} ms"),
              ),
            ));
  static Color getSignalColor(delay) {
    if (delay > 40 || delay < 0) {
      return const Color.fromARGB(255, 249, 142, 142);
    }
    if (delay > 15) {
      return Colors.yellowAccent;
    }
    return Colors.greenAccent;
  }
}
