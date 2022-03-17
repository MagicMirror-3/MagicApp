import 'package:flutter/material.dart';

class SafeMaterialArea extends StatelessWidget {
  const SafeMaterialArea({required this.child, Key? key}) : super(key: key);

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
