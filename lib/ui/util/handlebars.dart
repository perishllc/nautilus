import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';

class Handlebars {
  static Widget vertical(BuildContext context, {double height = 30}) {
    return Container(
      width: 4,
      height: height,
      margin: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.text45,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static Widget horizontal(
    BuildContext context, {
    EdgeInsetsGeometry margin = const EdgeInsets.only(top: 10),
    double? width,
  }) {
    width ??= MediaQuery.of(context).size.width * 0.15;
    return Container(
      margin: margin,
      height: 5,
      width: width,
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.text20,
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }
}
