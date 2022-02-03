import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/mirror/mirror_edit.dart';
import 'package:magic_app/util/text_types.dart';

class MirrorView extends StatefulWidget {
  const MirrorView({required this.height, this.enableClick = true, Key? key})
      : super(key: key);

  final double height;
  final bool enableClick;

  @override
  _MirrorViewState createState() => _MirrorViewState();
}

class _MirrorViewState extends State<MirrorView> {
  // TODO: Convert this to a setting
  static const double mirrorRatio = 50 / 70;

  @override
  Widget build(BuildContext context) {
    Container mirrorContainer = Container(
      constraints: BoxConstraints(
        maxHeight: widget.height,
        maxWidth: widget.height * mirrorRatio,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const DefaultPlatformText("top_bar"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              DefaultPlatformText("t_left"),
              DefaultPlatformText("t_middle"),
              DefaultPlatformText("t_right"),
            ],
          ),
          const DefaultPlatformText("upper_third"),
          const DefaultPlatformText("middle_center"),
          const DefaultPlatformText("lower_third"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              DefaultPlatformText("b_left"),
              DefaultPlatformText("b_middle"),
              DefaultPlatformText("b_right"),
            ],
          ),
          const DefaultPlatformText("bottom_bar"),
        ],
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
    );

    return widget.enableClick
        ? GestureDetector(
            onTap: () => Navigator.push(
              context,
              platformPageRoute(
                context: context,
                builder: (context) => const MirrorEdit(),
              ),
            ),
            child: mirrorContainer,
          )
        : mirrorContainer;
  }
}
