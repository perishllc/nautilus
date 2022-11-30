import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/localize.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/receive/share_card.dart';
import 'package:nautilus_wallet_flutter/ui/shop/use_card.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/strings.dart';
import 'package:share_plus/share_plus.dart';

class ShopSheet extends StatefulWidget {
  const ShopSheet({required this.localCurrency}) : super();

  final AvailableCurrency localCurrency;

  @override
  ShopSheetState createState() => ShopSheetState();
}

class ShopSheetState extends State<ShopSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15, bottom: 55),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDark,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // products title section:
              Container(
                margin: const EdgeInsets.only(top: 15, bottom: 20),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                child: Column(
                  children: <Widget>[
                    AutoSizeText(
                      AppLocalization.of(context).useNano,
                      style: AppStyles.textStyleHeader(context),
                      maxLines: 1,
                      stepGranularity: 0.1,
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  Text(
                    AppLocalization.of(context).getNano,
                    style: AppStyles.textStyleHeader2Colored(context),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UseCard(
                    image: "assets/logos/onramper.png",
                    title: NonTranslatable.onramper,
                    onPress: () {},
                  ),
                  UseCard(
                    image: "assets/logos/nanocafe.png",
                    title: NonTranslatable.nanocafe,
                    onPress: () async {},
                  ),
                ],
              ),
              Row(children: [
                Text(
                  AppLocalization.of(context).spendNano,
                  style: AppStyles.textStyleHeader2Colored(context),
                ),
              ]),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UseCard(
                    image: "assets/logos/redeemforme.png",
                    title: NonTranslatable.redeemforme,
                    onPress: () async {
                      const String url = "https://redeemfor.me";
                      await UIUtil.showChromeSafariWebview(context, url);
                    },
                  ),
                ],
              ),

              Row(
                children: [
                  Text(
                    AppLocalization.of(context).exchangeNano,
                    style: AppStyles.textStyleHeader2Colored(context),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UseCard(
                    image: "assets/logos/luckynano.png",
                    title: NonTranslatable.luckynano,
                    onPress: () async {},
                  ),
                  UseCard(
                    // image: "assets/logos/playnano.png",
                    image: "assets/logos/luckynano.png",
                    title: NonTranslatable.playnano,
                    onPress: () async {},
                  ),
                ],
              ),

              Row(
                children: [
                  Text(
                    AppLocalization.of(context).exchangeNano,
                    style: AppStyles.textStyleHeader2Colored(context),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UseCard(
                    image: "assets/logos/nanswap.png",
                    title: NonTranslatable.nanswap,
                    onPress: () async {},
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
