import 'package:flutter/material.dart';
import 'package:magic_app/util/text_types.dart';

import 'module.dart';

/// Widget to display a [Module] in the [MirrorView]
class ModuleLayoutWidget extends StatelessWidget {
  const ModuleLayoutWidget({
    required this.module,
    required this.selectedCallback,
    this.isSelected = false,
    Key? key,
  }) : super(key: key);

  /// The [Module] to display
  final Module module;

  /// The function to call if this widget was clicked
  final Function(Module, BuildContext) selectedCallback;

  /// Whether this module is selected.
  ///
  /// Setting it to [true] displays a different border around the widget
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // Listen to clicks
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => selectedCallback(module, context),
      child: Container(
        padding: const EdgeInsets.all(5),
        // Wrap it in a border
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.white24,
          ),
        ),
        // Display the name of the module
        child: Center(child: DefaultPlatformText(module.name)),
      ),
    );
  }
}

/// This widget represents a [Module] in the [ModuleCatalog] in [MirrorEdit].
class ModuleCatalogWidget extends StatelessWidget {
  const ModuleCatalogWidget({
    required this.module,
    required this.onDragCompleted,
    Key? key,
  }) : super(key: key);

  /// The [Module] to display
  final Module module;

  /// A callback which will be called once the module was dragged onto the layout
  final Function(Module) onDragCompleted;

  @override
  Widget build(BuildContext context) {
    // Only react to long presses
    return LongPressDraggable(
      data: module,
      maxSimultaneousDrags: 1,
      child: DefaultPlatformText(module.name),
      feedback: DefaultPlatformText(module.name),
      onDragCompleted: () => onDragCompleted(module),
    );
  }
}
