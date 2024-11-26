import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:nanopowrs/nanopowrs.dart';
import 'package:wallet_flutter/bus/work_event.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class CustomWorker extends StatefulWidget {
  const CustomWorker();
  @override
  State<StatefulWidget> createState() {
    return CustomWorkerState();
  }
}

class CustomWorkerState extends State<CustomWorker>
    with AutomaticKeepAliveClientMixin<CustomWorker> {
  WebViewController? webViewController;

  StreamSubscription<WorkEvent>? _workSub;

  @override
  void initState() {
    super.initState();
    RustLib.init().then((_) {
      _registerBus();
    });
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _registerBus() {
    _workSub = EventTaxiImpl.singleton().registerTo<WorkEvent>().listen((WorkEvent event) async {
      // if (event.type == "generate_work") {
      //   webViewController?.runJavascript(
      //       "window.type = '${event.subtype}'; window.hash = '${event.currentHash}';");
      // }

      const String THRESHOLD__SEND_CHANGE = "fffffff800000000"; // avg > 25secs on my PC
      const String THRESHOLD__OPEN_RECEIVE = "fffffe0000000000"; // avg < 2.5secs on my PC

      print("WORK EVENT: ${event.type}");
      if (event.type == "generate_work") {
        print("WORK HASH: ${event.currentHash}");
        String hash = event.currentHash;
        String threshold = THRESHOLD__OPEN_RECEIVE;
                
        // String work = await compute(getPowWrapper, hash);
        String work = await getPow(hashStr: hash);
        print("WORK RESULT: $work");
        EventTaxiImpl.singleton().fire(WorkEvent(type: "work", currentHash: hash, value: work));
      }
    });
  }

  void _destroyBus() {
    if (_workSub != null) {
      _workSub!.cancel();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox();
  }
}
