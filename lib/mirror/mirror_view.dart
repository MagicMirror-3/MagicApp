import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/mirror/mirror_edit.dart';
import 'package:magic_app/mirror/module_widget.dart';

import 'module.dart';

class MirrorView extends StatefulWidget {
  const MirrorView(
      {required this.height,
      this.enableClick = true,
      this.selectedModule = "",
      this.onModuleChanged = print,
      Key? key})
      : super(key: key);

  final double height;
  final bool enableClick;
  final String selectedModule;
  final ValueChanged<String> onModuleChanged;

  @override
  _MirrorViewState createState() => _MirrorViewState();
}

class _MirrorViewState extends State<MirrorView> {
  // TODO: Convert this to a setting
  static const double mirrorRatio = 50 / 70;
  static List<Module> modules = [
    Module(name: "t_bar"),
    Module(name: "t_l"),
    Module(name: "t_m"),
    Module(name: "t_rt"),
    Module(name: "upper"),
    Module(name: "middle"),
    Module(name: "lower"),
    Module(name: "b_l"),
    Module(name: "b_m"),
    Module(name: "b_r"),
    Module(name: "bottom_bar"),
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedModule = widget.selectedModule;
    });

    print(
        "MirrorView built with selected module $selectedModule (${widget.selectedModule}), enableClick: ${widget.enableClick}");
  }

  String selectedModule = "";

  void setSelectedModule(String moduleName) {
    print("MirrorView: $moduleName is selected");
    setState(() {
      selectedModule = moduleName;
    });

    widget.onModuleChanged(moduleName);
  }

  @override
  Widget build(BuildContext context) {
    List<DragTarget> modulesWidgets = [];

    for (Module m in modules) {
      ModuleWidget moduleWidget = ModuleWidget(
        module: m,
        selectedCallback: setSelectedModule,
        isSelected: m.name == selectedModule && !widget.enableClick,
      );

      modulesWidgets.add(
        DragTarget(
          onAccept: (data) => print("accepted $data"),
          onMove: (data) => print("move $data"),
          onLeave: (data) => print("leave $data"),
          builder: (_, __, ___) => Draggable(
            data: m,
            maxSimultaneousDrags: 1,
            child: moduleWidget,
            feedback: moduleWidget,
          ),
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

    return widget.enableClick
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
        : mirrorContainer;
  }
}
