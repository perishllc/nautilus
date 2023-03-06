import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/xmr_event.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class TopCard extends StatefulWidget {
  TopCard({this.child, this.priceConversion, required this.scaffoldKey, required this.opacityAnimation});

  final Widget? child;
  final GlobalKey<ScaffoldState> scaffoldKey;
  PriceConversion? priceConversion;
  Animation<double> opacityAnimation;

  @override
  State<StatefulWidget> createState() {
    return TopCardState();
  }
}

class TopCardState extends State<TopCard> with AutomaticKeepAliveClientMixin<TopCard> {
  late WebViewController webViewController;

  String hashedSeed = "";

  // Price conversion state (XMR, NANO, NONE)
  PriceConversion? _priceConversion;

  // Main card height
  double? mainCardHeight;
  double settingsIconMarginTop = 5;

  bool nanoMode = true;

  StreamSubscription<XMREvent>? _xmrEventSub;

  String xmrBalance = "0";
  double syncPercentage = 0;
  String xmrStatus = "";
  String xmrState = "";
  Color? xmrStatusColor;
  Timer? _syncTimer;
  bool stillSyncing = false;

  void areWeStillSyncing() {
    if (!mounted) return;
    if (stillSyncing != (xmrState == "syncing")) {
      setState(() {
        stillSyncing = xmrState == "syncing";
      });
    }
  }

  void _registerBus() {
    _xmrEventSub = EventTaxiImpl.singleton().registerTo<XMREvent>().listen((XMREvent event) {
      if (event.type == "mode_change") {
        if (event.message == "nano") {
          setState(() {
            nanoMode = true;
          });
        } else {
          setState(() {
            nanoMode = false;
          });
        }
      }
      if (event.type == "update_balance") {
        setState(() {
          // var bal = Decimal.parse(event.message) / Decimal.parse("1000000000000");
          xmrBalance = getXMRRawAsThemeAwareAmount(context, event.message);
        });
      }
      if (event.type == "update_progress") {
        setState(() {
          syncPercentage = double.parse(event.message);
        });
      }
      if (event.type == "update_status") {
        String title = "";
        Color? color = Colors.transparent;
        xmrState = event.message;
        switch (event.message) {
          case "error":
            title = CaseChange.toUpperCase(Z.of(context).xmrStatusError, context);
            color = StateContainer.of(context).curTheme.error;
            break;

          case "loading":
            title = CaseChange.toUpperCase(Z.of(context).xmrStatusLoading, context);
            color = StateContainer.of(context).curTheme.warning;
            stillSyncing = false;
            break;

          case "connecting":
            title = CaseChange.toUpperCase(Z.of(context).xmrStatusConnecting, context);
            color = StateContainer.of(context).curTheme.warning;
            break;

          case "syncing":
            title = CaseChange.toUpperCase(Z.of(context).xmrStatusSynchronizing, context);
            color = StateContainer.of(context).curTheme.warning;
            if (syncPercentage > 0) {
              title += ' ${(syncPercentage * 100).toStringAsPrecision(3)}%';
            } else {
              title += '...';
            }
            _syncTimer = Timer(const Duration(milliseconds: 3500), areWeStillSyncing);
            break;
          case "ready":
            title = CaseChange.toUpperCase(Z.of(context).xmrStatusSynchronized, context);
            color = StateContainer.of(context).curTheme.success;
            stillSyncing = false;
            break;
        }
        setState(() {
          xmrStatus = title;
          xmrStatusColor = color;
        });
      }
    });
  }

  void _destroyBus() {
    if (_xmrEventSub != null) {
      _xmrEventSub!.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBus();

    if (widget.priceConversion != null) {
      _priceConversion = widget.priceConversion;
    } else {
      _priceConversion = PriceConversion.CURRENCY;
    }

    // Main Card Size
    if (_priceConversion == PriceConversion.CURRENCY) {
      mainCardHeight = 80;
      settingsIconMarginTop = 15;
    } else if (_priceConversion == PriceConversion.NONE) {
      mainCardHeight = 64;
      settingsIconMarginTop = 7;
    } else if (_priceConversion == PriceConversion.HIDDEN) {
      mainCardHeight = 64;
      settingsIconMarginTop = 7;
    }
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  // Get balance display
  Widget _getBalanceWidget() {
    if (StateContainer.of(context).wallet?.loading ?? true) {
      // Placeholder for balance text
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_priceConversion == PriceConversion.CURRENCY)
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                const Text(
                  "1234567",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "NunitoSans",
                      fontSize: AppFontSizes.small,
                      fontWeight: FontWeight.w600,
                      color: Colors.transparent),
                ),
                Opacity(
                  opacity: widget.opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.text20,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      "1234567",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "NunitoSans",
                          fontSize: AppFontSizes.small - 3,
                          fontWeight: FontWeight.w600,
                          color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
          Container(
            constraints: BoxConstraints(maxWidth: (UIUtil.getDrawerAwareScreenWidth(context) - 225).abs()),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                const AutoSizeText(
                  "1234567",
                  style: TextStyle(
                      fontFamily: "NunitoSans",
                      fontSize: AppFontSizes.largestc,
                      fontWeight: FontWeight.w900,
                      color: Colors.transparent),
                  maxLines: 1,
                  stepGranularity: 0.1,
                  minFontSize: 1,
                ),
                Opacity(
                  opacity: widget.opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.primary60,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const AutoSizeText(
                      "1234567",
                      style: TextStyle(
                          fontFamily: "NunitoSans",
                          fontSize: AppFontSizes.largestc - 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.transparent),
                      maxLines: 1,
                      stepGranularity: 0.1,
                      minFontSize: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    // Balance texts
    return GestureDetector(
      onTap: () {
        if (_priceConversion == PriceConversion.CURRENCY) {
          // Hide prices
          setState(() {
            _priceConversion = PriceConversion.NONE;
            mainCardHeight = 64;
            settingsIconMarginTop = 7;
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.NONE);
        } else if (_priceConversion == PriceConversion.NONE) {
          // Cycle to hidden
          setState(() {
            _priceConversion = PriceConversion.HIDDEN;
            mainCardHeight = 64;
            settingsIconMarginTop = 7;
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.HIDDEN);
        } else if (_priceConversion == PriceConversion.HIDDEN) {
          // Cycle to CURRENCY price
          setState(() {
            mainCardHeight = 80;
            settingsIconMarginTop = 15;
          });
          Future<dynamic>.delayed(const Duration(milliseconds: 150), () {
            setState(() {
              _priceConversion = PriceConversion.CURRENCY;
            });
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.CURRENCY);
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: (UIUtil.getDrawerAwareScreenWidth(context) - 190).abs(),
        color: Colors.transparent,
        child: _priceConversion == PriceConversion.HIDDEN
            ?
            // Nano logo
            Center(child: Icon(AppIcons.nanologo, size: 32, color: StateContainer.of(context).curTheme.primary))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (nanoMode)
                    if (_priceConversion == PriceConversion.CURRENCY)
                      Text(
                        StateContainer.of(context).wallet!.getLocalCurrencyBalance(
                            context, StateContainer.of(context).curCurrency,
                            locale: StateContainer.of(context).currencyLocale),
                        textAlign: TextAlign.center,
                        style: AppStyles.textStyleCurrencyAlt(context),
                      ),
                  if (!nanoMode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // SizedBox.square(
                        //   dimension: 10.0,
                        //   child: Container(color: xmrStatusColor),
                        // ),
                        if (xmrStatus.isNotEmpty)
                          if (!<String>["ready", "error"].contains(xmrState))
                            DefaultTextStyle(
                              textAlign: TextAlign.center,
                              style: AppStyles.textStyleCurrencyAlt(context).copyWith(
                                color: xmrStatusColor,
                              ),
                              child: AnimatedTextKit(
                                animatedTexts: <AnimatedText>[
                                  WavyAnimatedText(xmrStatus, speed: const Duration(milliseconds: 100)),
                                ],
                                repeatForever: true,
                                isRepeatingAnimation: true,
                              ),
                            )
                          else
                            Text(
                              xmrStatus,
                              textAlign: TextAlign.center,
                              style: AppStyles.textStyleCurrencyAlt(context).copyWith(
                                color: xmrStatusColor,
                              ),
                            )
                        else
                          DefaultTextStyle(
                            textAlign: TextAlign.center,
                            style: AppStyles.textStyleCurrencyAlt(context).copyWith(
                              color: StateContainer.of(context).curTheme.primary,
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: <AnimatedText>[
                                WavyAnimatedText(
                                    CaseChange.toUpperCase(
                                      Z.of(context).xmrStatusConnecting,
                                      context,
                                    ),
                                    speed: const Duration(milliseconds: 100)),
                              ],
                              repeatForever: true,
                              isRepeatingAnimation: true,
                            ),
                          ),
                      ],
                    ),
                  if (!nanoMode && stillSyncing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          Z.of(context).thisMayTakeSomeTime,
                          textAlign: TextAlign.center,
                          style: AppStyles.textStyleCurrencyAlt(context).copyWith(
                            color: xmrStatusColor,
                            fontSize: AppFontSizes.smallest,
                          ),
                        )
                      ],
                    ),
                  if (nanoMode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          constraints:
                              BoxConstraints(maxWidth: (UIUtil.getDrawerAwareScreenWidth(context) - 205).abs()),
                          child: AutoSizeText.rich(
                            TextSpan(
                              children: [
                                if (_priceConversion == PriceConversion.CURRENCY)
                                  displayCurrencySymbol(context, AppStyles.textStyleCurrency(context))
                                else
                                  displayCurrencySymbol(context, AppStyles.textStyleCurrencySmaller(context)),
                                // Main balance text
                                TextSpan(
                                  text: getRawAsThemeAwareFormattedAmount(
                                      context, StateContainer.of(context).wallet?.accountBalance.toString()),
                                  style: _priceConversion == PriceConversion.CURRENCY
                                      ? AppStyles.textStyleCurrency(context)
                                      : AppStyles.textStyleCurrencySmaller(
                                          context,
                                        ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            style: TextStyle(fontSize: _priceConversion == PriceConversion.CURRENCY ? 28 : 22),
                            stepGranularity: 0.1,
                            minFontSize: 1,
                            maxFontSize: _priceConversion == PriceConversion.CURRENCY ? 28 : 22,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          constraints:
                              BoxConstraints(maxWidth: (UIUtil.getDrawerAwareScreenWidth(context) - 205).abs()),
                          child: AutoSizeText.rich(
                            TextSpan(
                              children: <InlineSpan>[
                                // Main balance text
                                TextSpan(
                                  text: xmrBalance,
                                  style: _priceConversion == PriceConversion.CURRENCY
                                      ? AppStyles.textStyleCurrency(context)
                                      : AppStyles.textStyleCurrencySmaller(
                                          context,
                                        ),
                                ),
                                TextSpan(
                                  text: " XMR",
                                  style: _priceConversion == PriceConversion.CURRENCY
                                      ? AppStyles.textStyleCurrency(context)
                                      : AppStyles.textStyleCurrencySmaller(context),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            style: TextStyle(fontSize: _priceConversion == PriceConversion.CURRENCY ? 28 : 22),
                            stepGranularity: 0.1,
                            minFontSize: 1,
                            maxFontSize: _priceConversion == PriceConversion.CURRENCY ? 28 : 22,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 0),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
      ),
      margin: EdgeInsets.only(left: 14.0, right: 14.0, top: MediaQuery.of(context).size.height * 0.005),
      child: Stack(
        children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // AnimatedContainer(
                //   duration: const Duration(milliseconds: 200),
                //   curve: Curves.easeInOut,
                //   width: 80.0,
                //   height: mainCardHeight,
                //   alignment: AlignmentDirectional.topStart,
                //   child: AnimatedContainer(
                //     duration: const Duration(milliseconds: 200),
                //     curve: Curves.easeInOut,
                //     margin: EdgeInsetsDirectional.only(top: settingsIconMarginTop, start: 5),
                //     height: 50,
                //     width: 50,
                //     child: TextButton(
                //       key: const Key("home_settings_button"),
                //       style: TextButton.styleFrom(
                //         foregroundColor: StateContainer.of(context).curTheme.text15,
                //         backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                //         // highlightColor: StateContainer.of(context).curTheme.text15,
                //         // splashColor: StateContainer.of(context).curTheme.text15,
                //       ),
                //       onPressed: () {
                //         widget.scaffoldKey.currentState?.openDrawer();
                //       },
                //       child: Stack(
                //         children: [
                //           Icon(
                //             AppIcons.settings,
                //             color: StateContainer.of(context).curTheme.text,
                //             size: 24,
                //           ),
                //           if (!StateContainer.of(context).activeAlertIsRead)
                //             Positioned(
                //               top: -3,
                //               right: -3,
                //               child: Container(
                //                 padding: const EdgeInsets.all(3),
                //                 decoration: BoxDecoration(
                //                   color: StateContainer.of(context).curTheme.backgroundDark,
                //                   shape: BoxShape.circle,
                //                 ),
                //                 child: Container(
                //                   decoration: BoxDecoration(
                //                     color: StateContainer.of(context).curTheme.success,
                //                     shape: BoxShape.circle,
                //                   ),
                //                   height: 11,
                //                   width: 11,
                //                 ),
                //               ),
                //             )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // AnimatedContainer(
                //   duration: const Duration(milliseconds: 200),
                //   curve: Curves.easeInOut,
                //   width: 80,
                //   height: mainCardHeight,
                //   alignment: AlignmentDirectional.center,
                //   child: TextButton(
                //     key: const Key("home_chart_button"),
                //     style: TextButton.styleFrom(
                //       foregroundColor: StateContainer.of(context).curTheme.text15,
                //       backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                //       // highlightColor: StateContainer.of(context).curTheme.text15,
                //       // splashColor: StateContainer.of(context).curTheme.text15,
                //     ),
                //     onPressed: () {
                //       // widget.scaffoldKey.currentState?.openDrawer();
                //       StateContainer.of(context).toggleChart();
                //     },
                //     child: Icon(
                //       Icons.trending_up,
                //       color: StateContainer.of(context).curTheme.text,
                //       size: 24,
                //     ),
                //   ),
                // ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 80,
                  height: mainCardHeight,
                  child: const SizedBox(),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: mainCardHeight,
                  child: _getBalanceWidget(),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 80,
                  height: mainCardHeight,
                ),
              ]),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: mainCardHeight,
            // height: mainCardHeight == 64 ? 60 : 74,
            margin: const EdgeInsets.only(
              left: 5,
              right: 5,
            ),
            // padding: EdgeInsets.all(0.0),
            padding: const EdgeInsets.only(bottom: 2), // covers the top of the balance text in the currency widget
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
