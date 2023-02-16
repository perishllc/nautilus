import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class Misc {
  // Build contact items for the list
  static Widget buildUserItem(BuildContext context, User user, bool ignoreNickname, var onPressed) {
    final String clickable = user.getDisplayName(ignoreNickname: ignoreNickname)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 58,
          width: double.infinity - 5,
          child: TextButton(
            onPressed: () {
              onPressed(user);
            },
            child: Column(
              children: <Widget>[
                Text(clickable, textAlign: TextAlign.center, style: AppStyles.textStyleAddressPrimary(context)),
                Text(
                  "(${Address(user.address).getShortString()})",
                  textAlign: TextAlign.center,
                  style: AppStyles.textStyleAddressPrimary(context).copyWith(fontSize: AppFontSizes.smallest),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          height: 1,
          color: StateContainer.of(context).curTheme.text03,
        ),
      ],
    );
  }

  static Widget walletBalanceButton(BuildContext context, bool localCurrencyMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () async {
            Clipboard.setData(ClipboardData(text: StateContainer.of(context).wallet!.address));
            // setState(() {
            //   // Set copied style
            //   _addressCopied = true;
            // });
            // _addressCopiedTimer?.cancel();
            // _addressCopiedTimer = Timer(const Duration(milliseconds: 800), () {
            //   if (!mounted) return;
            //   setState(() {
            //     _addressCopied = false;
            //   });
            // });
            UIUtil.showSnackbar(Z.of(context).addressCopied, context, durationMs: 1500);
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    AppIcons.content_copy,
                    size: 24,
                    color: StateContainer.of(context).curTheme.primary60,
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 5),
                    Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: StateContainer.of(context).selectedAccount!.name,
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.text60,
                                    fontSize: AppFontSizes.small,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "NunitoSans",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: StateContainer.of(context).wallet?.username ??
                                      Address(StateContainer.of(context).wallet!.address).getShortFirstPart(),
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.text60,
                                    fontSize: AppFontSizes.small,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "NunitoSans",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder<PriceConversion>(
                      future: sl.get<SharedPrefsUtil>().getPriceConversion(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData && snapshot.data != null && snapshot.data != PriceConversion.HIDDEN) {
                          return RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: "(",
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.primary60,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: "NunitoSans",
                                  ),
                                ),
                                if (!localCurrencyMode)
                                  TextSpan(
                                    text: getThemeAwareRawAccuracy(
                                      context,
                                      StateContainer.of(context).wallet!.accountBalance.toString(),
                                    ),
                                    style: TextStyle(
                                      color: StateContainer.of(context).curTheme.primary60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "NunitoSans",
                                    ),
                                  ),
                                if (!localCurrencyMode)
                                  displayCurrencySymbol(
                                    context,
                                    TextStyle(
                                      color: StateContainer.of(context).curTheme.primary60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "NunitoSans",
                                    ),
                                  ),
                                TextSpan(
                                  text: localCurrencyMode
                                      ? StateContainer.of(context).wallet!.getLocalCurrencyBalance(
                                          context, StateContainer.of(context).curCurrency,
                                          locale: StateContainer.of(context).currencyLocale)
                                      : getRawAsThemeAwareFormattedAmount(
                                          context, StateContainer.of(context).wallet!.accountBalance.toString()),
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.primary60,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "NunitoSans",
                                  ),
                                ),
                                TextSpan(
                                  text: ")",
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.primary60,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: "NunitoSans",
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        // return Text(
                        //   "*******",
                        //   style: TextStyle(
                        //     color: StateContainer.of(context).curTheme.text,
                        //     fontSize: 14.0,
                        //     fontWeight: FontWeight.w100,
                        //     fontFamily: "NunitoSans",
                        //   ),
                        // );
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
