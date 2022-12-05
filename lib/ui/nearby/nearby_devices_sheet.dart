import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_nearby_messages_api/flutter_nearby_messages_api.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';

class NearbyDevicesSheet extends StatefulWidget {
  const NearbyDevicesSheet({Key? key}) : super(key: key);

  // final List<Account> accounts;

  NearbyDevicesSheetState createState() => NearbyDevicesSheetState();
}

class NearbyDevicesSheetState extends State<NearbyDevicesSheet> {
  final GlobalKey expandedKey = GlobalKey();
  // FlutterNearbyMessagesApi nearbyMessagesApi = FlutterNearbyMessagesApi();

  final ScrollController _scrollController = ScrollController();

  Future<bool> _onWillPop() async {
    // if (_accountModifiedSub != null) {
    //   _accountModifiedSub!.cancel();
    // }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    initPlatformState();
  }

  @override
  Future<void> dispose() async {
    _destroyBus();
    super.dispose();
    // // unPublish
    // await nearbyMessagesApi.unPublish();
    // // backgroundUnsubscribe
    // await nearbyMessagesApi.backgroundUnsubscribe();
  }

  void _registerBus() {}

  void _destroyBus() {
    // if (_accountModifiedSub != null) {
    //   _accountModifiedSub!.cancel();
    // }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // // For iOS
    // await nearbyMessagesApi.setAPIKey(dotenv.env["MESSAGES_API_KEY"]!);

    // nearbyMessagesApi.onFound = (message) {
    //   print('~~~onFound : $message');
    // };

    // nearbyMessagesApi.onLost = (message) {
    //   print('~~~onLost : $message');
    // };

    // nearbyMessagesApi.statusHandler = (status) {
    //   print('~~~statusHandler : $status');
    // };

    // nearbyMessagesApi.setPermissionAlert('Your title', 'Your message', 'Deny', 'Grant');

    // nearbyMessagesApi.permissionHandler = (status) {
    //   print(status);
    // };

    // nearbyMessagesApi.bluetoothPowerErrorHandler = (args) {
    //   print('~~~ bluetoothPowerErrorHandler');
    // };

    // nearbyMessagesApi.bluetoothPermissionErrorHandler = (args) {
    //   print('~~~ bluetoothPermissionErrorHandler');
    // };

    // nearbyMessagesApi.microphonePermissionErrorHandler = (args) {
    //   print('~~~ microphonePermissionErrorHandler');
    // };

    // // Do not use it if you have not learned it carefully
    // nearbyMessagesApi.setNearbyAccessPermission(true);
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
              //A container for the header
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                child: Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text20,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          AutoSizeText(
                            CaseChange.toUpperCase(Z.of(context).accounts, context),
                            style: AppStyles.textStyleHeader(context),
                            maxLines: 1,
                            stepGranularity: 0.1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text: "(",
                              style: TextStyle(
                                color: StateContainer.of(context).curTheme.primary60,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w100,
                                fontFamily: "NunitoSans",
                              ),
                            ),
                            TextSpan(
                              text: "test",
                              style: TextStyle(
                                color: StateContainer.of(context).curTheme.primary60,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: "NunitoSans",
                              ),
                            ),
                            TextSpan(
                              text: (StateContainer.of(context).nyanoMode) ? (" nyano)") : (" NANO)"),
                              style: TextStyle(
                                color: StateContainer.of(context).curTheme.primary60,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w100,
                                fontFamily: "NunitoSans",
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Column(children: [
              //   TextButton(
              //       onPressed: () async {
              //         var rng = Random();
              //         await nearbyMessagesApi.publish('Hello world!: rng: ' + rng.nextInt(10000).toString());
              //       },
              //       child: const Text("publish")),
              //   TextButton(
              //       onPressed: () async {
              //         await nearbyMessagesApi.publish('Something else!');
              //       },
              //       child: const Text("publish2")),
              //   TextButton(
              //       onPressed: () async {
              //         await nearbyMessagesApi.unPublish();
              //       },
              //       child: const Text("unPublish")),
              //   TextButton(
              //       onPressed: () async {
              //         await nearbyMessagesApi.backgroundSubscribe();
              //       },
              //       child: const Text("backgroundSubscribe")),
              //   TextButton(
              //       onPressed: () async {
              //         await nearbyMessagesApi.backgroundUnsubscribe();
              //       },
              //       child: const Text("unSubscribe"))
              // ]),
              // //A list containing accounts
              // Expanded(
              //     key: expandedKey,
              //     child: Stack(
              //       children: <Widget>[
              //         if (widget.accounts == null)
              //           const Center(
              //             child: Text("Loading"),
              //           )
              //         else
              //           ListView.builder(
              //             padding: const EdgeInsets.symmetric(vertical: 20),
              //             itemCount: widget.accounts.length,
              //             controller: _scrollController,
              //             itemBuilder: (BuildContext context, int index) {
              //               return _buildAccountListItem(context, widget.accounts[index], setState);
              //             },
              //           ),
              //         //List Top Gradient
              //         Align(
              //           alignment: Alignment.topCenter,
              //           child: Container(
              //             height: 20.0,
              //             width: double.infinity,
              //             decoration: BoxDecoration(
              //               gradient: LinearGradient(
              //                 colors: [
              //                   StateContainer.of(context).curTheme.backgroundDark00!,
              //                   StateContainer.of(context).curTheme.backgroundDark!,
              //                 ],
              //                 begin: const AlignmentDirectional(0.5, 1.0),
              //                 end: const AlignmentDirectional(0.5, -1.0),
              //               ),
              //             ),
              //           ),
              //         ),
              //         // List Bottom Gradient
              //         Align(
              //           alignment: Alignment.bottomCenter,
              //           child: Container(
              //             height: 20.0,
              //             width: double.infinity,
              //             decoration: BoxDecoration(
              //               gradient: LinearGradient(
              //                 colors: [StateContainer.of(context).curTheme.backgroundDark!, StateContainer.of(context).curTheme.backgroundDark00!],
              //                 begin: const AlignmentDirectional(0.5, 1.0),
              //                 end: const AlignmentDirectional(0.5, -1.0),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     )),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY_OUTLINE,
                    Z.of(context).nearby,
                    Dimens.BUTTON_BOTTOM_DIMENS,
                    onPressed: () async {},
                  ),
                ],
              ),
              //A row with Close button
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
}
