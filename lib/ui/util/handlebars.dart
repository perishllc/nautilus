import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';

class Handlebars {
  static Widget vertical(BuildContext context) {
    return Container(
      width: 4,
      height: 30,
      margin: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.text45,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
