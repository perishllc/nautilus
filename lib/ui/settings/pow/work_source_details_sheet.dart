import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/node_modified_event.dart';
import 'package:wallet_flutter/bus/work_source_modified_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/node.dart';
import 'package:wallet_flutter/model/db/work_source.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/sheets.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

class WorkSourceDetailsSheet extends StatefulWidget {
  WorkSourceDetailsSheet({required this.workSource}) : super();
  WorkSource workSource;

  @override
  WorkSourceDetailsSheetState createState() => WorkSourceDetailsSheetState();
}

class WorkSourceDetailsSheetState extends State<WorkSourceDetailsSheet> {
  String? originalName;
  String? originalHttp;
  String? originalWs;

  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final TextEditingController _httpController = TextEditingController();
  final FocusNode _httpFocusNode = FocusNode();

  // Address copied or not
  late bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  Future<bool> _save() async {
    // Update name if changed and valid
    if (originalName != _nameController.text && _nameController.text.trim().isNotEmpty) {
      sl.get<DBHelper>().changeWorkSourceName(widget.workSource, _nameController.text);
      widget.workSource.name = _nameController.text;
      EventTaxiImpl.singleton().fire(WorkSourceModifiedEvent(workSource: widget.workSource));
    }

    if (originalHttp != _httpController.text && _httpController.text.trim().isNotEmpty) {
      sl.get<DBHelper>().changeWorkSourceUrl(widget.workSource, _httpController.text);
      widget.workSource.url = _httpController.text;
      EventTaxiImpl.singleton().fire(WorkSourceModifiedEvent(workSource: widget.workSource));
    }

    if (widget.workSource.selected) {
      await sl.get<DBHelper>().changeWorkSource(widget.workSource);
    }

    return true;
  }

  void initState() {
    super.initState();
    originalName = widget.workSource.name;
    originalHttp = widget.workSource.url;
  }

  @override
  Widget build(BuildContext context) {
    _addressCopied = false;
    _nameController.text = widget.workSource.name;
    _httpController.text = widget.workSource.url ?? "";
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return TapOutsideUnfocus(
        child: SafeArea(
          minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
          child: Column(
            children: <Widget>[
              Handlebars.horizontal(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsetsDirectional.only(top: 18.0, start: 10.0),
                    child: const SizedBox(),
                  ),

                  // The header of the sheet
                  Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                    child: Column(
                      children: <Widget>[
                        AutoSizeText(
                          CaseChange.toUpperCase(Z.of(context).pow, context),
                          style: AppStyles.textStyleHeader(context),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          stepGranularity: 0.1,
                        ),
                      ],
                    ),
                  ),
                  // Search Button
                  const SizedBox(height: 50, width: 50),
                ],
              ),
              // Address Text
              // Container(
              //   margin: const EdgeInsets.only(top: 10.0),
              //   child: account.address != null
              //       ? UIUtil.threeLineAddressText(context, account.address!,
              //           type: ThreeLineAddressTextType.PRIMARY60)
              //       : account.selected
              //           ? UIUtil.threeLineAddressText(
              //               context, StateContainer.of(context).wallet!.address!,
              //               type: ThreeLineAddressTextType.PRIMARY60)
              //           : const SizedBox(),
              // ),
              // The main container that holds Contact Name and Contact Address
              Expanded(
                child: KeyboardAvoider(
                    duration: Duration.zero,
                    autoScroll: true,
                    focusPadding: 40,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      AppTextField(
                        topMargin: MediaQuery.of(context).size.width * 0.14,
                        rightMargin: MediaQuery.of(context).size.width * 0.105,
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: StateContainer.of(context).curTheme.primary,
                          fontFamily: "NunitoSans",
                        ),
                      ),
                      AppTextField(
                        topMargin: MediaQuery.of(context).size.width * 0.14,
                        rightMargin: MediaQuery.of(context).size.width * 0.105,
                        controller: _httpController,
                        focusNode: _httpFocusNode,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: StateContainer.of(context).curTheme.text60,
                          fontFamily: "NunitoSans",
                        ),
                      ),
                    ])),
              ),
              Column(
                children: <Widget>[
                  // Row(
                  //   children: <Widget>[
                  //     AppButton.buildAppButton(
                  //         context,
                  //         // Share Address Button
                  //         _addressCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                  //         _addressCopied
                  //             ? Z.of(context).addressCopied
                  //             : Z.of(context).copyAddress,
                  //         Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                  //       Clipboard.setData(ClipboardData(text: node.address));
                  //       setState(() {
                  //         // Set copied style
                  //         _addressCopied = true;
                  //       });
                  //       if (_addressCopiedTimer != null) {
                  //         _addressCopiedTimer!.cancel();
                  //       }
                  //       _addressCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                  //         setState(() {
                  //           _addressCopied = false;
                  //         });
                  //       });
                  //     }),
                  //   ],
                  // ),
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY, Z.of(context).save, Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        _save();
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS,
                          onPressed: () {
                        _save();
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
    ;
  }
}
