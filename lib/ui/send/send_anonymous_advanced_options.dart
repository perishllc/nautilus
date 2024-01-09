import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';

class AnonymousAdvancedOptions extends StatefulWidget {
  const AnonymousAdvancedOptions({
    required this.onSendsChanged,
    required this.onDelaysChanged,
  });
  final Function(List<Map<String, dynamic>>) onSendsChanged;
  final Function(bool) onDelaysChanged;

  @override
  AnonymousAdvancedOptionsState createState() => AnonymousAdvancedOptionsState();
}

class AnonymousAdvancedOptionsState extends State<AnonymousAdvancedOptions> {
  bool _delays = false;

  List<Map<String, dynamic>> sends = [];

  List<int> _numbersThatAddTo100(int n) {
    if (n <= 0) return [];

    final Random random = Random();
    final List<int> points = List.generate(n - 1, (_) => random.nextInt(101));

    points.add(0);
    points.add(100);
    points.sort();

    List<int> randomNumbers = List<int>.generate(n, (int i) => points[i + 1] - points[i]);
    return randomNumbers;
  }

  @override
  void initState() {
    super.initState();

    List<int> percentsThatAddTo100 = _numbersThatAddTo100(2);
    sends[0]['percent'] = percentsThatAddTo100[0];
    sends[1]['percent'] = percentsThatAddTo100[1];

    for (Map<String, dynamic> send in sends) {
      send['percentController'].text = send['percent'].toString();
    }
  }

  @override
  void dispose() {
    for (Map<String, dynamic> send in sends) {
      send['percentController'].dispose();
    }
    super.dispose();
  }

  Widget _buildSendInput(int index) {
    Map<String, dynamic> send = sends[index];
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: send['percentController'] as TextEditingController,
            decoration: InputDecoration(
              suffixText: '%',
              suffixStyle: AppStyles.textStyleSettingItemSubheader(context),
            ),
            style: AppStyles.textStyleAddressPrimary(context),
            keyboardType: TextInputType.number,
            onChanged: (String value) {
              int? newPercent = int.tryParse(value);
              if (newPercent != null) {
                // Calculate new total percentage
                final int newTotal = sends.fold(
                    0,
                    (int sum, Map<String, dynamic> s) =>
                        sum + (s == sends[index] ? newPercent : s['percent'] as int));
                if (newTotal <= 100) {
                  setState(() {
                    send['percent'] = newPercent;
                  });
                  widget.onSendsChanged(sends);
                } else {
                  setState(() {
                    final int num = 100 - (newTotal - newPercent);
                    sends[index]['percent'] = num;
                    sends[index]['percentController'].text = num.toString();
                  });

                  // Revert change or handle error: show a Snackbar, alert dialog, etc.
                  UIUtil.showSnackbar('Total percentage cannot exceed 100%', context);
                  // Optionally, revert to the previous value if the new total exceeds 100
                  setState(() {});
                }
              }
              widget.onSendsChanged(sends);
            },
          ),
        ),
        if (_delays) ...[
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextFormField(
                initialValue: sends[index]['seconds'].toString(),
                decoration: InputDecoration(
                  suffixText: 'seconds',
                  suffixStyle: AppStyles.textStyleSettingItemSubheader(context),
                ),
                style: AppStyles.textStyleAddressPrimary(context),
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  int? newSeconds = int.tryParse(value);
                  if (newSeconds != null) {
                    setState(() {
                      send['seconds'] = newSeconds;
                    });
                    widget.onSendsChanged(sends);
                  }
                }),
          ),
        ]
      ],
    );
  }

  void _addSend() {
    setState(() {
      sends.add({'percent': 0, 'seconds': 0, 'percentController': TextEditingController()});
      List<int> percentsThatAddTo100 = _numbersThatAddTo100(sends.length);
      for (int i = 0; i < sends.length; i++) {
        sends[i]['percent'] = percentsThatAddTo100[i];
        sends[i]['percentController'].text = percentsThatAddTo100[i].toString();
      }
      widget.onSendsChanged(sends);
    });
  }

  void _removeSend() {
    setState(() {
      sends.removeLast();
      List<int> percentsThatAddTo100 = _numbersThatAddTo100(sends.length);
      for (int i = 0; i < sends.length; i++) {
        sends[i]['percent'] = percentsThatAddTo100[i];
        sends[i]['percentController'].text = percentsThatAddTo100[i].toString();
      }
      widget.onSendsChanged(sends);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Checkbox(
                    value: _delays,
                    activeColor: StateContainer.of(context).curTheme.primary,
                    onChanged: (bool? value) {
                      if (value == null) return;
                      setState(() {
                        _delays = value;
                        widget.onDelaysChanged(_delays);
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _delays = !_delays;
                        widget.onDelaysChanged(_delays);
                      });
                    },
                    child: Text(
                      Z.current.enableDelays,
                      style: AppStyles.textStyleParagraph(context),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: StateContainer.of(context).curTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS)),
                    onPressed: () {
                      _removeSend();
                    },
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 4),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: StateContainer.of(context).curTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS)),
                    onPressed: () {
                      _addSend();
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          ...List<Widget>.generate(sends.length, (int index) => _buildSendInput(index)),
        ],
      ),
    );
  }
}
