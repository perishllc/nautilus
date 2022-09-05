import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/xmr_event.dart';
import 'package:nautilus_wallet_flutter/util/blake2b.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class CustomMonero extends StatefulWidget {
  const CustomMonero();
  @override
  State<StatefulWidget> createState() {
    return CustomMoneroState();
  }
}

// final webViewKey = GlobalKey<CustomMoneroState>();

class CustomMoneroState extends State<CustomMonero> with AutomaticKeepAliveClientMixin<CustomMonero> {
  WebViewController? webViewController;

  StreamSubscription<XMREvent>? _xmrSub;

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
    // xmr:
    _xmrSub = EventTaxiImpl.singleton().registerTo<XMREvent>().listen((XMREvent event) {
      if (event.type == "xmr_reload") {
        webViewController?.reload();
      }
      if (event.type == "xmr_send" || event.type == "xmr_get_fee") {
        // webViewController?.reload();
        List<String> msgs = event.message.split(":");
        final String address = msgs[0];
        final String amount = msgs[1];
        webViewController?.runJavascript("window.action = '${event.type}'; window.address = '$address'; window.amount = '$amount';");
      }
    });
  }

  void _destroyBus() {
    if (_xmrSub != null) {
      _xmrSub!.cancel();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      height: 0,

      // margin: const EdgeInsets.all(30),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(20.0),
        ),
        child: FutureBuilder<String>(
          future: StateContainer.of(context).getSeed(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final String hashedSeed = NanoHelpers.byteToHex(blake2b(NanoHelpers.hexToBytes(snapshot.data as String))).substring(0, 64);
              String url = "http://localhost:8080/assets/xmr/index.html#s=$hashedSeed&h=${StateContainer.of(context).xmrRestoreHeight}";

              if (kDebugMode) {
                url = "http://142.93.244.88:8080/#s=$hashedSeed&h=${StateContainer.of(context).xmrRestoreHeight}";
              }
              return WebView(
                // TODO: store block height:
                initialUrl: url,
                javascriptMode: JavascriptMode.unrestricted,
                debuggingEnabled: !kReleaseMode,
                gestureNavigationEnabled: true,
                zoomEnabled: false,
                javascriptChannels: {
                  JavascriptChannel(
                      name: "XMR",
                      onMessageReceived: (JavascriptMessage message) {
                        // message contains the 'h-captcha-response' token.
                        // Send it to your server in the login or other
                        // data for verification via /siteverify
                        // see: https://docs.hcaptcha.com/#server
                        // widget.callback(message.message);
                        // Navigator.of(context).pop();

                        final String messageString = message.message;
                        final String type = messageString.substring(0, messageString.indexOf(":"));
                        final String eventMessage = messageString.substring(messageString.indexOf(":") + 1);
                        print("type: $type - eventMessage: $eventMessage");

                        EventTaxiImpl.singleton().fire(XMREvent(type: type, message: eventMessage));
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
              );
            }
            return const SizedBox();
          },
        ),
        // WebView(
        //   // initialUrl: "http://142.93.244.88:8080/#s=$hashedSeed",
        //   initialUrl: "http://142.93.244.88:8080/#s=${hashedSeed}",
        //   javascriptMode: JavascriptMode.unrestricted,
        //   debuggingEnabled: true,
        //   gestureNavigationEnabled: true,
        //   zoomEnabled: false,
        //   javascriptChannels: {
        //     JavascriptChannel(
        //         name: "XMR",
        //         onMessageReceived: (JavascriptMessage message) {
        //           // message contains the 'h-captcha-response' token.
        //           // Send it to your server in the login or other
        //           // data for verification via /siteverify
        //           // see: https://docs.hcaptcha.com/#server
        //           // widget.callback(message.message);
        //           // Navigator.of(context).pop();

        //           final String messageString = message.message;
        //           final String type = messageString.substring(0, messageString.indexOf(":"));
        //           final String eventMessage = messageString.substring(messageString.indexOf(":") + 1);

        //           print("@@@@@@@@@@@@@@@@@@@@@");
        //           print("type: $type - eventMessage: $eventMessage");

        //           EventTaxiImpl.singleton().fire(XMREvent(type: type, message: eventMessage));
        //         }),
        //     JavascriptChannel(
        //         name: "CloseWebView",
        //         onMessageReceived: (JavascriptMessage message) {
        //           Navigator.of(context).pop();
        //         })
        //   },
        //   // onWebViewCreated: (WebViewController w) {
        //   //   webViewController = w;
        //   // },
        // ),
        // child: InAppWebView(
        //   // key: webViewKey,
        //   initialUrlRequest: URLRequest(url: Uri.parse("http://perish.co:3000/xmr")),
        //   gestureRecognizers: Set()
        //     ..add(Factory<TapGestureRecognizer>(
        //       () => TapGestureRecognizer(),
        //     ))
        //     ..add(Factory<VerticalDragGestureRecognizer>(
        //       () => VerticalDragGestureRecognizer(),
        //     ))
        //     ..add(Factory<HorizontalDragGestureRecognizer>(
        //       () => HorizontalDragGestureRecognizer(),
        //     )),

        //   // initialOptions: options,
        // ),
      ),
    );
  }
}
