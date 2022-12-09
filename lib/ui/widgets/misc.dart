import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/styles.dart';

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
}
