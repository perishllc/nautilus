import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/account.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/accounts/accounts_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class Misc {
  static bool _loadingAccounts = false;

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
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                // width: 36,
                // height: 36,
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: StateContainer.of(context).curTheme.text30,
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: StateContainer.of(context).wallet!.address ?? ""));
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
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 2,
                        color: StateContainer.of(context).curTheme.primary60 ?? Colors.transparent,
                      ),
                    ),
                    child: Icon(
                      Icons.content_copy,
                      size: 24,
                      color: StateContainer.of(context).curTheme.primary60,
                    ),
                  ),
                ),
              ),
              // Account switcher
              Container(
                // height: 36,
                // width: 36,
                // height: 48,
                // width: 48,
                alignment: Alignment.centerRight,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: StateContainer.of(context).curTheme.text30,
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                  ),
                  onPressed: () async {
                    final String seed = await StateContainer.of(context).getSeed();
                    final List<Account> accounts = await sl.get<DBHelper>().getAccounts(seed);

                    // ignore: use_build_context_synchronously
                    Sheets.showAppHeightNineSheet(
                      context: context,
                      widget: AppAccountsSheet(accounts: accounts),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        width: 2,
                        color: StateContainer.of(context).curTheme.primary60 ?? Colors.transparent,
                      ),
                    ),
                    child: Icon(
                      Icons.manage_accounts,
                      size: 24,
                      color: StateContainer.of(context).curTheme.primary60,
                    ),
                  ),
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
                            text: StateContainer.of(context).selectedAccount!.name,
                            style: TextStyle(
                              color: StateContainer.of(context).curTheme.text60,
                              fontSize: AppFontSizes.small,
                              fontWeight: FontWeight.w700,
                              fontFamily: "NunitoSans",
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            text: StateContainer.of(context).wallet?.username ??
                                Address(StateContainer.of(context).wallet!.address).getShortFirstPart(),
                            style: TextStyle(
                              color: StateContainer.of(context).curTheme.text60,
                              fontSize: AppFontSizes.small,
                              fontWeight: FontWeight.w700,
                              fontFamily: "NunitoSans",
                            ),
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
      ],
    );
  }
}
