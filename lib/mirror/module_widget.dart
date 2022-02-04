import 'package:flutter/material.dart';
import 'package:magic_app/util/text_types.dart';

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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        print("Module ${module.name} clicked");
        selectedCallback(module.name);
      },
      child: Container(
        child: DefaultPlatformText(module.name),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
