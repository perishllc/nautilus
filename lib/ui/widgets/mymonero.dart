
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class MyMonero extends StatefulWidget {
  const MyMonero();
  @override
  State<StatefulWidget> createState() {
    return MyMoneroState();
  }
}

class MyMoneroState extends State<MyMonero> with AutomaticKeepAliveClientMixin<MyMonero> {
  late WebViewController webViewController;
  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      // width: MediaQuery.of(context).size.width / 2,
      height: 500,

      // margin: const EdgeInsets.all(30),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(20.0),
        ),
        // child: WebView(
        //   initialUrl: "https://xmrwallet.com",
        //   javascriptMode: JavascriptMode.unrestricted,
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
        //           Navigator.of(context).pop();
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
        child: InAppWebView(
          // key: webViewKey,
          initialUrlRequest: URLRequest(url: Uri.parse("https://wallet.mymonero.com/")),
          gestureRecognizers: Set()
            ..add(Factory<TapGestureRecognizer>(
              () => TapGestureRecognizer(),
            ))
            ..add(Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
            ))
            ..add(Factory<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
            )),

          // initialOptions: options,
        ),
      ),
    );
  }
}
