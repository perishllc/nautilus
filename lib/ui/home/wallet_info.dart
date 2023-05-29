import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/account.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/accounts/accountdetails_sheet.dart';
import 'package:wallet_flutter/ui/accounts/accounts_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class WalletInfo extends StatefulWidget {
  WalletInfo({this.priceConversion, required this.scaffoldKey, required this.opacityAnimation});

  final GlobalKey<ScaffoldState> scaffoldKey;
  PriceConversion? priceConversion;
  Animation<double> opacityAnimation;

  @override
  State<StatefulWidget> createState() {
    return WalletInfoState();
  }
}

class WalletInfoState extends State<WalletInfo> with AutomaticKeepAliveClientMixin<WalletInfo> {
  late WebViewController webViewController;

  String hashedSeed = "";

  // Price conversion state (XMR, NANO, NONE)
  PriceConversion? _priceConversion;

  // Main card height
  double? mainCardHeight;
  double settingsIconMarginTop = 5;

  bool nanoMode = true;

  Timer? _syncTimer;
  bool stillSyncing = false;

  void _registerBus() {}

  void _destroyBus() {}

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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_priceConversion == PriceConversion.CURRENCY)
            Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                const Text(
                  "1234567",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: "NunitoSans",
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.w600,
                    color: Colors.transparent,
                  ),
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
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: "NunitoSans",
                        fontSize: AppFontSizes.small - 3,
                        fontWeight: FontWeight.w600,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Container(
            constraints: BoxConstraints(maxWidth: (UIUtil.getDrawerAwareScreenWidth(context) - 225).abs()),
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                const AutoSizeText(
                  "1234567",
                  style: TextStyle(
                    fontFamily: "NunitoSans",
                    fontSize: AppFontSizes.largestc,
                    fontWeight: FontWeight.w900,
                    color: Colors.transparent,
                  ),
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
                        color: Colors.transparent,
                      ),
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
        // width: (UIUtil.getDrawerAwareScreenWidth(context) - 190).abs(),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Nano logo
            if (_priceConversion == PriceConversion.HIDDEN)
              Container(
                width: 200,
                alignment: AlignmentDirectional.center,
                child: Icon(AppIcons.nanologo, size: 32, color: StateContainer.of(context).curTheme.primary),
              ),
            if (_priceConversion == PriceConversion.CURRENCY)
              Text(
                StateContainer.of(context).wallet!.getLocalCurrencyBalance(
                    context, StateContainer.of(context).curCurrency,
                    locale: StateContainer.of(context).currencyLocale),
                textAlign: TextAlign.center,
                style: AppStyles.textStyleCurrencyAlt(context),
              ),
            if (_priceConversion != PriceConversion.HIDDEN)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(maxWidth: (UIUtil.getDrawerAwareScreenWidth(context) - 205).abs()),
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
      margin: EdgeInsets.only(left: 14, right: 14, top: MediaQuery.of(context).size.height * 0.005),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
      child: Stack(
        children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: mainCardHeight,
                  child: _getBalanceWidget(),
                ),
                // AnimatedContainer(
                //   duration: const Duration(milliseconds: 200),
                //   curve: Curves.easeInOut,
                //   width: 80,
                //   height: mainCardHeight,
                // ),
                OutlinedButton(
                  style: TextButton.styleFrom(
                    foregroundColor: StateContainer.of(context).curTheme.text30, padding: const EdgeInsets.all(4.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                    // highlightColor: StateContainer.of(context).curTheme.text15,
                    // splashColor: StateContainer.of(context).curTheme.text30,
                    // backgroundColor: StateContainer.of(context).curTheme.primary10,
                  ),
                  onPressed: () async {
                    // Sheets.showAppHeightNineSheet(
                    //   context: context,
                    //   widget: AccountDetailsSheet(account: StateContainer.of(context).selectedAccount!),
                    // );
                    final String seed = await StateContainer.of(context).getSeed();
                    final List<Account> accounts = await sl.get<DBHelper>().getAccounts(seed);

                    // ignore: use_build_context_synchronously
                    Sheets.showAppHeightNineSheet(
                      context: context,
                      widget: AppAccountsSheet(accounts: accounts),
                    );
                  },
                  onLongPress: () async {
                    Clipboard.setData(ClipboardData(text: StateContainer.of(context).wallet!.address ?? ""));
                    UIUtil.showSnackbar(Z.of(context).addressCopied, context, durationMs: 1500);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Main account name
                        Text(
                          StateContainer.of(context).selectedAccount!.name!,
                          style: TextStyle(
                            fontFamily: "NunitoSans",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: StateContainer.of(context).curTheme.text,
                          ),
                        ),
                        // Main account address
                        Text(
                          StateContainer.of(context).wallet?.username ??
                              Address(StateContainer.of(context).wallet?.address).getShortFirstPart() ??
                              "",
                          style: TextStyle(
                            fontFamily: "OverpassMono",
                            fontWeight: FontWeight.w100,
                            fontSize: 12,
                            color: StateContainer.of(context).curTheme.text60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
          // AnimatedContainer(
          //   duration: const Duration(milliseconds: 200),
          //   curve: Curves.easeInOut,
          //   height: mainCardHeight,
          //   // height: mainCardHeight == 64 ? 60 : 74,
          //   margin: const EdgeInsets.only(
          //     left: 5,
          //     right: 5,
          //   ),
          //   // padding: EdgeInsets.all(0.0),
          //   padding: const EdgeInsets.only(bottom: 2), // covers the top of the balance text in the currency widget
          //   child: const SizedBox(),
          // ),
        ],
      ),
    );
  }
}
