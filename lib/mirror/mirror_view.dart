import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/mirror/mirror_edit.dart';
import 'package:magic_app/mirror/mirror_layout_handler.dart';
import 'package:magic_app/mirror/module_widget.dart';
import 'package:magic_app/util/text_types.dart';

import '../generated/l10n.dart';
import 'module.dart';

/// Displays the current layout of the mirror
class MirrorView extends StatefulWidget {
  const MirrorView(
      {required this.height,
      this.enableClick = true,
      this.displayLoading = true,
      this.selectedModule,
      this.onModuleChanged = print,
      Key? key})
      : super(key: key);

  /// The height of the mirror. The width will be calculated depending on the ratio.
  final double height;

  /// Whether layout should be clickable
  final bool enableClick;

  /// Whether a loading animation should be displayed on top of the layout
  final bool displayLoading;

  /// The currently selected module (will be displayed with a border
  final Module? selectedModule;

  /// Called whenever the module selection changed
  final ValueChanged<Module?> onModuleChanged;

  @override
  MirrorViewState createState() => MirrorViewState();
}

class MirrorViewState extends State<MirrorView> {
  // TODO: Convert this to a setting
  static const double mirrorRatio = 50 / 70;

  /// Every position a module can have except [ModulePosition.menu]
  static final Iterable<ModulePosition> validModulePositions =
      ModulePosition.values.getRange(0, ModulePosition.values.length - 2);

  @override
  void initState() {
    super.initState();
    selectedModule = widget.selectedModule;

    // print("Loaded layout: $layout");
    // print(
    //     "MirrorView built with selected module $selectedModule (${widget.selectedModule}), enableClick: ${widget.enableClick}");
  }

  /// The currently selected module
  Module? selectedModule;

  /// Pushes the [MirrorEdit] view onto the Navigator
  void openMirrorEdit(BuildContext context) {
    if (widget.enableClick && !widget.displayLoading) {
      Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder: (_) => MirrorEdit(
            selectedModule: selectedModule,
          ),
        ),
      );
    }
  }

  /// Updates the selected module and calls [openMirrorEdit()]
  void setSelectedModule(Module? module, BuildContext context) {
    if (module != selectedModule) {
      setState(() {
        selectedModule = module;
      });

      widget.onModuleChanged(module);
    }

    openMirrorEdit(context);
  }

  @override
  Widget build(BuildContext context) {
    Container moduleContainer = _buildLayoutContainer();

    // Open the MirrorEdit view, if the layout is clickable and not loading
    return widget.enableClick && !widget.displayLoading
        ? GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => openMirrorEdit(context),
            child: moduleContainer,
          )
        // Else, display a loading animation on top of the layout if its loading
        : widget.displayLoading
            ? Stack(
                alignment: Alignment.center,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: 0.55,
                      sigmaY: 0.55,
                    ),
                    child: moduleContainer,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 25),
                        child: PlatformCircularProgressIndicator(),
                      ),
                      DefaultPlatformText(S.of(context).mirror_refresh)
                    ],
                  )
                ],
              )
            // Just display the layout
            : moduleContainer;
  }

  /// Builds a widget representing the layout of the MagicMirror² framework
  Container _buildLayoutContainer() {
    List<Widget> modulesWidgets = [];
    for (ModulePosition modulePosition in validModulePositions) {
      Widget targetChild = Container();

      if (MirrorLayoutHandler.isReady) {
        Module? m = MirrorLayoutHandler.layout.modules[modulePosition];

        // Fill the widget with the name of the module and make it draggable
        if (m != null) {
          ModuleLayoutWidget moduleWidget = ModuleLayoutWidget(
            module: m,
            selectedCallback: setSelectedModule,
            isSelected: selectedModule != null &&
                m.name == selectedModule!.name &&
                !widget.enableClick,
          );

          targetChild = Draggable(
            data: m,
            maxSimultaneousDrags: widget.enableClick ? 0 : 1,
            feedback: moduleWidget,
            child: moduleWidget,
          );
        }
      }

      // Each position in the layout could be target of a drag movement
      modulesWidgets.add(
        Flexible(
          fit: FlexFit.tight,
          child: DragTarget(
            // Move module here if it's dropped on top of this target
            onAccept: (Module newModule) {
              setState(() {
                MirrorLayoutHandler.moveModule(newModule, modulePosition);
              });
            },

            // Swap the module if its hovering over this target
            onMove: (data) {
              // Grab the involved modules
              Module newModule = data.data as Module;

              setState(() {
                MirrorLayoutHandler.temporarilyMoveModule(
                  newModule,
                  modulePosition,
                );
              });
            },
            // Undo the temporary move if the module hover over this target ends
            onLeave: (data) {
              setState(() {
                MirrorLayoutHandler.undoTemporaryMove();
              });
            },
            builder: (_, __, ___) => targetChild,
          ),
        ),
      );
    }

    // Order the widgets as they would be on the MagicMirror itself
    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.height,
        maxWidth: widget.height * mirrorRatio,
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // top_bar
          modulesWidgets[0],
          // top_left, top_center, top_right
          Flexible(
            fit: FlexFit.tight,
            child: Row(
              children: [
                modulesWidgets[1],
                modulesWidgets[2],
                modulesWidgets[3],
              ],
            ),
          ),
          // upper_third
          modulesWidgets[4],
          // middle_center
          modulesWidgets[5],
          // lower_third
          modulesWidgets[6],
          // bottom_left, bottom_center, bottom_right
          Flexible(
            fit: FlexFit.tight,
            child: Row(
              children: [
                modulesWidgets[7],
                modulesWidgets[8],
                modulesWidgets[9],
              ],
            ),
          ),
          // bottom_bar
          modulesWidgets[10],
        ],
      ),
    );
  }
}
