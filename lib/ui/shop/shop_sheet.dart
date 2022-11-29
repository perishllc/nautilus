import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

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
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDark,
          borderRadius: BorderRadius.all(Radius.circular(15)),

        ),
        child: Column(
          children: [
            // products title section:
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Use Nano",
                    style: AppStyles.textStyleButtonPrimaryOutline(context),
                    // style: TextStyle(
                    //   color: StateContainer.of(context).curTheme.primary,
                    //   fontSize: AppFontSizes.largest(context),
                    //   fontWeight: FontWeight.w700,
                    //   fontFamily: "NunitoSans",
                    //   decoration: TextDecoration.none,
                    // ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(),
                  Text("test"),
                  UseCard(
                    image: "assets/logos/redeemforme.png",
                    title: NonTranslatable.redeemforme,
                    onPress: () {},
                  ),
                  UseCard(
                    image: "assets/logos/nanocafe.png",
                    title: NonTranslatable.nanocafe,
                    onPress: () {},
                  ),
                  UseCard(
                    image: "assets/logos/nanswap.png",
                    title: NonTranslatable.nanswap,
                    onPress: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
