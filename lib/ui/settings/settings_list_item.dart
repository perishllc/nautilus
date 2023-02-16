import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/model/setting_item.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';

class AppSettings {
  // Settings item with a dropdown option
  static Widget buildSettingsListItemDoubleLine(
      BuildContext context, String heading, SettingSelectionItem? defaultMethod, IconData icon, Function onPressed,
      {bool disabled = false, String? overrideSubtitle}) {
    return IgnorePointer(
      ignoring: disabled,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: StateContainer.of(context).curTheme.text15,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),

          // highlightColor: StateContainer.of(context).curTheme.text15,
          // splashColor: StateContainer.of(context).curTheme.text15,
        ),
        onPressed: () {
          // ignore: avoid_dynamic_calls
          onPressed();
        },
        child: Container(
          height: 60.0,
          margin: const EdgeInsetsDirectional.only(start: 30.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsetsDirectional.only(end: 13.0),
                child: Container(
                  margin: const EdgeInsets.only(top: 3, left: 3, bottom: 3, right: 3),
                  child: Icon(icon,
                      color: disabled
                          ? StateContainer.of(context).curTheme.primary45
                          : StateContainer.of(context).curTheme.primary,
                      size: 24),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: UIUtil.drawerWidth(context) - 100,
                    child: AutoSizeText(
                      heading,
                      style: disabled
                          ? AppStyles.textStyleSettingItemHeader45(context)
                          : AppStyles.textStyleSettingItemHeader(context),
                      maxLines: 1,
                      stepGranularity: 0.1,
                      minFontSize: 8,
                    ),
                  ),
                  SizedBox(
                    width: UIUtil.drawerWidth(context) - 100,
                    child: AutoSizeText(
                      overrideSubtitle ?? defaultMethod!.getDisplayName(context),
                      style: disabled
                          ? AppStyles.textStyleSettingItemSubheader30(context)
                          : AppStyles.textStyleSettingItemSubheader(context),
                      maxLines: 1,
                      stepGranularity: 0.1,
                      minFontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Settings item with direct functionality and two lines
  static Widget buildSettingsListItemDoubleLineTwo(
      BuildContext context, String heading, String text, IconData icon, Function onPressed,
      {bool disabled = false}) {
    return IgnorePointer(
      ignoring: disabled,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: StateContainer.of(context).curTheme.text15, padding: EdgeInsets.zero,
          // highlightColor: StateContainer.of(context).curTheme.text15,
          // splashColor: StateContainer.of(context).curTheme.text15,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        onPressed: () {
          // ignore: avoid_dynamic_calls
          onPressed();
        },
        child: Container(
          height: 60.0,
          margin: const EdgeInsetsDirectional.only(start: 30.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsetsDirectional.only(end: 13.0),
                child: Container(
                  margin: const EdgeInsets.only(top: 3, left: 3, bottom: 3, right: 3),
                  child: Icon(icon,
                      color: disabled
                          ? StateContainer.of(context).curTheme.primary45
                          : StateContainer.of(context).curTheme.primary,
                      size: 24),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: UIUtil.drawerWidth(context) - 100,
                    child: AutoSizeText(
                      heading,
                      style: disabled
                          ? AppStyles.textStyleSettingItemHeader45(context)
                          : AppStyles.textStyleSettingItemHeader(context),
                      maxLines: 1,
                      stepGranularity: 0.1,
                      minFontSize: 8,
                    ),
                  ),
                  SizedBox(
                    width: UIUtil.drawerWidth(context) - 100,
                    child: AutoSizeText(
                      text,
                      style: disabled
                          ? AppStyles.textStyleSettingItemSubheader30(context)
                          : AppStyles.textStyleSettingItemSubheader(context),
                      maxLines: 1,
                      stepGranularity: 0.1,
                      minFontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Settings item without any dropdown option but rather a direct functionality
  static Widget buildSettingsListItemSingleLine(
    BuildContext context,
    String heading,
    IconData settingIcon, {
    Function? onPressed,
    Function? onLongPress,
    bool disabled = false,
    Widget? iconOverride,
  }) {
    return IgnorePointer(
      ignoring: disabled,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: StateContainer.of(context).curTheme.text15, padding: EdgeInsets.zero,
          // highlightColor: StateContainer.of(context).curTheme.text15,
          // splashColor: StateContainer.of(context).curTheme.text15,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        onLongPress: () {
          if (onLongPress != null) {
            // ignore: avoid_dynamic_calls
            onLongPress();
          } else {
            return;
          }
        },
        onPressed: () {
          if (onPressed != null) {
            // ignore: avoid_dynamic_calls
            onPressed();
          } else {
            return;
          }
        },
        child: Container(
          height: 60.0,
          margin: const EdgeInsetsDirectional.only(start: 30.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsetsDirectional.only(end: 13.0),
                child: Container(
                  margin: EdgeInsetsDirectional.only(
                    top: 3,
                    start: settingIcon == AppIcons.logout
                        ? 6
                        : settingIcon == AppIcons.changerepresentative
                            ? 0
                            : settingIcon == AppIcons.backupseed
                                ? 1
                                : settingIcon == AppIcons.transferfunds
                                    ? 2
                                    : 3,
                    bottom: 3,
                    end: settingIcon == AppIcons.logout
                        ? 0
                        : settingIcon == AppIcons.changerepresentative
                            ? 6
                            : settingIcon == AppIcons.backupseed
                                ? 5
                                : settingIcon == AppIcons.transferfunds
                                    ? 4
                                    : 3,
                  ),
                  child: iconOverride ??
                      Icon(
                        settingIcon,
                        color: disabled
                            ? StateContainer.of(context).curTheme.primary45
                            : StateContainer.of(context).curTheme.primary,
                        size: 24,
                      ),
                ),
              ),
              SizedBox(
                width: UIUtil.drawerWidth(context) - 100,
                child: Text(
                  heading,
                  style: disabled
                      ? AppStyles.textStyleSettingItemHeader45(context)
                      : AppStyles.textStyleSettingItemHeader(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildSettingsListItemSingleLineTwoItems(
    BuildContext context,
    String heading,
    IconData settingIcon, {
    Function? onPressed,
    Function? onLongPress,
    bool disabled = false,
    Widget? iconOverride,
  }) {
    return IgnorePointer(
      ignoring: disabled,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: StateContainer.of(context).curTheme.text15, padding: EdgeInsets.zero,
          // highlightColor: StateContainer.of(context).curTheme.text15,
          // splashColor: StateContainer.of(context).curTheme.text15,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        onLongPress: () {
          if (onLongPress != null) {
            // ignore: avoid_dynamic_calls
            onLongPress();
          } else {
            return;
          }
        },
        onPressed: () {
          if (onPressed != null) {
            // ignore: avoid_dynamic_calls
            onPressed();
          } else {
            return;
          }
        },
        child: Container(
          height: 60.0,
          // width: 120,
          // margin: const EdgeInsetsDirectional.only(start: 30.0, end: 12),
          child: Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsetsDirectional.only(end: 13.0),
                child: Container(
                  margin: EdgeInsetsDirectional.only(
                    top: 3,
                    start: settingIcon == AppIcons.logout
                        ? 6
                        : settingIcon == AppIcons.changerepresentative
                            ? 0
                            : settingIcon == AppIcons.backupseed
                                ? 1
                                : settingIcon == AppIcons.transferfunds
                                    ? 2
                                    : 3,
                    bottom: 3,
                    end: settingIcon == AppIcons.logout
                        ? 0
                        : settingIcon == AppIcons.changerepresentative
                            ? 6
                            : settingIcon == AppIcons.backupseed
                                ? 5
                                : settingIcon == AppIcons.transferfunds
                                    ? 4
                                    : 3,
                  ),
                  child: iconOverride ??
                      Icon(
                        settingIcon,
                        color: disabled
                            ? StateContainer.of(context).curTheme.primary45
                            : StateContainer.of(context).curTheme.primary,
                        size: 24,
                      ),
                ),
              ),
              SizedBox(
                // width: UIUtil.drawerWidth(context) / 3,
                child: Text(
                  heading,
                  style: disabled
                      ? AppStyles.textStyleSettingItemHeader45(context)
                      : AppStyles.textStyleSettingItemHeader(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // // Settings item with a dropdown option
  // static Widget buildSettingsListItemDoubleLine(
  //     BuildContext context, String heading, SettingSelectionItem? defaultMethod, IconData icon, Function onPressed,
  //     {bool disabled = false, String? overrideSubtitle}) {
  //   return IgnorePointer(
  //     ignoring: disabled,
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         foregroundColor: StateContainer.of(context).curTheme.text15,
  //         backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
  //         padding: EdgeInsets.zero,
  //         // highlightColor: StateContainer.of(context).curTheme.text15,
  //         // splashColor: StateContainer.of(context).curTheme.text15,
  //       ),
  //       onPressed: () {
  //         // ignore: avoid_dynamic_calls
  //         onPressed();
  //       },
  //       child: Container(
  //         height: 60.0,
  //         margin: const EdgeInsetsDirectional.only(start: 30.0),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: <Widget>[
  //             Container(
  //               margin: const EdgeInsetsDirectional.only(end: 13.0),
  //               child: Container(
  //                 margin: const EdgeInsets.only(top: 3, left: 3, bottom: 3, right: 3),
  //                 child: Icon(icon,
  //                     color: disabled
  //                         ? StateContainer.of(context).curTheme.primary45
  //                         : StateContainer.of(context).curTheme.primary,
  //                     size: 24),
  //               ),
  //             ),
  //             Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 SizedBox(
  //                   width: UIUtil.drawerWidth(context) - 100,
  //                   child: AutoSizeText(
  //                     heading,
  //                     style: disabled
  //                         ? AppStyles.textStyleSettingItemHeader45(context)
  //                         : AppStyles.textStyleSettingItemHeader(context),
  //                     maxLines: 1,
  //                     stepGranularity: 0.1,
  //                     minFontSize: 8,
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: UIUtil.drawerWidth(context) - 100,
  //                   child: AutoSizeText(
  //                     overrideSubtitle ?? defaultMethod!.getDisplayName(context),
  //                     style: disabled
  //                         ? AppStyles.textStyleSettingItemSubheader30(context)
  //                         : AppStyles.textStyleSettingItemSubheader(context),
  //                     maxLines: 1,
  //                     stepGranularity: 0.1,
  //                     minFontSize: 8,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // //Settings item with direct functionality and two lines
  // static Widget buildSettingsListItemDoubleLineTwo(
  //     BuildContext context, String heading, String text, IconData icon, Function onPressed,
  //     {bool disabled = false}) {
  //   return IgnorePointer(
  //     ignoring: disabled,
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         foregroundColor: StateContainer.of(context).curTheme.text15,
  //         backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
  //         padding: EdgeInsets.zero,

  //         // highlightColor: StateContainer.of(context).curTheme.text15,
  //         // splashColor: StateContainer.of(context).curTheme.text15,
  //       ),
  //       onPressed: () {
  //         // ignore: avoid_dynamic_calls
  //         onPressed();
  //       },
  //       child: Container(
  //         height: 60.0,
  //         margin: const EdgeInsetsDirectional.only(start: 30.0),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: <Widget>[
  //             Container(
  //               margin: const EdgeInsetsDirectional.only(end: 13.0),
  //               child: Container(
  //                 margin: const EdgeInsets.only(top: 3, left: 3, bottom: 3, right: 3),
  //                 child: Icon(icon,
  //                     color: disabled
  //                         ? StateContainer.of(context).curTheme.primary45
  //                         : StateContainer.of(context).curTheme.primary,
  //                     size: 24),
  //               ),
  //             ),
  //             Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 SizedBox(
  //                   width: UIUtil.drawerWidth(context) - 100,
  //                   child: AutoSizeText(
  //                     heading,
  //                     style: disabled
  //                         ? AppStyles.textStyleSettingItemHeader45(context)
  //                         : AppStyles.textStyleSettingItemHeader(context),
  //                     maxLines: 1,
  //                     stepGranularity: 0.1,
  //                     minFontSize: 8,
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: UIUtil.drawerWidth(context) - 100,
  //                   child: AutoSizeText(
  //                     text,
  //                     style: disabled
  //                         ? AppStyles.textStyleSettingItemSubheader30(context)
  //                         : AppStyles.textStyleSettingItemSubheader(context),
  //                     maxLines: 1,
  //                     stepGranularity: 0.1,
  //                     minFontSize: 8,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // //Settings item without any dropdown option but rather a direct functionality
  // static Widget buildSettingsListItemSingleLine(BuildContext context, String heading, IconData settingIcon,
  //     {Function? onPressed, bool disabled = false, Widget? iconOverride}) {
  //   return IgnorePointer(
  //     ignoring: disabled,
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         foregroundColor: StateContainer.of(context).curTheme.text15, padding: EdgeInsets.zero,
  //         backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
  //         // highlightColor: StateContainer.of(context).curTheme.text15,
  //         // splashColor: StateContainer.of(context).curTheme.text15,
  //       ),
  //       onPressed: () {
  //         if (onPressed != null) {
  //           // ignore: avoid_dynamic_calls
  //           onPressed();
  //         } else {
  //           return;
  //         }
  //       },
  //       child: Container(
  //         height: 60.0,
  //         margin: const EdgeInsetsDirectional.only(start: 30.0),
  //         child: Row(
  //           children: <Widget>[
  //             Container(
  //               margin: const EdgeInsetsDirectional.only(end: 13.0),
  //               child: Container(
  //                 margin: EdgeInsetsDirectional.only(
  //                   top: 3,
  //                   start: settingIcon == AppIcons.logout
  //                       ? 6
  //                       : settingIcon == AppIcons.changerepresentative
  //                           ? 0
  //                           : settingIcon == AppIcons.backupseed
  //                               ? 1
  //                               : settingIcon == AppIcons.transferfunds
  //                                   ? 2
  //                                   : 3,
  //                   bottom: 3,
  //                   end: settingIcon == AppIcons.logout
  //                       ? 0
  //                       : settingIcon == AppIcons.changerepresentative
  //                           ? 6
  //                           : settingIcon == AppIcons.backupseed
  //                               ? 5
  //                               : settingIcon == AppIcons.transferfunds
  //                                   ? 4
  //                                   : 3,
  //                 ),
  //                 child: iconOverride ??
  //                     Icon(
  //                       settingIcon,
  //                       color: disabled
  //                           ? StateContainer.of(context).curTheme.primary45
  //                           : StateContainer.of(context).curTheme.primary,
  //                       size: 24,
  //                     ),
  //               ),
  //             ),
  //             SizedBox(
  //               width: UIUtil.drawerWidth(context) - 100,
  //               child: Text(
  //                 heading,
  //                 style: disabled
  //                     ? AppStyles.textStyleSettingItemHeader45(context)
  //                     : AppStyles.textStyleSettingItemHeader(context),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
