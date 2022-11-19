import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:coingecko_api/coingecko_api.dart';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/market_chart_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class MarketCard extends StatefulWidget {
  MarketCard({this.child, required this.localCurrency, required this.scaffoldKey, required this.opacityAnimation});

  final Widget? child;
  final GlobalKey<ScaffoldState> scaffoldKey;
  PriceConversion? priceConversion;
  Animation<double> opacityAnimation;
  AvailableCurrency localCurrency;

  @override
  State<StatefulWidget> createState() {
    return MarketCardState();
  }
}

class MarketCardState extends State<MarketCard> with AutomaticKeepAliveClientMixin<MarketCard> {
  late WebViewController webViewController;

  String hashedSeed = "";

  // Price conversion state (XMR, NANO, NONE)
  PriceConversion? _priceConversion;

  // Main card height
  double? mainCardHeight;
  double settingsIconMarginTop = 5;

  List<FlSpot> points = [];

  void _registerBus() {}

  void _destroyBus() {}

  @override
  void initState() {
    super.initState();
    _registerBus();

    // if (widget.priceConversion != null) {
    //   _priceConversion = widget.priceConversion;
    // } else {
    //   _priceConversion = PriceConversion.CURRENCY;
    // }

    // // Main Card Size
    // if (_priceConversion == PriceConversion.CURRENCY) {
    //   mainCardHeight = 80;
    //   settingsIconMarginTop = 15;
    // } else if (_priceConversion == PriceConversion.NONE) {
    //   mainCardHeight = 64;
    //   settingsIconMarginTop = 7;
    // } else if (_priceConversion == PriceConversion.HIDDEN) {
    //   mainCardHeight = 64;
    //   settingsIconMarginTop = 7;
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      CoinGeckoApi api = CoinGeckoApi();
      final CoinGeckoResult<List<MarketChartData>> marketChart = await api.coins.getCoinMarketChart(
        id: "nano",
        vsCurrency: widget.localCurrency.getIso4217Code(),
        days: 7,
      );

      for (MarketChartData chartData in marketChart.data) {
        points.add(FlSpot(chartData.date.millisecondsSinceEpoch.toDouble(), chartData.price!));
      }
    });
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
          // Cyclce to hidden
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
                  if (_priceConversion == PriceConversion.CURRENCY)
                    Text(
                      StateContainer.of(context).wallet!.getLocalCurrencyBalance(
                          context, StateContainer.of(context).curCurrency,
                          locale: StateContainer.of(context).currencyLocale),
                      textAlign: TextAlign.center,
                      style: AppStyles.textStyleCurrencyAlt(context),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
      ),
      margin: EdgeInsets.only(left: 14.0, right: 14.0, top: MediaQuery.of(context).size.height * 0.005),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: AspectRatio(
        aspectRatio: 2,
        child: LineChart(
          LineChartData(

            borderData: FlBorderData(
                border: const Border(bottom: BorderSide(), left: BorderSide())),
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              // leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: points.map((FlSpot point) => FlSpot(point.x, point.y)).toList(),
                isCurved: true,
                color: StateContainer.of(context).curTheme.primary,
                barWidth: 2,
                dotData: FlDotData(
                  show: false,
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                // TODO : Utilize touch event here to perform any operation
              },
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: StateContainer.of(context).curTheme.primary,
                tooltipRoundedRadius: 20.0,
                // showOnTopOfTheChartBoxArea: true,
                fitInsideHorizontally: true,
                tooltipMargin: 0,
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map(
                    (LineBarSpot touchedSpot) {
                      const TextStyle textStyle = TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      );
                      return LineTooltipItem(
                        points[touchedSpot.spotIndex].y.toStringAsFixed(2),
                        textStyle,
                      );
                    },
                  ).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
