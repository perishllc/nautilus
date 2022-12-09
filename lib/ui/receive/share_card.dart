import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AppShareCard extends StatefulWidget {
  AppShareCard(this.key, this.qrSVG, this.logoSvg);
  final GlobalKey? key;
  final Widget qrSVG;
  final Widget logoSvg;

  @override
  _AppShareCardState createState() => _AppShareCardState(key, qrSVG, logoSvg);
}

class _AppShareCardState extends State<AppShareCard> {
  _AppShareCardState(this.globalKey, this.qrSVG, this.logoSvg);
  GlobalKey? globalKey;
  Widget qrSVG;
  Widget logoSvg;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Container(
        height: 125,
        width: 235,
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDark,
          borderRadius: BorderRadius.circular(12.5),
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 12.5, right: 12.5, top: 12.5),
          constraints: const BoxConstraints.expand(),
          // The main row that holds QR, logo, the address, ticker and the website text
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // A container for QR
              Container(
                margin: const EdgeInsets.only(bottom: 12.5),
                width: 100,
                height: 100.0,
                child: Stack(
                  children: <Widget>[
                    // Background QR
                    Center(
                      child: SizedBox(
                        width: 91.954,
                        height: 91.954,
                        child: qrSVG,
                      ),
                    ),
                    // Actual QR part of the QR
                    Center(
                      child: Container(
                        color: Colors.white,
                        height: 64.6,
                        width: 64.6,
                        padding: const EdgeInsets.all(2),
                        child: QrImage(
                          padding: EdgeInsets.zero,
                          data: StateContainer.of(context).wallet!.address!,
                          version: 6,
                          gapless: false,
                          errorCorrectionLevel: QrErrorCorrectLevel.Q,
                        ),
                      ),
                    ),
                    // Outer Ring
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: StateContainer.of(context).curTheme.primary!, width: 1.3913),
                        ),
                      ),
                    ),
                    // Logo Background White
                    Center(
                      child: Container(
                        width: 21,
                        height: 21,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: /*StateContainer.of(context).curTheme.primary*/ Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Center(
                    //   child: Container(
                    //     height: 4.9,
                    //     padding: EdgeInsetsDirectional.only(
                    //       end: 8,
                    //     ),
                    //     child: Icon(
                    //       AppIcons.nautilushorizontal,
                    //       size: 4.9,
                    //       color: StateContainer.of(context).curTheme.backgroundDark,
                    //     ),
                    //   ),
                    // ),
                    Center(
                      child: SizedBox(
                        height: 18,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: logoSvg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // A column for logo, address, ticker and website text
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Logo
                  Container(
                    width: 96,
                    height: 20,
                    margin: const EdgeInsetsDirectional.only(start: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Currency Icon
                        SizedBox(
                          width: 29,
                          child: Icon(
                            AppIcons.nanohorizontal,
                            color: StateContainer.of(context).curTheme.primary,
                            size: 13,
                          ),
                        ),
                        Container(
                          width: 60,
                          margin: const EdgeInsets.only(top: 1),
                          child: AutoSizeText(
                            "NANO",
                            style: TextStyle(
                              color: StateContainer.of(context).curTheme.primary,
                              fontFamily: "Comfortaa",
                              fontWeight: FontWeight.w300,
                              fontSize: 40,
                              letterSpacing: 1.5,
                            ),
                            minFontSize: 0.1,
                            stepGranularity: 0.1,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Address
                  Container(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Column(
                      children: <Widget>[
                        // First row of the address
                        SizedBox(
                          width: 97,
                          child: AutoSizeText.rich(
                            TextSpan(
                              children: [
                                // Primary part of the first row
                                TextSpan(
                                  text: StateContainer.of(context).wallet!.address!.substring(0, 12),
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.primary,
                                    fontFamily: "OverpassMono",
                                    fontWeight: FontWeight.w100,
                                    fontSize: 50.0,
                                    height: 1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: StateContainer.of(context).wallet!.address!.substring(12, 16),
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.text,
                                    fontFamily: "OverpassMono",
                                    fontWeight: FontWeight.w100,
                                    fontSize: 50.0,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            stepGranularity: 0.1,
                            minFontSize: 1,
                            style: const TextStyle(
                              fontSize: 50.0,
                              fontFamily: "OverpassMono",
                              fontWeight: FontWeight.w100,
                              height: 1.2,
                            ),
                          ),
                        ),
                        // Second row of the address
                        SizedBox(
                          width: 97,
                          child: AutoSizeText(
                            StateContainer.of(context).wallet!.address!.substring(16, 32),
                            minFontSize: 1.0,
                            stepGranularity: 0.1,
                            maxFontSize: 50,
                            maxLines: 1,
                            style: TextStyle(
                              color: StateContainer.of(context).curTheme.text,
                              fontFamily: "OverpassMono",
                              fontWeight: FontWeight.w100,
                              fontSize: 50,
                              height: 1.2,
                            ),
                          ),
                        ),
                        // Third row of the address
                        SizedBox(
                          width: 97,
                          child: AutoSizeText(
                            StateContainer.of(context).wallet!.address!.substring(32, 48),
                            minFontSize: 1.0,
                            stepGranularity: 0.1,
                            maxFontSize: 50,
                            maxLines: 1,
                            style: TextStyle(
                              color: StateContainer.of(context).curTheme.text,
                              fontFamily: "OverpassMono",
                              fontWeight: FontWeight.w100,
                              fontSize: 50,
                              height: 1.2,
                            ),
                          ),
                        ),
                        // Fourth(last) row of the address
                        SizedBox(
                          width: 97,
                          child: AutoSizeText.rich(
                            TextSpan(
                              children: [
                                // Text colored part of the last row
                                TextSpan(
                                  text: StateContainer.of(context).wallet!.address!.substring(48, 59),
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.text,
                                    fontFamily: "OverpassMono",
                                    fontWeight: FontWeight.w100,
                                    fontSize: 50.0,
                                    height: 1.2,
                                  ),
                                ),
                                // Primary colored part of the last row
                                TextSpan(
                                  text: StateContainer.of(context).wallet!.address!.substring(59),
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.primary,
                                    fontFamily: "OverpassMono",
                                    fontWeight: FontWeight.w100,
                                    fontSize: 50.0,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            stepGranularity: 0.1,
                            minFontSize: 1,
                            style: const TextStyle(
                              fontSize: 50,
                              fontFamily: "OverpassMono",
                              fontWeight: FontWeight.w100,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ticker & Website
                  Container(
                    width: 97,
                    margin: const EdgeInsets.only(bottom: 12.5),
                    child: AutoSizeText(
                      "\$XNO      NANO.ORG",
                      minFontSize: 0.1,
                      stepGranularity: 0.1,
                      maxLines: 1,
                      style: TextStyle(
                        color: StateContainer.of(context).curTheme.primary,
                        fontFamily: "Comfortaa",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
