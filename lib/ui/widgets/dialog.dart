import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/wallet.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/themes.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:markdown/markdown.dart' as md;
import 'package:rive/rive.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDialogs {
  static void showConfirmDialog(var context, var title, var content, var buttonText, Function onPressed, {String cancelText, Function cancelAction}) {
    if (cancelText == null) {
      cancelText = AppLocalization.of(context).cancel.toUpperCase();
    }
    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return AppAlertDialog(
          title: Text(
            title,
            style: AppStyles.textStyleButtonPrimaryOutline(context),
          ),
          content: Text(content, style: AppStyles.textStyleParagraph(context)),
          actions: <Widget>[
            FlatButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
              padding: EdgeInsets.all(12),
              child: Container(
                constraints: BoxConstraints(maxWidth: 100),
                child: Text(
                  cancelText,
                  style: AppStyles.textStyleDialogButtonText(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (cancelAction != null) {
                  cancelAction();
                }
              },
            ),
            FlatButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
              padding: EdgeInsets.all(12),
              child: Container(
                constraints: BoxConstraints(maxWidth: 100),
                child: Text(
                  buttonText,
                  style: AppStyles.textStyleDialogButtonText(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onPressed();
              },
            ),
          ],
        );
      },
    );
  }

  static void showInfoDialog(var context, var title, var content) {
    showDialog(
      barrierColor: StateContainer.of(context).curTheme.barrier,
      context: context,
      builder: (BuildContext context) {
        return AppAlertDialog(
          title: Text(
            title,
            style: AppStyles.textStyleButtonPrimaryOutline(context),
          ),
          content: Text(content, style: AppStyles.textStyleParagraph(context)),
          actions: <Widget>[
            FlatButton(
              child: Text(
                AppLocalization.of(context).cancel.toUpperCase(),
                style: AppStyles.textStyleDialogButtonText(context),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showChangeLog(BuildContext context) async {
    String changeLogMarkdown = await DefaultAssetBundle.of(context).loadString("CHANGELOG.md");

    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext ctx) => material.Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              backgroundColor: StateContainer.of(context).curTheme.backgroundDarkest,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(AppLocalization.of(context).changeLog, textAlign: TextAlign.center, style: AppStyles.textStyleDialogHeader(context)),
                  ),
                  Container(
                      constraints: BoxConstraints(minHeight: 300, maxHeight: 400),
                      child: new Scrollbar(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                child: MarkdownBody(
                                  data: changeLogMarkdown,
                                  shrinkWrap: true,
                                  selectable: false,
                                  onTapLink: (text, url, title) async {
                                    Uri uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
                                      textTheme: TextTheme(
                                    bodyText2: TextStyle(
                                      fontSize: AppFontSizes.smallText(context),
                                      fontWeight: FontWeight.w400,
                                      color: StateContainer.of(context).curTheme.text,
                                    ),
                                  ))).copyWith(
                                    h1: TextStyle(
                                      fontSize: AppFontSizes.large(context),
                                      color: StateContainer.of(context).curTheme.success,
                                    ),
                                    h2: TextStyle(
                                      fontSize: AppFontSizes.large(context),
                                      color: StateContainer.of(context).curTheme.success,
                                    ),
                                    h2Padding: EdgeInsets.only(top: 24),
                                    h4: TextStyle(
                                      color: StateContainer.of(context).curTheme.warning,
                                    ),
                                    listBullet: TextStyle(
                                      color: StateContainer.of(context).curTheme.text,
                                    ),
                                    horizontalRuleDecoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: 3, color: StateContainer.of(context).curTheme.text),
                                      ),
                                    ),
                                  ),
                                  extensionSet: md.ExtensionSet(
                                    md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                                    [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          // Go to send with address
                          Future.delayed(Duration(milliseconds: 1000), () {
                            Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                            Sheets.showAppHeightNineSheet(
                                context: context,
                                widget: SendSheet(
                                  localCurrency: StateContainer.of(context).curCurrency,
                                  address: AppWallet.nautilusRepresentative,
                                  quickSendAmount: "1000000000000000000000000000000",
                                ));
                          });
                        },
                        child: Text(
                          AppLocalization.of(context).supportTheDeveloper,
                          style: TextStyle(
                            fontSize: AppFontSizes.medium,
                            color: StateContainer.of(context).curTheme.primary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalization.of(context).dismiss, style: AppStyles.textStyleDialogOptions(context)),
                      ),
                    ]),
                  ),
                ],
              ),
            ));
  }
}

enum AnimationType { SEND, GENERIC, TRANSFER_SEARCHING_QR, TRANSFER_SEARCHING_MANUAL, TRANSFER_TRANSFERRING, MANTA, LOADING, SEARCHING }

class AnimationLoadingOverlay extends ModalRoute<void> {
  AnimationType type;
  Function onPoppedCallback;
  Color barrier;
  Color barrierStronger;
  AnimationController _controller;

  AnimationLoadingOverlay(this.type, this.barrier, this.barrierStronger, {this.onPoppedCallback});

  @override
  Duration get transitionDuration => Duration(milliseconds: 0);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor {
    if (type == AnimationType.TRANSFER_TRANSFERRING || type == AnimationType.TRANSFER_SEARCHING_QR || type == AnimationType.TRANSFER_SEARCHING_MANUAL) {
      return barrierStronger;
    }
    return barrier;
  }

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => false;

  @override
  void didComplete(void result) {
    if (this.onPoppedCallback != null) {
      this.onPoppedCallback();
    }
    super.didComplete(result);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _getAnimation(BuildContext context) {
    switch (type) {
      case AnimationType.LOADING:
        // return Center(child: RiveAnimation.asset('assets/animations/diamond-loader.riv', fit: BoxFit.contain));
        // return Center(child: RiveAnimation.asset('assets/animations/particle-loader.riv', fit: BoxFit.contain));
        // return Center(child: RiveAnimation.asset('assets/animations/loader3.riv', fit: BoxFit.contain));
        return Lottie.network(
          'https://assets10.lottiefiles.com/packages/lf20_t9gkkhz4.json',
        );
      case AnimationType.SEND:
        return Center(
          child: FlareActor(
            "legacy_assets/send_animation.flr",
            animation: "main",
            fit: BoxFit.contain,
            color: StateContainer.of(context).curTheme.primary,
          ),
        );
      case AnimationType.MANTA:
        return Center(
          child: FlareActor(
            "legacy_assets/manta_animation.flr",
            animation: "main",
            fit: BoxFit.contain,
          ),
        );
      case AnimationType.TRANSFER_SEARCHING_QR:
        return Stack(
          children: <Widget>[
            Center(
              child: FlareActor(
                "legacy_assets/searchseedqr_animation_qronly.flr",
                animation: "main",
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: FlareActor(
                "legacy_assets/searchseedqr_animation_glassonly.flr",
                animation: "main",
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: FlareActor(
                "legacy_assets/searchseedqr_animation_magnifyingglassonly.flr",
                animation: "main",
                fit: BoxFit.contain,
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        );
      case AnimationType.TRANSFER_SEARCHING_MANUAL:
        return Stack(
          children: <Widget>[
            Center(
              child: FlareActor(
                "legacy_assets/searchseedmanual_animation_seedonly.flr",
                animation: "main",
                fit: BoxFit.contain,
                color: StateContainer.of(context).curTheme.primary30,
              ),
            ),
            Center(
              child: FlareActor(
                "legacy_assets/searchseedmanual_animation_glassonly.flr",
                animation: "main",
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: FlareActor(
                "legacy_assets/searchseedmanual_animation_magnifyingglassonly.flr",
                animation: "main",
                fit: BoxFit.contain,
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        );
      case AnimationType.TRANSFER_TRANSFERRING:
        return Stack(
          children: <Widget>[
            FlareActor(
              "legacy_assets/transfer_animation_paperwalletonly.flr",
              animation: "main",
              fit: BoxFit.contain,
            ),
            FlareActor(
              "legacy_assets/transfer_animation_nautiluswalletonly.flr",
              animation: "main",
              fit: BoxFit.contain,
              color: StateContainer.of(context).curTheme.primary,
            ),
          ],
        );
      case AnimationType.GENERIC:
      default:
        return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(StateContainer.of(context).curTheme.primary60));
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    switch (type) {
      case AnimationType.TRANSFER_SEARCHING_QR:
        return Center(
          child: Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.15),
            width: MediaQuery.of(context).size.width / 1.1,
            height: MediaQuery.of(context).size.width / 1.1,
            child: _getAnimation(context),
          ),
        );
      case AnimationType.TRANSFER_SEARCHING_MANUAL:
        return Center(
          child: Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.15),
            width: MediaQuery.of(context).size.width / 1.1,
            height: MediaQuery.of(context).size.width / 1.1,
            child: _getAnimation(context),
          ),
        );
      case AnimationType.TRANSFER_TRANSFERRING:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: AlignmentDirectional(0, -0.5),
                width: MediaQuery.of(context).size.width / 1.4,
                height: MediaQuery.of(context).size.width / 1.4 / 2,
                child: _getAnimation(context),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, top: 20, bottom: MediaQuery.of(context).size.height * 0.15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(CaseChange.toUpperCase(AppLocalization.of(context).transferLoading, context), style: AppStyles.textStyleHeader2Colored(context)),
                    Container(
                      margin: EdgeInsets.only(bottom: 7),
                      width: 33.333,
                      height: 8.866,
                      child: FlareActor(
                        "legacy_assets/threedot_animation.flr",
                        animation: "main",
                        fit: BoxFit.contain,
                        color: StateContainer.of(context).curTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case AnimationType.MANTA:
        return Center(
          child: Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: _getAnimation(context),
          ),
        );
      case AnimationType.SEND:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: type == AnimationType.SEND ? MainAxisAlignment.end : MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: type == AnimationType.SEND ? EdgeInsets.only(bottom: 10.0, left: 90, right: 90) : EdgeInsets.zero,
              //Widgth/Height ratio is needed because BoxFit is not working as expected
              width: type == AnimationType.SEND ? double.infinity : 100,
              height: type == AnimationType.SEND ? MediaQuery.of(context).size.width : 100,
              child: _getAnimation(context),
            ),
          ],
        );
      case AnimationType.GENERIC:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: type == AnimationType.SEND ? MainAxisAlignment.end : MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: type == AnimationType.SEND ? EdgeInsets.only(bottom: 10.0, left: 90, right: 90) : EdgeInsets.zero,
              //Widgth/Height ratio is needed because BoxFit is not working as expected
              width: type == AnimationType.SEND ? double.infinity : 100,
              height: type == AnimationType.SEND ? MediaQuery.of(context).size.width : 100,
              child: _getAnimation(context),
            ),
          ],
        );
      default:
        return _getAnimation(context);
    }
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
