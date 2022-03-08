import 'package:flutter/material.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';

import 'mirror_data.dart';
import 'mirror_view.dart';

/// Displays the mirror layout with a wall in the background ([MirrorBackground])
/// and a frame ([MirrorFrame]) around the mirror ([MirrorView])
class MirrorContainer extends StatelessWidget {
  const MirrorContainer(
      {this.mirrorSize = 75,
      this.enableClick = true,
      this.displayLoading = true,
      this.selectedModule,
      this.onModuleChanged,
      this.mirrorViewKey,
      Key? key})
      : super(key: key);

  /// The size (in % of the available height) of the mirror
  final int mirrorSize;

  /// Whether the [MirrorEdit] screen should be opened once the mirror is clicked
  final bool enableClick;

  /// Whether a loading screen should be shown overlaying the mirror. This also disabled the opening of [MirrorEdit]
  final bool displayLoading;

  /// The (optionally) selectedModule. This will cause the given module to be highlighted
  final Module? selectedModule;

  /// A callback to inform the parent if a different (or no) module was selected
  final ValueChanged<Module?>? onModuleChanged;

  /// A key to retrieve the state of the [MirrorView]
  final GlobalKey<MirrorViewState>? mirrorViewKey;

  @override
  Widget build(BuildContext context) {
    // Take as much space as possible
    return Expanded(
      // Fluent transitions
      child: Hero(
        tag: "mirror",
        child: LayoutBuilder(
          // Open the MirrorEdit on click
          builder: (_, BoxConstraints constraints) => GestureDetector(
            // behavior: HitTestBehavior.translucent,
            onTap: () => onModuleChanged!(null),
            // Construct the displayed layout
            child: MirrorBackground(
              mirrorBorder: MirrorFrame(
                mirrorView: MirrorView(
                  key: mirrorViewKey,
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
      ),
    );
  }
}

/// Displays a wall with a background color and texture.
class MirrorBackground extends StatelessWidget {
  const MirrorBackground({required this.mirrorBorder, Key? key})
      : super(key: key);

  /// The [MirrorFrame] to display on top of this background
  final MirrorFrame mirrorBorder;

  @override
  Widget build(BuildContext context) {
    // Wall texture from: https://www.freepik.com/free-photo/white-plaster-texture_1034065.htm
    // Retrieve the image from the value in the local storage
    AssetImage backgroundImage = AssetImage(
        "assets/patterns/wall/${SharedPreferencesHandler.getValue(SettingKeys.wallPattern)}");

    return Container(
      child: mirrorBorder,
      alignment: Alignment.center,
      // Decorate the container with a color and image
      decoration: BoxDecoration(
        color: SharedPreferencesHandler.getValue(SettingKeys.wallColor),
        image: DecorationImage(
          image: backgroundImage,
          // The texture should fill the entire screen by repeating itself
          repeat: ImageRepeat.repeat,
        ),
      ),
    );
  }
}

/// Displays the frame around the [MirrorView]
class MirrorFrame extends StatelessWidget {
  const MirrorFrame({required this.mirrorView, Key? key}) : super(key: key);

  /// The [MirrorView] containing the layout of the modules
  final MirrorView mirrorView;

  /// The width of the frame
  static const double frameWidth = 20;

  @override
  Widget build(BuildContext context) {
    // Texture from: https://www.ikea.com/de/de/p/dalskaerr-rahmen-holzeffekt-hellbraun-80374217/
    AssetImage borderImage = AssetImage(
        "assets/patterns/mirror_frame/${SharedPreferencesHandler.getValue(SettingKeys.mirrorFrame)}");

    return Container(
      // Use the frameWidth as a safe zone
      padding: const EdgeInsets.all(frameWidth),
      // Small shadow for decoration purposes
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(spreadRadius: 0, blurRadius: 5, offset: Offset(3, 3))
        ],
        // Use the given frame image
        image: DecorationImage(
          image: borderImage,
          fit: BoxFit.fill,
        ),
      ),
      child: mirrorView,
    );
  }
}
