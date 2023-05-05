import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomStack extends Stack {
  CustomStack({children}) : super(children: children as List<Widget>, alignment: Alignment.topRight);

  @override
  CustomRenderStack createRenderObject(BuildContext context) {
    return CustomRenderStack(
      alignment: alignment,
      // alignment: Alignment.topRight,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
    );
  }
}

class CustomRenderStack extends RenderStack {
  CustomRenderStack({required AlignmentGeometry alignment, required TextDirection textDirection, required StackFit fit})
      : super(
            alignment: alignment,
            textDirection: textDirection,
            fit: fit);

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position = Offset.zero}) {
    bool stackHit = false;

    final List<RenderBox> children = getChildrenAsList();

    for (final RenderBox child in children) {
      final StackParentData childParentData = child.parentData! as StackParentData;

      final bool childHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );

      if (childHit) stackHit = true;
    }

    return stackHit;
  }
}