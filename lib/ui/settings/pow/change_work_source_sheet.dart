import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/node_modified_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/work_source.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/settings/pow/add_work_source_sheet.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

class ChangePowSheet extends StatefulWidget {
  const ChangePowSheet({super.key, required this.workSources});

  final List<WorkSource> workSources;

  @override
  ChangePowSheetState createState() => ChangePowSheetState();
}

class ChangePowSheetState extends State<ChangePowSheet> {
  static const int MAX_ACCOUNTS = 50;
  final GlobalKey expandedKey = GlobalKey();

  bool _addingItem = false;
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<NodeModifiedEvent>? _nodeModifiedSub;

  Future<bool> _onWillPop() async {
    if (_nodeModifiedSub != null) {
      _nodeModifiedSub!.cancel();
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    _addingItem = false;
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _registerBus() {
    // _nodeModifiedSub = EventTaxiImpl.singleton().registerTo<NodeModifiedEvent>().listen((NodeModifiedEvent event) {
    //   if (event.deleted) {
    //     if (event.node!.selected) {
    //       Future<void>.delayed(const Duration(milliseconds: 50), () {
    //         setState(() {
    //           widget.workSources
    //               .where((WorkSource a) => a.id == StateContainer.of(context).selectedAccount!.id)
    //               .forEach((WorkSource ws) async {
    //             ws.selected = true;
    //             await sl.get<DBHelper>().changeWorkSource(ws);
    //             // await sl.get<AccountService>().updateNode();
    //           });
    //         });
    //       });
    //     }
    //     setState(() {
    //       widget.workSources.removeWhere((WorkSource a) => a.id == event.node!.id);
    //     });
    //   } else if (event.created && event.node != null) {
    //     setState(() {
    //       widget.workSources.add(event.node!);
    //     });
    //   } else {
    //     // Name change
    //     setState(() {
    //       widget.workSources.removeWhere((Node a) => a.id == event.node!.id);
    //       widget.workSources.add(event.node!);
    //       widget.workSources.sort((Node a, Node b) => a.id!.compareTo(b.id!));
    //     });
    //   }
    // });
  }

  void _destroyBus() {
    if (_nodeModifiedSub != null) {
      _nodeModifiedSub!.cancel();
    }
  }

  Future<void> _changeItem(WorkSource ws, StateSetter setState) async {
    // // don't unselect if already selected
    if (ws.selected) {
      return;
    }
    // Change ws
    for (final WorkSource acc in widget.workSources) {
      if (acc.selected) {
        setState(() {
          acc.selected = false;
        });
      } else if (ws.id == acc.id) {
        setState(() {
          acc.selected = true;
        });
      }
    }
    await sl.get<DBHelper>().changeWorkSource(ws);
    // EventTaxiImpl.singleton().fire(NodeChangedEvent(node: node, delayPop: true));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.035,
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
                      Handlebars.horizontal(context),
                      Container(
                        margin: const EdgeInsets.only(top: 15.0),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                        child: Column(
                          children: <Widget>[
                            AutoSizeText(
                              CaseChange.toUpperCase(Z.of(context).pow, context),
                              style: AppStyles.textStyleHeader(context),
                              maxLines: 1,
                              stepGranularity: 0.1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: AppDialogs.infoButton(
                      context,
                      () {
                        AppDialogs.showInfoDialog(
                          context,
                          Z.of(context).changePowSource,
                          Z.of(context).changePowSourceInfo,
                        );
                      },
                    ),
                  ),
                ],
              ),

              // A list containing accounts
              Expanded(
                  key: expandedKey,
                  child: Stack(
                    children: <Widget>[
                      if (widget.workSources == null)
                        const Center(
                          child: Text("Loading"),
                        )
                      else
                        DraggableScrollbar(
                          controller: _scrollController,
                          scrollbarColor: StateContainer.of(context).curTheme.primary,
                          scrollbarTopMargin: 20.0,
                          scrollbarBottomMargin: 12.0,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            // padding: const EdgeInsets.only(right: 2),
                            itemCount: widget.workSources.length,
                            controller: _scrollController,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildListItem(context, widget.workSources[index], setState, index);
                            },
                          ),
                        ),

                      // begin: const AlignmentDirectional(0.5, 1.0),
                      // end: const AlignmentDirectional(0.5, -1.0),
                      ListGradient(
                        height: 20,
                        top: true,
                        color: StateContainer.of(context).curTheme.backgroundDark!,
                      ),
                      ListGradient(
                        height: 20,
                        top: false,
                        color: StateContainer.of(context).curTheme.backgroundDark!,
                      ),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),
              //A row with Add Account button
              if (widget.workSources.length < MAX_ACCOUNTS)
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                      context,
                      AppButtonType.PRIMARY,
                      Z.of(context).addWorkSource,
                      Dimens.BUTTON_TOP_DIMENS,
                      disabled: _addingItem,
                      onPressed: () async {
                        if (_addingItem) {
                          return;
                        }
                        setState(() {
                          _addingItem = true;
                        });

                        WorkSource? ws = await Sheets.showAppHeightEightSheet(
                          context: context,
                          widget: const AddWorkSourceSheet(),
                        ) as WorkSource?;
                        if (!mounted) return;
                        if (ws == null) {
                          setState(() {
                            _addingItem = false;
                          });
                          return;
                        }
                        ws.id = widget.workSources.length;

                        sl.get<DBHelper>().saveWorkSource(ws).then((WorkSource? newWs) {
                          if (newWs == null) {
                            sl.get<Logger>().d("Error adding worksource: worksource was null");
                            return;
                          }
                          widget.workSources.add(newWs);
                          setState(() {
                            _addingItem = false;
                            widget.workSources.sort((WorkSource a, WorkSource b) => a.id!.compareTo(b.id!));
                            // Scroll if list is full
                            if (expandedKey.currentContext != null) {
                              final RenderBox? box = expandedKey.currentContext!.findRenderObject() as RenderBox?;
                              if (box == null) return;
                              if (widget.workSources.length * 72.0 >= box.size.height) {
                                _scrollController.animateTo(
                                  newWs.id! * 72.0 > _scrollController.position.maxScrollExtent
                                      ? _scrollController.position.maxScrollExtent + 72.0
                                      : newWs.id! * 72.0,
                                  curve: Curves.easeOut,
                                  duration: const Duration(milliseconds: 200),
                                );
                              }
                            }
                          });
                        });
                      },
                    ),
                  ],
                ),
              // Close button
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY_OUTLINE,
                    Z.of(context).close,
                    Dimens.BUTTON_BOTTOM_DIMENS,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildListItem(BuildContext context, WorkSource ws, StateSetter setState, int index) {
    return Column(
      children: <Widget>[
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Slidable(
            closeOnScroll: true,
            endActionPane: _getSlideActionsForListItem(context, ws, setState),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: StateContainer.of(context).curTheme.text15,
                backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),

              // highlightColor: StateContainer.of(context).curTheme.text15,
              // splashColor: StateContainer.of(context).curTheme.text15,
              // padding: EdgeInsets.all(0.0),
              onPressed: () async {
                await _changeItem(ws, setState);
              },
              child: SizedBox(
                height: 70.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // // Selected indicator
                    // Container(
                    //   height: 70,
                    //   width: 6,
                    //   color: node.selected ? StateContainer.of(context).curTheme.primary : Colors.transparent,
                    // ),
                    // Icon, Account Name, Address and Amount
                    Expanded(
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(start: 20, end: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Center(
                                      child: Container(
                                        margin: EdgeInsets.zero,
                                        child: Icon(
                                          Icons.hub,
                                          color: ws.selected
                                              ? StateContainer.of(context).curTheme.success
                                              : StateContainer.of(context).curTheme.primary,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Account name and address
                                Container(
                                  width: (MediaQuery.of(context).size.width - 116) * 0.9,
                                  // width: (MediaQuery.of(context).size.width - 200),
                                  margin: const EdgeInsetsDirectional.only(start: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Account name
                                      AutoSizeText(
                                        ws.name,
                                        style: TextStyle(
                                          fontFamily: "NunitoSans",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                          color: StateContainer.of(context).curTheme.text,
                                        ),
                                        minFontSize: 8.0,
                                        stepGranularity: 1,
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                      ),
                                      // // type
                                      // AutoSizeText(
                                      //   ws.type,
                                      //   style: TextStyle(
                                      //     fontFamily: "OverpassMono",
                                      //     fontWeight: FontWeight.w100,
                                      //     fontSize: 14.0,
                                      //     color: StateContainer.of(context).curTheme.text60,
                                      //   ),
                                      //   minFontSize: 8.0,
                                      //   stepGranularity: 0.1,
                                      //   maxLines: 2,
                                      // ),
                                      if (ws.type == WorkSourceTypes.URL)
                                        AutoSizeText(
                                          "${ws.url}",
                                          style: TextStyle(
                                            fontFamily: "OverpassMono",
                                            fontWeight: FontWeight.w100,
                                            fontSize: 14.0,
                                            color: StateContainer.of(context).curTheme.text60,
                                          ),
                                          minFontSize: 8.0,
                                          stepGranularity: 0.1,
                                          maxLines: 2,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Handlebars.vertical(context),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (index == widget.workSources.length - 1)
          Divider(
            height: 2,
            color: StateContainer.of(context).curTheme.text15,
          ),
      ],
    );
  }

  ActionPane _getSlideActionsForListItem(BuildContext context, WorkSource node, StateSetter setState) {
    final List<Widget> actions = <Widget>[];

    actions.add(SlidableAction(
        autoClose: false,
        borderRadius: BorderRadius.circular(5.0),
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
        foregroundColor: StateContainer.of(context).curTheme.primary,
        icon: Icons.edit,
        label: Z.of(context).edit,
        onPressed: (BuildContext context) async {
          // await Future<dynamic>.delayed(const Duration(milliseconds: 250));
          // if (!mounted) return;
          // Sheets.showAppHeightNineSheet(
          //   context: context,
          //   widget: NodeDetailsSheet(node: node),
          // );
          // await Slidable.of(context)!.close();
        }));

    if (node.id! > 2) {
      actions.add(
        SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
          foregroundColor: StateContainer.of(context).curTheme.error60,
          icon: Icons.delete,
          label: Z.of(context).delete,
          onPressed: (BuildContext context) {
            AppDialogs.showConfirmDialog(context, Z.of(context).deleteWorkSourceHeader, Z.of(context).deleteWorkSourceConfirmation,
                CaseChange.toUpperCase(Z.of(context).yes, context), () async {
              await Future<dynamic>.delayed(const Duration(milliseconds: 250));
              // Remove account
              await sl.get<DBHelper>().deleteWorkSource(node);
              // EventTaxiImpl.singleton().fire(NodeModifiedEvent(node: node, deleted: true));
              setState(() {
                widget.workSources.removeWhere((WorkSource acc) => acc.id == node.id);
              });
              if (!mounted) return;
              await Slidable.of(context)!.close();
            }, cancelText: CaseChange.toUpperCase(Z.of(context).no, context));
          },
        ),
      );
    }

    return ActionPane(
      // motion: const DrawerMotion(),
      motion: const ScrollMotion(),
      extentRatio: (node.id! > 2) ? 0.5 : 0.25,
      children: actions,
    );
  }
}
