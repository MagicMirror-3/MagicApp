import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/mirror/mirror_edit.dart';
import 'package:magic_app/mirror/module_widget.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:magic_app/util/text_types.dart';

import '../generated/l10n.dart';
import '../settings/constants.dart';
import 'mirror_data.dart';

class MirrorView extends StatefulWidget {
  const MirrorView(
      {required this.height,
      this.enableClick = true,
      this.displayLoading = true,
      this.selectedModule,
      this.onModuleChanged = print,
      Key? key})
      : super(key: key);

  final double height;
  final bool enableClick;
  final bool displayLoading;
  final Module? selectedModule;
  final ValueChanged<Module?> onModuleChanged;

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

    // print("Loaded layout: $layout");
    // print(
    //     "MirrorView built with selected module $selectedModule (${widget.selectedModule}), enableClick: ${widget.enableClick}");
  }

  Module? selectedModule;
  late MirrorLayout layout;

  Module? tempMovedModule;

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
    List<Widget> modulesWidgets = [];
    for (ModulePosition modulePosition in validModulePositions) {
      Module? m = layout.modules[modulePosition];
      dynamic targetChild;

      if (m != null) {
        ModuleWidget moduleWidget = ModuleWidget(
          module: m,
          selectedCallback: setSelectedModule,
          isSelected: selectedModule != null &&
              m.name == selectedModule!.name &&
              !widget.enableClick,
        );

        targetChild = Draggable(
          data: m,
          maxSimultaneousDrags: 1,
          child: moduleWidget,
          feedback: moduleWidget,
        );
      } else {
        // print("No module for position $modulePosition");
        targetChild = Container();
      }

      modulesWidgets.add(
        Flexible(
          fit: FlexFit.tight,
          child: DragTarget(
            onAccept: (newModule) {
              if (newModule is Module) {
                if (tempMovedModule != null) {
                  tempMovedModule!.originalPosition =
                      newModule.originalPosition;
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
        ),
      );
    }

    Container moduleContainer = Container(
      constraints: BoxConstraints(
        maxHeight: widget.height,
        maxWidth: widget.height * mirrorRatio,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          modulesWidgets[0],
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
          modulesWidgets[4],
          modulesWidgets[5],
          modulesWidgets[6],
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
          modulesWidgets[10],
        ],
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
    );

    return widget.enableClick && !widget.displayLoading
        ? GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => openMirrorEdit(context),
            child: moduleContainer,
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
            : moduleContainer;
  }
}
