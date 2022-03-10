import 'package:flutter/material.dart';
import 'package:magic_app/util/text_types.dart';

import 'module.dart';

class ModuleLayoutWidget extends StatelessWidget {
  const ModuleLayoutWidget(
      {required this.module,
      required this.selectedCallback,
      this.isSelected = false,
      Key? key})
      : super(key: key);

  final Module module;
  final Function(Module, BuildContext) selectedCallback;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => selectedCallback(module, context),
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

class ModuleCatalogWidget extends StatelessWidget {
  const ModuleCatalogWidget(
      {required this.module, required this.onDragCompleted, Key? key})
      : super(key: key);

  final Module module;
  final Function(Module) onDragCompleted;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      data: module,
      maxSimultaneousDrags: 1,
      child: Row(
        children: [
          const Icon(Icons.crop_portrait),
          DefaultPlatformText(module.name),
        ],
      ),
      feedback: DefaultPlatformText(module.name),
      onDragCompleted: () => onDragCompleted(module),
    );
  }
}
