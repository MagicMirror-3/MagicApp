import 'package:flutter/material.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';

import 'mirror_view.dart';

class MirrorContainer extends StatelessWidget {
  const MirrorContainer(
      {this.mirrorSize = 75,
      this.enableClick = true,
      this.displayLoading = true,
      this.selectedModule = "",
      this.onModuleChanged,
      Key? key})
      : super(key: key);

  final int mirrorSize;
  final bool enableClick;
  final bool displayLoading;
  final String selectedModule;
  final ValueChanged<String>? onModuleChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Hero(
        tag: "mirror",
        child: LayoutBuilder(
          builder: (_, BoxConstraints constraints) => MirrorBackground(
            mirrorBorder: MirrorBorder(
              mirrorView: MirrorView(
                height: mirrorSize / 100 * constraints.maxHeight,
                enableClick: enableClick,
                displayLoading: displayLoading,
                selectedModule: selectedModule,
                onModuleChanged: onModuleChanged ?? print,
              ),
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
        "assets/patterns/wall/${SharedPreferencesHandler.getValue(SettingKeys.wallPattern)}");

    return Container(
      child: mirrorBorder,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SharedPreferencesHandler.getValue(SettingKeys.wallColor),
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
        "assets/patterns/mirror_border/${SharedPreferencesHandler.getValue(SettingKeys.mirrorBorder)}");

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
