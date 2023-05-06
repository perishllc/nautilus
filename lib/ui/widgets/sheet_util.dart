import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/ui/util/routes.dart';

class Sheets {
  //App Ninty Height Sheet
  static Future<T?> showAppHeightNineSheet<T>(
      {required BuildContext context,
      required Widget widget,
      Color? color,
      double radius = 30.0,
      Color? barrier,
      int animationDurationMs = 250,
      bool removeUntilHome = false,
      bool closeOnTap = false,
      Function? onDisposed}) {
    assert(radius > 0.0);
    color ??= StateContainer.of(context).curTheme.backgroundDark;
    barrier ??= StateContainer.of(context).curTheme.barrier;
    final _AppHeightNineModalRoute<T> route = _AppHeightNineModalRoute<T>(
        builder: (BuildContext context) {
          return widget;
        },
        color: color,
        radius: radius,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrier: barrier,
        animationDurationMs: animationDurationMs,
        closeOnTap: closeOnTap,
        onDisposed: onDisposed);
    if (removeUntilHome) {
      return Navigator.pushAndRemoveUntil<T>(context, route, RouteUtils.withNameLike('/home'));
    }
    return Navigator.push<T>(context, route);
  }

  //App Height Eigth Sheet
  static Future<T?> showAppHeightEightSheet<T>({
    required BuildContext context,
    required Widget widget,
    Color? color,
    double radius = 30.0,
    Color? barrier,
    int animationDurationMs = 225,
  }) {
    assert(radius > 0.0);
    color ??= StateContainer.of(context).curTheme.backgroundDark;
    barrier ??= StateContainer.of(context).curTheme.barrier;
    return Navigator.push<T>(
        context,
        _AppHeightEightModalRoute<T>(
            builder: (BuildContext context) {
              return widget;
            },
            color: color,
            radius: radius,
            barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrier: barrier,
            animationDurationMs: animationDurationMs));
  }

  static Future<T?> showAppHeightFullSheet<T>(
      {required BuildContext context,
      required Widget widget,
      Color? color,
      double radius = 30.0,
      Color? barrier,
      int animationDurationMs = 250,
      bool removeUntilHome = false,
      bool closeOnTap = false,
      Function? onDisposed,
      bool allowSlide = false}) {
    assert(radius > 0.0);
    color ??= StateContainer.of(context).curTheme.backgroundDark;
    barrier ??= StateContainer.of(context).curTheme.barrier;
    final _AppHeightFullModalRoute<T> route = _AppHeightFullModalRoute<T>(
        builder: (BuildContext context) {
          return widget;
        },
        color: color,
        radius: radius,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrier: barrier,
        animationDurationMs: animationDurationMs,
        closeOnTap: closeOnTap,
        onDisposed: onDisposed,
        allowSlide: allowSlide);
    if (removeUntilHome) {
      return Navigator.pushAndRemoveUntil<T>(context, route, RouteUtils.withNameLike('/home'));
    }
    return Navigator.push<T>(context, route);
  }
}

class _AppHeightNineSheetLayout extends SingleChildLayoutDelegate {
  _AppHeightNineSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    if (constraints.maxHeight < 667)
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.95);
    if ((constraints.maxHeight / constraints.maxWidth > 2.1 && Platform.isAndroid) || constraints.maxHeight > 812)
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.8);
    else
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.9);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_AppHeightNineSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _AppHeightNineModalRoute<T> extends PopupRoute<T> {
  _AppHeightNineModalRoute(
      {this.builder,
      this.barrierLabel,
      this.color,
      this.radius,
      RouteSettings? settings,
      this.barrier,
      this.animationDurationMs,
      this.closeOnTap,
      this.onDisposed})
      : super(settings: settings);

  final WidgetBuilder? builder;
  final double? radius;
  final Color? color;
  final Color? barrier;
  final int? animationDurationMs;
  final bool? closeOnTap;
  final Function? onDisposed;

  @override
  Color? get barrierColor => barrier;

  @override
  bool get barrierDismissible => true;

  @override
  String? barrierLabel;

  @override
  void didComplete(T? result) {
    if (onDisposed != null) {
      onDisposed!();
    }
    super.didComplete(result);
  }

  AnimationController? _animationController;
  late CurvedAnimation appSheetAnimation;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = BottomSheet.createAnimationController(navigator!.overlay!);
    _animationController!.duration = Duration(milliseconds: animationDurationMs!);
    appSheetAnimation =
        CurvedAnimation(parent: _animationController!, curve: Curves.easeOut, reverseCurve: Curves.linear)
          ..addStatusListener((AnimationStatus animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              appSheetAnimation.curve = Curves.linear;
            }
          });
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: GestureDetector(
        onTap: () {
          if (closeOnTap!) {
            // Close when tapped anywhere
            Navigator.of(context).pop();
          }
        },
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: AnimatedBuilder(
            animation: appSheetAnimation,
            builder: (BuildContext context, Widget? child) => CustomSingleChildLayout(
              delegate: _AppHeightNineSheetLayout(appSheetAnimation.value),
              child: BottomSheet(
                animationController: _animationController,
                onClosing: () => Navigator.pop(context),
                backgroundColor: color,
                elevation: 0,
                builder: (BuildContext context) => Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius!),
                      topRight: Radius.circular(radius!),
                    ),
                  ),
                  child: Builder(builder: builder!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: animationDurationMs!);
}
//App Height Nine Sheet End

class _AppHeightEightSheetLayout extends SingleChildLayoutDelegate {
  _AppHeightEightSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    if (constraints.maxHeight < 667)
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.9);
    if (constraints.maxHeight / constraints.maxWidth > 2.1)
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.7);
    else
      return BoxConstraints(
          minWidth: constraints.maxWidth,
          maxWidth: constraints.maxWidth,
          minHeight: 0.0,
          maxHeight: constraints.maxHeight * 0.8);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_AppHeightEightSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _AppHeightEightModalRoute<T> extends PopupRoute<T> {
  _AppHeightEightModalRoute(
      {this.builder,
      this.barrierLabel,
      this.color,
      this.radius,
      RouteSettings? settings,
      this.barrier,
      this.animationDurationMs})
      : super(settings: settings);

  final WidgetBuilder? builder;
  final double? radius;
  final Color? color;
  final Color? barrier;
  final int? animationDurationMs;

  @override
  Color? get barrierColor => barrier;

  @override
  bool get barrierDismissible => true;

  @override
  String? barrierLabel;

  AnimationController? _animationController;
  late CurvedAnimation appSheetAnimation;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = BottomSheet.createAnimationController(navigator!.overlay!);
    _animationController!.duration = Duration(milliseconds: animationDurationMs!);
    appSheetAnimation =
        CurvedAnimation(parent: _animationController!, curve: Curves.easeOut, reverseCurve: Curves.linear)
          ..addStatusListener((AnimationStatus animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              appSheetAnimation.curve = Curves.linear;
            }
          });
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: AnimatedBuilder(
          animation: appSheetAnimation,
          builder: (BuildContext context, Widget? child) => CustomSingleChildLayout(
            delegate: _AppHeightEightSheetLayout(appSheetAnimation.value),
            child: BottomSheet(
              animationController: _animationController,
              onClosing: () => Navigator.pop(context),
              backgroundColor: color,
              elevation: 0,
              builder: (BuildContext context) => Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(radius!),
                    topRight: Radius.circular(radius!),
                  ),
                ),
                child: Builder(builder: builder!),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: animationDurationMs!);
}
//App HeightEight Sheet End

class _AppHeightFullSheetLayout extends SingleChildLayoutDelegate {
  _AppHeightFullSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_AppHeightFullSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _AppHeightFullModalRoute<T> extends PopupRoute<T> {
  _AppHeightFullModalRoute(
      {this.builder,
      this.barrierLabel,
      this.color,
      this.radius,
      RouteSettings? settings,
      this.barrier,
      this.animationDurationMs,
      this.closeOnTap,
      this.onDisposed,
      this.allowSlide = false})
      : super(settings: settings);

  final WidgetBuilder? builder;
  final double? radius;
  final Color? color;
  final Color? barrier;
  final int? animationDurationMs;
  final bool? closeOnTap;
  final Function? onDisposed;
  final bool allowSlide;

  @override
  Color? get barrierColor => barrier;

  @override
  bool get barrierDismissible => true;

  @override
  String? barrierLabel;

  @override
  void didComplete(T? result) {
    if (onDisposed != null) {
      onDisposed!();
    }
    super.didComplete(result);
  }

  AnimationController? _animationController;
  late CurvedAnimation appSheetAnimation;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = BottomSheet.createAnimationController(navigator!.overlay!);
    _animationController!.duration = Duration(milliseconds: animationDurationMs!);
    appSheetAnimation =
        CurvedAnimation(parent: _animationController!, curve: Curves.easeOut, reverseCurve: Curves.linear)
          ..addStatusListener((AnimationStatus animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              appSheetAnimation.curve = Curves.linear;
            }
          });
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    if (allowSlide) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: GestureDetector(
          onTap: () {
            if (closeOnTap!) {
              // Close when tapped anywhere
              Navigator.of(context).pop();
            }
          },
          child: AnimatedBuilder(
            animation: appSheetAnimation,
            builder: (BuildContext context, Widget? child) => CustomSingleChildLayout(
              delegate: _AppHeightFullSheetLayout(appSheetAnimation.value),
              child: BottomSheet(
                animationController: _animationController,
                onClosing: () => Navigator.pop(context),
                backgroundColor: color,
                elevation: 0,
                builder: (BuildContext context) => Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius!),
                      topRight: Radius.circular(radius!),
                    ),
                  ),
                  child: Builder(builder: builder!),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: GestureDetector(
        onTap: () {
          if (closeOnTap!) {
            // Close when tapped anywhere
            Navigator.of(context).pop();
          }
        },
        child: Builder(builder: builder!),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: animationDurationMs!);
}
//App Height Full Sheet End