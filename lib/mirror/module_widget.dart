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
  final Function(String, BuildContext) selectedCallback;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => selectedCallback(module.name, context),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.redAccent,
          ),
        ),
        child: Center(child: DefaultPlatformText(module.name)),
      ),
    );
  }
}
