import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/util/user_data_util.dart';

class BeforeScanScreen extends StatefulWidget {
  @override
  _BeforeScanScreenState createState() => _BeforeScanScreenState();
}

class _BeforeScanScreenState extends State<BeforeScanScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () async {
      dynamic scanResult = await UserDataUtil.getQRData(DataType.DATA, context);
      Navigator.pop(context, scanResult);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Hero(
        tag: 'scanButton',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
          ),
          child: const Icon(
            AppIcons.scan,
            size: 50,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
