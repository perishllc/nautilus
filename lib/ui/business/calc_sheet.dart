import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:quiver/strings.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/receive/receive_show_qr.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/numberutil.dart';

class CalcSheet extends StatefulWidget {
  const CalcSheet({required this.localCurrency, this.address, this.qrWidget, this.amountRaw}) : super();

  final AvailableCurrency localCurrency;
  final Widget? qrWidget;
  final String? address;
  final String? amountRaw;

  @override
  CalcSheetState createState() => CalcSheetState();
}

// creating Stateless Widget for buttons
class MyButton extends StatelessWidget {
  // declaring variables
  final Color color;
  final Color textColor;
  final String buttonText;
  final void Function()? onTapped;

  MyButton({this.color = Colors.black, this.textColor = Colors.white, required this.buttonText, this.onTapped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Padding(
        padding: const EdgeInsets.all(0.2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 50,
            height: 50,
            // padding: EdgeInsets.all(2),
            color: StateContainer.of(context).curTheme.backgroundDarkest,
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                  color: StateContainer.of(context).curTheme.text,
                  fontSize: AppFontSizes.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CalcSheetState extends State<CalcSheet> {
  final FocusNode _amountFocusNode = FocusNode();
  final TextEditingController _amountController = TextEditingController();

  String userInput = "";
  String answer = "";

  late NumberFormat _localCurrencyFormat;

  // Array of button
  final List<String> buttons = [
    'C',
    '+/-',
    '%',
    'DEL',
    '7',
    '8',
    '9',
    '/',
    '4',
    '5',
    '6',
    'x',
    '1',
    '2',
    '3',
    '-',
    '0',
    '.',
    '=',
    '+',
  ];

  @override
  void initState() {
    super.initState();

    // On amount focus change
    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
      } else {}
    });

    // Set initial currency format
    _localCurrencyFormat = NumberFormat.currency(
      locale: widget.localCurrency.getLocale().toString(),
      symbol: widget.localCurrency.getCurrencySymbol(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
      child: Column(
        children: <Widget>[
          Center(
            child: Handlebars.horizontal(context),
          ),
          Expanded(
            child: Container(
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.centerRight,
                  child: Text(
                    userInput,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  alignment: Alignment.centerRight,
                  child: Text(
                    answer,
                    style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              ]),
            ),
          ),
          Expanded(
            child: Container(
              width: 300,
              height: 600,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButton(
                          buttonText: "C",
                          onTapped: () {
                            setState(() {
                              userInput = "";
                              answer = "";
                            });
                          }),
                      MyButton(
                          buttonText: "+/-",
                          onTapped: () {
                            setState(() {
                              // userInput = userInput + "-";
                            });
                          }),
                      MyButton(
                          buttonText: "%",
                          onTapped: () {
                            setState(() {
                              userInput += " % ";
                            });
                          }),
                      MyButton(
                          buttonText: "DEL",
                          onTapped: () {
                            setState(() {
                              userInput = userInput.substring(0, userInput.length - 1);
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButton(
                          buttonText: "7",
                          onTapped: () {
                            setState(() {
                              userInput += "7";
                            });
                          }),
                      MyButton(
                          buttonText: "8",
                          onTapped: () {
                            setState(() {
                              userInput += "8";
                            });
                          }),
                      MyButton(
                          buttonText: "9",
                          onTapped: () {
                            setState(() {
                              userInput += "9";
                            });
                          }),
                      MyButton(
                        buttonText: "/",
                        onTapped: () {
                          setState(() {
                            userInput += " / ";
                          });
                        },
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButton(
                          buttonText: "4",
                          onTapped: () {
                            setState(() {
                              userInput += "4";
                            });
                          }),
                      MyButton(
                          buttonText: "5",
                          onTapped: () {
                            setState(() {
                              userInput += "5";
                            });
                          }),
                      MyButton(
                          buttonText: "6",
                          onTapped: () {
                            setState(() {
                              userInput += "6";
                            });
                          }),
                      MyButton(
                        buttonText: "X",
                        onTapped: () {
                          setState(() {
                            userInput += " x ";
                          });
                        },
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButton(
                        buttonText: "1",
                        onTapped: () {
                          setState(() {
                            userInput += "1";
                          });
                        },
                      ),
                      MyButton(
                        buttonText: "2",
                        onTapped: () {
                          setState(() {
                            userInput += "2";
                          });
                        },
                      ),
                      MyButton(
                        buttonText: "3",
                        onTapped: () {
                          setState(() {
                            userInput += "3";
                          });
                        },
                      ),
                      MyButton(
                        buttonText: "-",
                        onTapped: () {
                          setState(() {
                            userInput += " - ";
                          });
                        },
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButton(
                        buttonText: ".",
                        onTapped: () => {
                          setState(() {
                            userInput += ".";
                          })
                        },
                      ),
                      MyButton(buttonText: "0"),
                      MyButton(
                        buttonText: "=",
                        onTapped: () {
                          setState(() {
                            equalPressed();
                          });
                        },
                      ),
                      MyButton(
                        buttonText: "+",
                        onTapped: () {
                          setState(() {
                            userInput += " + ";
                          });
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY,
                    "Checkout",
                    Dimens.BUTTON_TOP_DIMENS,
                    onPressed: () async {
                      bool _localCurrencyMode = false;

                      final String formattedAmount = sanitizedAmount(_localCurrencyFormat, answer);
                      String amountRaw;
                      if (answer.isEmpty || answer == "0") {
                        amountRaw = "0";
                      } else {
                        if (_localCurrencyMode) {
                          amountRaw = NumberUtil.getAmountAsRaw(sanitizedAmount(
                              _localCurrencyFormat,
                              convertLocalCurrencyToLocalizedCrypto(
                                  context, _localCurrencyFormat, _amountController.text)));
                        } else {
                          if (!mounted) return;
                          amountRaw = getThemeAwareAmountAsRaw(context, formattedAmount);
                        }
                      }

                      // getThemeAwareAmountAsRaw(context, amount)

                      Sheets.showAppHeightEightSheet(
                        context: context,
                        widget: ReceiveShowQRSheet(
                          localCurrency: widget.localCurrency,
                          address: widget.address,
                          qrWidget: widget.qrWidget,
                          amountRaw: amountRaw,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

// function to calculate the input operation
  void equalPressed() {
    String finaluserinput = userInput;
    finaluserinput = userInput.replaceAll('x', '*');

    Parser p = Parser();
    Expression exp = p.parse(finaluserinput);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm) as double;
    answer = eval.toString();
  }
}
