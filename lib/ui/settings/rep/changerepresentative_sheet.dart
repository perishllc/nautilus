import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/authentication_method.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/model/wallet.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/model/response/process_response.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/routes.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';
import 'package:wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/security.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/biometrics.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/hapticutil.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/ninja/ninja_node.dart';
import 'package:wallet_flutter/util/numberutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

import 'changerepresentativemanualentry_sheet.dart';

class AppChangeRepresentativeSheet extends StatefulWidget {
  const AppChangeRepresentativeSheet() : super();

  @override
  // ignore: library_private_types_in_public_api
  _AppChangeRepresentativeSheetState createState() => _AppChangeRepresentativeSheetState();
}

class _AppChangeRepresentativeSheetState extends State<AppChangeRepresentativeSheet> {
  // State variables
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  StreamSubscription<AuthenticatedEvent>? _authSub;

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton().registerTo<AuthenticatedEvent>().listen((event) {
      if (event.authType == AUTH_EVENT_TYPE.CHANGE) {
        doChange();
      }
    });
  }

  void _destroyBus() {
    if (_authSub != null) {
      _authSub!.cancel();
    }
  }

  Future<bool> _onWillPop() async {
    _destroyBus();
    return true;
  }

  List<Widget> _getRepresentativeWidgets(BuildContext context, List<NinjaNode>? list) {
    if (list == null) {
      return [];
    }
    final List<Widget> ret = [];
    for (final NinjaNode node in list) {
      if (node.alias != null && node.alias!.trim().isNotEmpty) {
        ret.add(_buildSingleRepresentative(
          node,
          context,
        ));
      }
    }
    return ret;
  }

  Widget _buildRepresenativeDialog(BuildContext context) {
    return AppSimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            Z.of(context).representatives,
            style: AppStyles.textStyleDialogHeader(context),
          ),
        ),
        children: _getRepresentativeWidgets(context, StateContainer.of(context).nanoNinjaNodes));
  }

  String _sanitizeAlias(String? alias) {
    if (alias != null) {
      return alias.replaceAll(RegExp(r'[^a-zA-Z_.!?_;:-]'), '');
    }
    return '';
  }

  bool _animationOpen = false;
  NinjaNode _rep = NinjaNode(account: AppWallet.nautilusRepresentative);

  Widget _buildSingleRepresentative(NinjaNode rep, BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: StateContainer.of(context).curTheme.text15, padding: EdgeInsets.zero,
            // highlightColor: StateContainer.of(context).curTheme.text15,
            // splashColor: StateContainer.of(context).curTheme.text15,
          ),
          onPressed: () async {
            if (!NanoAccounts.isValid(NonTranslatable.accountType, rep.account!)) {
              return;
            }
            _rep = rep;
            // Authenticate
            final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
            final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
            // if (!mounted) return;
            if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
              try {
                final bool authenticated = await sl
                    .get<BiometricUtil>()
                    .authenticateWithBiometrics(context, Z.of(context).changeRepAuthenticate);
                if (authenticated) {
                  sl.get<HapticUtil>().fingerprintSucess();
                  EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.CHANGE));
                }
              } catch (e) {
                await authenticateWithPin(rep.account, context);
              }
            } else if (authMethod.method == AuthMethod.PIN) {
              await authenticateWithPin(rep.account, context);
            } else {
              EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.CHANGE));
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 24),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _sanitizeAlias(rep.alias),
                        style: TextStyle(
                            color: StateContainer.of(context).curTheme.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0,
                            fontFamily: 'Nunito Sans'),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 7),
                        child: RichText(
                          text: TextSpan(
                            text: "",
                            children: [
                              TextSpan(
                                text: "${Z.of(context).votingWeight}: ",
                                style: TextStyle(
                                  color: StateContainer.of(context).curTheme.text,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 14.0,
                                  fontFamily: 'Nunito Sans',
                                ),
                              ),
                              TextSpan(
                                text: NumberUtil.getPercentOfTotalSupply(rep.votingWeight!),
                                style: TextStyle(
                                    color: StateContainer.of(context).curTheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                    fontFamily: 'Nunito Sans'),
                              ),
                              TextSpan(
                                text: "%",
                                style: TextStyle(
                                    color: StateContainer.of(context).curTheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                    fontFamily: 'Nunito Sans'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        child: RichText(
                          text: TextSpan(
                            text: '',
                            children: [
                              TextSpan(
                                text: "${Z.of(context).uptime}: ",
                                style: TextStyle(
                                    color: StateContainer.of(context).curTheme.text,
                                    fontWeight: FontWeight.w100,
                                    fontSize: 14.0,
                                    fontFamily: 'Nunito Sans'),
                              ),
                              TextSpan(
                                text: rep.uptime!.toStringAsFixed(2),
                                style: TextStyle(
                                    color: StateContainer.of(context).curTheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                    fontFamily: 'Nunito Sans'),
                              ),
                              TextSpan(
                                text: "%",
                                style: TextStyle(
                                    color: StateContainer.of(context).curTheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                    fontFamily: 'Nunito Sans'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(end: 24, start: 14),
                  child: Stack(
                    children: <Widget>[
                      Icon(
                        AppIcons.score,
                        color: StateContainer.of(context).curTheme.primary,
                        size: 50,
                      ),
                      Container(
                        alignment: const AlignmentDirectional(-0.03, 0.03),
                        width: 50,
                        height: 50,
                        child: Text(
                          (rep.score).toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: StateContainer.of(context).curTheme.backgroundDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Nunito Sans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> doChange() async {
    if (_animationOpen) {
      return; // not sure why it's called more than once
    }
    _animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.CHANGE_REP, onPoppedCallback: () => _animationOpen = false);
    // If account isnt open, just store the account in sharedprefs
    if (StateContainer.of(context).wallet!.openBlock == null) {
      await sl.get<SharedPrefsUtil>().setRepresentative(_rep.account);
      StateContainer.of(context).wallet!.representative = _rep.account!;
      UIUtil.showSnackbar(Z.of(context).changeRepSucces, context);
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
    } else if (StateContainer.of(context).wallet!.representative == _rep.account) {
      // sleep for 2 seconds:
      await Future<dynamic>.delayed(const Duration(seconds: 2));
      // representative is the same as the current one:
      if (_animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(Z.of(context).changeRepSame, context);
    } else {
      try {
        final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
        final String privKey = await NanoUtil.uniSeedToPrivate(await StateContainer.of(context).getSeed(),
            StateContainer.of(context).selectedAccount!.index!, derivationMethod);
        final ProcessResponse resp = await sl.get<AccountService>().requestChange(
            StateContainer.of(context).wallet!.address,
            _rep.account,
            StateContainer.of(context).wallet!.frontier,
            StateContainer.of(context).wallet!.accountBalance.toString(),
            privKey);
        StateContainer.of(context).wallet!.representative = _rep.account!;
        StateContainer.of(context).wallet!.frontier = resp.hash;
        UIUtil.showSnackbar(Z.of(context).changeRepSucces, context);
        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      } catch (e) {
        sl.get<Logger>().e("Failed to change", e);
        if (_animationOpen) {
          Navigator.of(context).pop();
        }
        UIUtil.showSnackbar(Z.of(context).sendError, context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return WillPopScope(
          onWillPop: _onWillPop,
          child: SafeArea(
              minimum: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.035,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    //A container for the header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 60, width: 60),
                        //Container for the header
                        Column(
                          children: <Widget>[
                            Handlebars.horizontal(context),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                              child: AutoSizeText(
                                CaseChange.toUpperCase(Z.of(context).changeRepAuthenticate, context),
                                style: AppStyles.textStyleHeader(context),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                stepGranularity: 0.1,
                              ),
                            ),
                          ],
                        ),
                        //A container for the info button
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsetsDirectional.only(top: 10.0, end: 10.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: StateContainer.of(context).curTheme.text15,
                              backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                              disabledForegroundColor: StateContainer.of(context).curTheme.text15?.withOpacity(0.38),
                              padding: const EdgeInsets.all(13.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                              tapTargetSize: MaterialTapTargetSize.padded,
                            ),
                            onPressed: () {
                              AppDialogs.showInfoDialog(context, Z.of(context).repInfoHeader, Z.of(context).repInfo);
                            },
                            child: Icon(AppIcons.info, size: 24, color: StateContainer.of(context).curTheme.text),
                          ),
                        ),
                      ],
                    ),

                    //A expanded section for current representative and new representative fields
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            top: smallScreen(context) ? 20 : 35, bottom: smallScreen(context) ? 20 : 35),
                        child: Stack(children: <Widget>[
                          Container(
                            color: Colors.transparent,
                            constraints: const BoxConstraints.expand(),
                            child: const SizedBox.expand(),
                          ),
                          Column(
                            children: <Widget>[
                              // Currently represented by text
                              Container(
                                  margin: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width * 0.105,
                                      right: MediaQuery.of(context).size.width * 0.105),
                                  child: Text(
                                    Z.of(context).currentlyRepresented,
                                    style: AppStyles.textStyleParagraph(context),
                                  )),
                              // Current representative
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: StateContainer.of(context).wallet!.representative));
                                  setState(() {
                                    _addressCopied = true;
                                  });
                                  if (_addressCopiedTimer != null) {
                                    _addressCopiedTimer!.cancel();
                                  }
                                  _addressCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                                    setState(() {
                                      _addressCopied = false;
                                    });
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width * 0.105,
                                      right: MediaQuery.of(context).size.width * 0.105,
                                      top: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context).curTheme.backgroundDarkest,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: UIUtil.threeLineAddressText(
                                      context, StateContainer.of(context).wallet!.representative,
                                      type: _addressCopied
                                          ? ThreeLineAddressTextType.SUCCESS_FULL
                                          : ThreeLineAddressTextType.PRIMARY),
                                ),
                              ),
                              // Address Copied text container
                              Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: Text(_addressCopied ? Z.of(context).addressCopied : "",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: StateContainer.of(context).curTheme.success,
                                      fontFamily: "NunitoSans",
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),

                    //A row with change and close button
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            AppButton.buildAppButton(
                              context,
                              AppButtonType.PRIMARY,
                              Z.of(context).useAppRep.replaceAll("%1", NonTranslatable.appName),
                              Dimens.BUTTON_TOP_DIMENS,
                              onPressed: () async {
                                if (!NanoAccounts.isValid(NonTranslatable.accountType, AppWallet.nautilusRepresentative)) {
                                  return;
                                }
                                _rep = NinjaNode(account: AppWallet.nautilusRepresentative);
                                // Authenticate
                                final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                                final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
                                if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                                  try {
                                    final bool authenticated = await sl
                                        .get<BiometricUtil>()
                                        .authenticateWithBiometrics(context, Z.of(context).changeRepAuthenticate);
                                    if (authenticated) {
                                      sl.get<HapticUtil>().fingerprintSucess();
                                      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.CHANGE));
                                    }
                                  } catch (e) {
                                    await authenticateWithPin(AppWallet.nautilusRepresentative, context);
                                  }
                                } else if (authMethod.method == AuthMethod.PIN) {
                                  await authenticateWithPin(AppWallet.nautilusRepresentative, context);
                                } else {
                                  EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.CHANGE));
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            AppButton.buildAppButton(
                              context,
                              AppButtonType.PRIMARY_OUTLINE,
                              Z.of(context).pickFromList,
                              Dimens.BUTTON_BOTTOM_DIMENS,
                              disabled: StateContainer.of(context).nanoNinjaNodes == null,
                              onPressed: () {
                                showDialog(
                                    barrierColor: StateContainer.of(context).curTheme.barrier,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return _buildRepresenativeDialog(context);
                                    });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            AppButton.buildAppButton(
                              context,
                              AppButtonType.PRIMARY_OUTLINE,
                              Z.of(context).manualEntry,
                              Dimens.BUTTON_BOTTOM_DIMENS,
                              onPressed: () {
                                Sheets.showAppHeightEightSheet(
                                    context: context, widget: ChangeRepManualSheet(TextEditingController()));
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )));
    });
  }

  Future<void> authenticateWithPin(String? rep, BuildContext context) async {
    // PIN Authentication
    final String? expectedPin = await sl.get<Vault>().getPin();
    final String? plausiblePin = await sl.get<Vault>().getPlausiblePin();
    final bool? auth = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        plausiblePin: plausiblePin,
        description: Z.of(context).pinRepChange,
      );
    }));
    if (auth != null && auth) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.CHANGE));
    }
  }
}
