import 'package:flutter/material.dart';

/// Keeps a Dart List in sync with an AnimatedList.
///
/// This class only exposes as much of the Dart List API as is needed by the
/// sample app. More list methods are easily added, however methods that mutate the
/// list must make the same changes to the animated list in terms of
/// [AnimatedListState.insertItem] and [AnimatedList.removeItem].
class ListModel<E> {
  ListModel({
    required this.listKey,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final List<E> _items;

  List<E> get items => _items;

  AnimatedListState? get _animatedList => listKey.currentState;

  final INSERT_DURATION = Duration(milliseconds: 300);
  final REMOVE_DURATION = Duration(milliseconds: 300);

  void insertAtTop(E item, {bool instant = false}) {
    insertAt(item, 0, instant: instant);
    // if (listKey.currentState != null) {
    //   _items.insert(0, item);
    //   Duration duration = instant ? Duration(milliseconds: 0) : INSERT_DURATION;
    //   _animatedList.insertItem(0, duration: duration);
    // }
  }

  void insertAt(E item, int index, {bool instant = false}) {
    if (listKey.currentState != null) {
      _items.insert(index, item);
      Duration duration = instant ? Duration(milliseconds: 0) : INSERT_DURATION;
      _animatedList!.insertItem(index, duration: duration);
    }
  }

  void removeAt(int index, var builder, {bool instant = false}) {
    if (listKey.currentState != null) {
      _items.removeAt(index);
      Duration duration = instant ? Duration(milliseconds: 0) : REMOVE_DURATION;
      _animatedList!.removeItem(index, (BuildContext context, Animation<double> animation) => builder(context, index, animation) as Widget, duration: duration);
    }
  }

  void empty() {
    // for (int i = _items.length; i < _items.length; i++) {
    //   _animatedList.removeItem(i, (context, animation) => null);
    // }
    // _items.clear();
    // _animatedList.
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
