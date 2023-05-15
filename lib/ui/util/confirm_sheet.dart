import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_cron/easy_cron.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/scheduled_modified_event.dart';
import 'package:wallet_flutter/bus/sub_modified_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/scheduled.dart';
import 'package:wallet_flutter/model/db/subscription.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/subs/add_scheduled_sheet.dart';
import 'package:wallet_flutter/ui/subs/add_sub_sheet.dart';
import 'package:wallet_flutter/ui/subs/scheduled_confirm_sheet.dart';
import 'package:wallet_flutter/ui/subs/sub_confirm_sheet.dart';
import 'package:wallet_flutter/ui/subs/sub_details_sheet.dart';
import 'package:wallet_flutter/ui/upcoming/scheduled_details_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/ui/widgets/transaction_state_tag.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

class ConfirmSheet extends StatefulWidget {
  ConfirmSheet({
    super.key,
    this.title = "",
    this.subtitle = "",
    this.infoButtonTitle = "",
    this.infoButtonText = "",
  });

  String title;
  String subtitle;
  String infoButtonTitle;
  String infoButtonText;

  @override
  ConfirmSheetState createState() => ConfirmSheetState();
}

class ConfirmSheetState extends State<ConfirmSheet> {
  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _registerBus() {}

  void _destroyBus() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(
        // bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDark,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                  ),
                  Column(
                    children: <Widget>[
                      Handlebars.horizontal(
                        context,
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                      if (widget.title.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 15.0),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                          child: Column(
                            children: <Widget>[
                              AutoSizeText(
                                CaseChange.toUpperCase(widget.title, context),
                                style: AppStyles.textStyleHeader(context),
                                maxLines: 1,
                                stepGranularity: 0.1,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (widget.infoButtonTitle.isNotEmpty)
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: AppDialogs.infoButton(
                        context,
                        () {
                          AppDialogs.showInfoDialog(
                            context,
                            widget.infoButtonTitle,
                            widget.infoButtonText,
                          );
                        },
                      ),
                    )
                  else
                    const SizedBox(
                      width: 60,
                      height: 60,
                    ),
                ],
              ),
              if (widget.subtitle.isNotEmpty)
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 30, right: 30),
                      child: Text(
                        widget.subtitle,
                        style: AppStyles.textStyleParagraph(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 35,
              ),
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY_OUTLINE,
                    Z.of(context).cancel,
                    Dimens.BUTTON_COMPACT_LEFT_DIMENS,
                    onPressed: () async {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY,
                    Z.of(context).confirm,
                    Dimens.BUTTON_COMPACT_RIGHT_DIMENS,
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
