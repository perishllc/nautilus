import 'package:flutter/material.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class HCaptcha extends StatefulWidget {
  HCaptcha(this.callback);
  Function callback;
  @override
  State<StatefulWidget> createState() {
    return HCaptchaState();
  }
}

class HCaptchaState extends State<HCaptcha> {
  late WebViewController webViewController;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        // width: MediaQuery.of(context).size.width / 2,
        height: 500,
        
        // margin: const EdgeInsets.all(30),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(20.0),
          ),
          child: WebView(
            initialUrl: NonTranslatable.hcaptchaUrl,
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: true,
            zoomEnabled: false,
            javascriptChannels: {
              JavascriptChannel(
                  name: "Captcha",
                  onMessageReceived: (JavascriptMessage message) {
                    // message contains the 'h-captcha-response' token.
                    // Send it to your server in the login or other
                    // data for verification via /siteverify
                    // see: https://docs.hcaptcha.com/#server
                    widget.callback(message.message);
                    Navigator.of(context).pop();
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
        ),
      ),
    );
  }
}
