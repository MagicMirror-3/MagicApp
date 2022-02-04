import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import 'mirror_view.dart';

class MirrorContainer extends StatelessWidget {
  const MirrorContainer(
      {this.mirrorSize = 75,
      this.enableClick = true,
      this.selectedModule = "",
      this.selectedModuleCallback,
      Key? key})
      : super(key: key);

  final int mirrorSize;
  final bool enableClick;
  final String selectedModule;
  final Function? selectedModuleCallback;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (_, BoxConstraints constraints) => MirrorBackground(
          mirrorBorder: MirrorBorder(
            mirrorView: MirrorView(
              height: mirrorSize / 100 * constraints.maxHeight,
              enableClick: enableClick,
              selectedModule: selectedModule,
              selectedModuleCallback: selectedModuleCallback ?? print,
            ),
          ),
        ),
      ),
    );
  }
}

class MirrorBackground extends StatelessWidget {
  const MirrorBackground({required this.mirrorBorder, Key? key})
      : super(key: key);

  final MirrorBorder mirrorBorder;

  @override
  Widget build(BuildContext context) {
    // Wall texture from: https://www.freepik.com/free-photo/white-plaster-texture_1034065.htm
    AssetImage backgroundImage = AssetImage(
        "assets/patterns/wall/${Settings.getValue("wallPattern", "wall.jpg")}");

    String colorCode =
        Settings.getValue("wallColor", "#ffffffff").replaceAll("#", "");

    Color backgroundColor = Color(int.parse(colorCode, radix: 16));

    return Container(
      child: mirrorBorder,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        image: DecorationImage(
          image: backgroundImage,
          repeat: ImageRepeat.repeat,
        ),
      ),
    );
  }
}

class MirrorBorder extends StatelessWidget {
  const MirrorBorder({required this.mirrorView, Key? key}) : super(key: key);

  final MirrorView mirrorView;
  static const double borderWidth = 20;

  @override
  Widget build(BuildContext context) {
    // Texture from: https://www.ikea.com/de/de/p/dalskaerr-rahmen-holzeffekt-hellbraun-80374217/
    AssetImage borderImage = AssetImage(
        "assets/patterns/mirror_border/${Settings.getValue("borderImage", "default.png")}");

    return Container(
      padding: const EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(spreadRadius: 0, blurRadius: 5, offset: Offset(3, 3))
        ],
        image: DecorationImage(
          image: borderImage,
          fit: BoxFit.fill,
        ),
      ),
      child: mirrorView,
    );
  }
}
