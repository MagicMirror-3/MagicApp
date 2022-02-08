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
  static const List<String> moduleNames = [
    "t_bar",
    "t_l",
    "t_m",
    "t_rt",
    "upper",
    "middle",
    "lower",
    "b_l",
    "b_m",
    "b_r",
    "bottom_bar",
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
    List<ModuleWidget> modules = [];

    for (String s in moduleNames) {
      modules.add(
        ModuleWidget(
          module: Module(name: s),
          selectedCallback: setSelectedModule,
          isSelected: s == selectedModule && !widget.enableClick,
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
          modules[0],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              modules[1],
              modules[2],
              modules[3],
            ],
          ),
          modules[4],
          modules[5],
          modules[6],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              modules[7],
              modules[8],
              modules[9],
            ],
          ),
          modules[10],
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
