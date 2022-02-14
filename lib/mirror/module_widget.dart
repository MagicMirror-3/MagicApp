import 'package:flutter/material.dart';

import 'module.dart';

class ModuleWidget extends StatelessWidget {
  const ModuleWidget(
      {required this.module,
      required this.selectedCallback,
      this.isSelected = false,
      Key? key})
      : super(key: key);

  final Module module;
  final Function selectedCallback;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // Draggable and Drag Target
    return Listener(
      // behavior: HitTestBehavior.deferToChild,
      onPointerDown: (_) {
        print("Module ${module.name} clicked");
        selectedCallback(module.name);
      },
      // onTapCancel: () {
      //   print("Tap cancelled");
      // },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.redAccent,
          ),
        ),
        child: const Text("abc"),
      ),
    );
  }
}
