import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/mirror/mirror_edit.dart';
import 'package:magic_app/mirror/module_widget.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:magic_app/util/text_types.dart';

import '../settings/constants.dart';
import 'mirror_data.dart';

class MirrorView extends StatefulWidget {
  const MirrorView(
      {required this.height,
      this.enableClick = true,
      this.displayLoading = true,
      this.selectedModule = "",
      this.onModuleChanged = print,
      Key? key})
      : super(key: key);

  final double height;
  final bool enableClick;
  final bool displayLoading;
  final String selectedModule;
  final ValueChanged<String> onModuleChanged;

  @override
  MirrorViewState createState() => MirrorViewState();
}

class MirrorViewState extends State<MirrorView> {
  // TODO: Convert this to a setting
  static const double mirrorRatio = 50 / 70;
  static final Iterable<ModulePosition> validModulePositions =
      ModulePosition.values.getRange(0, ModulePosition.values.length - 2);

  @override
  void initState() {
    super.initState();
    selectedModule = widget.selectedModule;
    layout = SharedPreferencesHandler.getValue(SettingKeys.mirrorLayout);

    print("Loaded layout: $layout");
    // print(
    //     "MirrorView built with selected module $selectedModule (${widget.selectedModule}), enableClick: ${widget.enableClick}");
  }

  String selectedModule = "";
  late MirrorLayout layout;

  Module? tempMovedModule;

  void setSelectedModule(String moduleName) {
    setState(() {
      selectedModule = moduleName;
    });

    widget.onModuleChanged(moduleName);
  }

  @override
  Widget build(BuildContext context) {
    List<DragTarget> modulesWidgets = [];

    for (ModulePosition modulePosition in validModulePositions) {
      Module? m = layout.modules[modulePosition];
      dynamic targetChild;

      if (m != null) {
        ModuleWidget moduleWidget = ModuleWidget(
          module: m,
          selectedCallback: setSelectedModule,
          isSelected: m.name == selectedModule && !widget.enableClick,
        );

        targetChild = Draggable(
          data: m,
          maxSimultaneousDrags: 1,
          child: moduleWidget,
          feedback: moduleWidget,
        );
      } else {
        // print("No module for position $modulePosition");
        targetChild = const Padding(padding: EdgeInsets.all(10));
      }

      modulesWidgets.add(
        DragTarget(
          onAccept: (newModule) {
            if (newModule is Module) {
              if (tempMovedModule != null) {
                tempMovedModule!.originalPosition = newModule.originalPosition;
              }
              newModule.originalPosition = modulePosition;

              setState(() {
                layout.changeModulePosition(newModule, modulePosition);
              });
            }
          },
          onMove: (data) {
            Module newModule = data.data as Module;
            Module? currentModule = layout.modules[modulePosition];
            if (newModule.name != currentModule?.name) {
              tempMovedModule = currentModule;

              setState(() {
                layout.changeModulePosition(newModule, modulePosition);

                if (tempMovedModule != null) {
                  layout.changeModulePosition(
                      tempMovedModule!, newModule.originalPosition);
                }
              });
            }
          },
          onLeave: (data) {
            if (tempMovedModule != null) {
              print(
                  "Moving ${tempMovedModule!.name} back to ${tempMovedModule!.originalPosition}");

              layout.changeModulePosition(
                tempMovedModule!,
                tempMovedModule!.originalPosition,
              );

              setState(() {
                tempMovedModule = null;
              });
            }
          },
          builder: (_, __, ___) => targetChild,
        ),
      );
    }

    Container mirrorContainer = Container(
      constraints: BoxConstraints(
        maxHeight: widget.height,
        maxWidth: widget.height * mirrorRatio,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          modulesWidgets[0],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              modulesWidgets[1],
              modulesWidgets[2],
              modulesWidgets[3],
            ],
          ),
          modulesWidgets[4],
          modulesWidgets[5],
          modulesWidgets[6],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              modulesWidgets[7],
              modulesWidgets[8],
              modulesWidgets[9],
            ],
          ),
          modulesWidgets[10],
        ],
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
    );

    return widget.enableClick && !widget.displayLoading
        ? Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => Navigator.push(
              context,
              platformPageRoute(
                context: context,
                builder: (_) => MirrorEdit(
                  selectedModule: selectedModule,
                ),
              ),
            ),
            child: mirrorContainer,
          )
        : widget.displayLoading
            ? Stack(
                alignment: Alignment.center,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: 0.55,
                      sigmaY: 0.55,
                    ),
                    child: mirrorContainer,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 25),
                        child: PlatformCircularProgressIndicator(),
                      ),
                      const DefaultPlatformText("Refreshing Layout...")
                    ],
                  )
                ],
              )
            : mirrorContainer;
  }
}
