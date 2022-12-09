import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/exceptions.dart';

enum AppButtonType { PRIMARY, PRIMARY_OUTLINE, SUCCESS, SUCCESS_OUTLINE, TEXT_OUTLINE }

class AppButton {
  static const double BORDER_RADIUS = 24.0;
  // Primary button builder
  static Widget buildAppButton(BuildContext context, AppButtonType type, String buttonText, List<double> dimens,
      {Function? onPressed, bool disabled = false, Key? instanceKey}) {
    switch (type) {
      case AppButtonType.PRIMARY:
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BORDER_RADIUS),
              boxShadow: [StateContainer.of(context).curTheme.boxShadowButton!],
            ),
            height: 55,
            margin: EdgeInsetsDirectional.fromSTEB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: TextButton(
              key: instanceKey,
              style: TextButton.styleFrom(
                foregroundColor: StateContainer.of(context).curTheme.background40,
                backgroundColor: disabled ? StateContainer.of(context).curTheme.primary60 : StateContainer.of(context).curTheme.primary,
                surfaceTintColor: StateContainer.of(context).curTheme.background40,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BORDER_RADIUS)),
              ),
              child: AutoSizeText(buttonText, textAlign: TextAlign.center, style: AppStyles.textStyleButtonPrimary(context), maxLines: 1, stepGranularity: 0.5),
              onPressed: () {
                if (onPressed != null && !disabled) {
                  onPressed();
                }
                return;
              },
            ),
          ),
        );
      case AppButtonType.PRIMARY_OUTLINE:
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: StateContainer.of(context).curTheme.backgroundDark,
              borderRadius: BorderRadius.circular(BORDER_RADIUS),
              boxShadow: [StateContainer.of(context).curTheme.boxShadowButton!],
            ),
            height: 55,
            margin: EdgeInsetsDirectional.fromSTEB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: StateContainer.of(context).curTheme.primary,
                backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                textStyle: TextStyle(color: disabled ? StateContainer.of(context).curTheme.primary60 : StateContainer.of(context).curTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BORDER_RADIUS),
                  // side: BorderSide(color: disabled ? StateContainer.of(context).curTheme.primary60! : StateContainer.of(context).curTheme.primary!, width: 2.0),
                ),
              ).copyWith(
                side: MaterialStateProperty.resolveWith<BorderSide>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed))
                      return BorderSide(
                        color: StateContainer.of(context).curTheme.primary!,
                        width: 2,
                      );
                    return BorderSide(
                      color: disabled ? StateContainer.of(context).curTheme.primary60! : StateContainer.of(context).curTheme.primary!,
                      width: 2,
                    );
                  },
                ),
              ),
              // borderSide: BorderSide(color: disabled ? StateContainer.of(context).curTheme.primary60 : StateContainer.of(context).curTheme.primary, width: 2.0),
              // highlightedBorderColor: disabled ? StateContainer.of(context).curTheme.primary60 : StateContainer.of(context).curTheme.primary,
              // splashColor: StateContainer.of(context).curTheme.primary30,
              // highlightColor: StateContainer.of(context).curTheme.primary15,

              // color: StateContainer.of(context).curTheme.backgroundDark,
              // textColor: disabled ? StateContainer.of(context).curTheme.primary60 : StateContainer.of(context).curTheme.primary,
              // borderSide: BorderSide(color: disabled ? StateContainer.of(context).curTheme.primary60 : StateContainer.of(context).curTheme.primary, width: 2.0),
              // highlightedBorderColor: disabled ? StateContainer.of(context).curTheme.primary60 : StateContainer.of(context).curTheme.primary,
              // splashColor: StateContainer.of(context).curTheme.primary30,
              // highlightColor: StateContainer.of(context).curTheme.primary15,
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: disabled ? AppStyles.textStyleButtonPrimaryOutlineDisabled(context) : AppStyles.textStyleButtonPrimaryOutline(context),
                maxLines: 1,
                stepGranularity: 0.5,
              ),
              onPressed: () {
                if (onPressed != null && !disabled) {
                  onPressed();
                }
                return;
              },
            ),
          ),
        );
      case AppButtonType.SUCCESS:
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BORDER_RADIUS),
              boxShadow: <BoxShadow>[StateContainer.of(context).curTheme.boxShadowButton!],
            ),
            height: 55,
            margin: EdgeInsetsDirectional.fromSTEB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: StateContainer.of(context).curTheme.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BORDER_RADIUS)),
                backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                // TODO: finish this
                // highlightColor: StateContainer.of(context).curTheme.success30,
                // splashColor: StateContainer.of(context).curTheme.successDark,
              ),
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: AppStyles.textStyleButtonPrimaryGreen(context),
                maxLines: 1,
                stepGranularity: 0.5,
              ),
              onPressed: () {
                if (onPressed != null && !disabled) {
                  onPressed();
                }
                return;
              },
            ),
          ),
        );
      case AppButtonType.SUCCESS_OUTLINE:
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: StateContainer.of(context).curTheme.backgroundDark,
              borderRadius: BorderRadius.circular(BORDER_RADIUS),
              boxShadow: [StateContainer.of(context).curTheme.boxShadowButton!],
            ),
            height: 55,
            margin: EdgeInsetsDirectional.fromSTEB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: StateContainer.of(context).curTheme.text15,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BORDER_RADIUS)),
                backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                side: BorderSide(color: StateContainer.of(context).curTheme.success!, width: 2.0),
              ) /*.copyWith(
                side: MaterialStateProperty.resolveWith<BorderSide>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed))
                      return BorderSide(
                        color: StateContainer.of(context).curTheme.primary!,
                        width: 2,
                      );
                    return BorderSide(
                      color: StateContainer.of(context).curTheme.success!,
                      width: 2,
                    );
                  },
                ),
              )*/
              ,
              // TODO:
              // color: StateContainer.of(context).curTheme.backgroundDark,
              // textColor: StateContainer.of(context).curTheme.success,
              // highlightedBorderColor: StateContainer.of(context).curTheme.success,
              // splashColor: StateContainer.of(context).curTheme.success30,
              // highlightColor: StateContainer.of(context).curTheme.success15,
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: AppStyles.textStyleButtonSuccessOutline(context),
                maxLines: 1,
                stepGranularity: 0.5,
              ),
              onPressed: () {
                if (onPressed != null) {
                  onPressed();
                }
                return;
              },
            ),
          ),
        );
      case AppButtonType.TEXT_OUTLINE:
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: StateContainer.of(context).curTheme.backgroundDark,
              borderRadius: BorderRadius.circular(BORDER_RADIUS),
              boxShadow: [StateContainer.of(context).curTheme.boxShadowButton!],
            ),
            height: 55,
            margin: EdgeInsetsDirectional.fromSTEB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: StateContainer.of(context).curTheme.text15,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BORDER_RADIUS)),
                backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                side: BorderSide(color: StateContainer.of(context).curTheme.text!, width: 2.0),
              ),
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: AppStyles.textStyleButtonTextOutline(context),
                maxLines: 1,
                stepGranularity: 0.5,
              ),
              onPressed: () {
                if (onPressed != null) {
                  onPressed();
                }
                return;
              },
            ),
          ),
        );
      default:
        throw UIException("Invalid Button Type $type");
    }
  }

  static Widget pillButton(BuildContext context, String buttonText, {void Function()? onPressed}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.only(left: 10, right: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: StateContainer.of(context).curTheme.background,
        ),
        onPressed: onPressed,
        // child: Text(buttonText, style: AppStyles.textStyleVersion(context)),
        child: Text(buttonText, style: AppStyles.textStyleVersion(context)),
      ),
    );
  }
}
