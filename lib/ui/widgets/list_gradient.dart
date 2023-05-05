import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ListGradient extends StatefulWidget {
  ListGradient({required this.height, this.top, this.begin, this.end, this.alignment, required this.color});

  final double height;
  bool? top;
  AlignmentGeometry? begin;
  AlignmentGeometry? end;
  AlignmentGeometry? alignment;
  // final List<Color> colors;
  final Color color;

  @override
  State<StatefulWidget> createState() {
    return ListGradientState();
  }
}

class ListGradientState extends State<ListGradient> {
  @override
  Widget build(BuildContext context) {
    late AlignmentGeometry begin;
    late AlignmentGeometry end;
    late AlignmentGeometry alignment;

    if (widget.top == true) {
      begin = AlignmentDirectional.topCenter;
      end = AlignmentDirectional.bottomCenter;
      alignment = AlignmentDirectional.topCenter;
    } else if (widget.top == false) {
      begin = AlignmentDirectional.bottomCenter;
      end = AlignmentDirectional.topCenter;
      alignment = AlignmentDirectional.bottomCenter;
    } else {
      begin = widget.begin!;
      end = widget.end!;
      alignment = widget.alignment!;
    }

    final List<Color> colors = <Color>[widget.color, widget.color.withOpacity(0)];
    Offset offset = Offset.zero;
    // fix for wierd transparent sliver bug with gradients:
    // ignore: use_if_null_to_convert_nulls_to_bools
    if (widget.top == true) {
      offset = const Offset(0, -1);
    } else if (widget.top == false) {
      offset = const Offset(0, 1);
    }
    return Transform.translate(
      offset: offset,
      child: Align(
        alignment: alignment,
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // colors: <Color>[
              //   StateContainer.of(context).curTheme.background00!,
              //   StateContainer.of(context).curTheme.background!
              // ],
              colors: colors,
              // begin: const AlignmentDirectional(0.5, 1.0),
              // end: const AlignmentDirectional(0.5, -1.0),
              begin: begin,
              end: end,
            ),
          ),
        ),
      ),
    );
  }
}
