import 'package:flutter/material.dart';
import 'package:magic_app/util/text_types.dart';

import 'mirror_data.dart';

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
    return Listener(
      onPointerDown: (_) {
        print("Module ${module.name} clicked");
        selectedCallback(module.name);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.redAccent,
          ),
        ),
        child: DefaultPlatformText(module.name),
      ),
    );
  }
}
