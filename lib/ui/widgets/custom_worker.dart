import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    _registerBus();
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _registerBus() {
    _workSub = EventTaxiImpl.singleton()
        .registerTo<WorkEvent>()
        .listen((WorkEvent event) async {
      if (event.type == "generate_work") {
        webViewController?.runJavascript(
            "window.type = '${event.subtype}'; window.hash = '${event.currentHash}';");
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

    const String url = "http://localhost:8080/assets/work/index.html";

    return SizedBox(
      height: 2,
      width: 2,
      child: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
        debuggingEnabled: !kReleaseMode,
        gestureNavigationEnabled: true,
        zoomEnabled: false,
        javascriptChannels: <JavascriptChannel>{
          JavascriptChannel(
              name: "POW",
              onMessageReceived: (JavascriptMessage message) {
                final String messageString = message.message;

                final List<String> msgs = messageString.split(":");
                final String type = msgs[0];
                final String currentHash = msgs[1];
                final String field2 = msgs[2];

                switch (type) {
                  case "progress":
                    EventTaxiImpl.singleton().fire(WorkEvent(
                        type: type, currentHash: currentHash, value: field2));
                    break;
                  case "work":
                    EventTaxiImpl.singleton().fire(WorkEvent(
                        type: type, currentHash: currentHash, value: field2));
                    break;
                }
              }),
          JavascriptChannel(
              name: "CloseWebView",
              onMessageReceived: (JavascriptMessage message) {
                Navigator.of(context).pop();
              })
        },
        onWebViewCreated: (WebViewController w) {
          webViewController = w;
        },
      ),
    );
  }
}
