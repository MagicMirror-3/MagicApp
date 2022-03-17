import 'package:flutter/material.dart';

/// Wraps the given widget in a [SafeArea] and a transparent [Material] widget
class SafeMaterialArea extends StatelessWidget {
  const SafeMaterialArea({required this.child, Key? key}) : super(key: key);

  /// The [Widget] to wrap
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}
