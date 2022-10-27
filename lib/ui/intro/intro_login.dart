import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';

class IntroLoginPage extends StatefulWidget {
  const IntroLoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IntroLoginPageState createState() => _IntroLoginPageState();
}

class _IntroLoginPageState extends State<IntroLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final Magic magic = Magic.instance;

  Future<void> loginFunction({required String email}) async {
    try {
      final String key = await magic.auth.loginWithMagicLink(email: _emailController.text);
      skipIntro(key);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> skipIntro(String key) async {
    await sl.get<DBHelper>().dropAccounts();
    await sl.get<Vault>().setSeed(NanoSeeds.generateSeed());
    if (!mounted) return;
    // Update wallet
    final String seed = await StateContainer.of(context).getSeed();
    if (!mounted) return;
    await NanoUtil().loginAccount(seed, context);

    const String DEFAULT_PIN = "000000";

    await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
    await sl.get<Vault>().writePin(DEFAULT_PIN);
    final PriceConversion conversion = await sl.get<SharedPrefsUtil>().getPriceConversion();
    if (!mounted) return;
    StateContainer.of(context).requestSubscribe();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: conversion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter your email', border: OutlineInputBorder()),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      return null;
                    },
                    controller: _emailController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    // onPressed: () {
                    //   if (_formKey.currentState!.validate()) {
                    //     debugPrint('Email: ${_emailController.text}');
                    //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check you email')));
                    //   }
                    // },
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        loginFunction(
                          email: _emailController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check your email')));
                      }
                    },
                    child: const Text('Login'),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
