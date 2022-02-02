import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_app/mirror_view.dart';

class MirrorContainer extends StatelessWidget {
  const MirrorContainer(
      {required this.backgroundColor,
      required this.borderColor,
      this.mirrorSize = 75,
      Key? key})
      : super(key: key);

  final Color backgroundColor;
  final Color borderColor;
  final int mirrorSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (_, BoxConstraints constraints) => MirrorBackground(
          color: backgroundColor,
          mirrorBorder: MirrorBorder(
            color: borderColor,
            mirrorView: MirrorView(
              height: mirrorSize / 100 * constraints.maxHeight,
            ),
          ),
        ),
      ),
    );
  }
}

class MirrorBackground extends StatelessWidget {
  const MirrorBackground(
      {required this.color,
      required this.mirrorBorder,
      // Wall texture from: https://www.freepik.com/free-photo/white-plaster-texture_1034065.htm
      this.pattern = "assets/patterns/wall/wall.jpg",
      Key? key})
      : super(key: key);

  final Color color;
  final String pattern;
  final MirrorBorder mirrorBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: mirrorBorder,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        image: DecorationImage(
          image: AssetImage(pattern),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class MirrorBorder extends StatelessWidget {
  const MirrorBorder(
      {required this.color,
      required this.mirrorView,
      // Texture from: https://www.ikea.com/de/de/p/dalskaerr-rahmen-holzeffekt-hellbraun-80374217/
      this.pattern = "assets/patterns/wood.png",
      Key? key})
      : super(key: key);

  final Color color;
  final String pattern;
  final MirrorView mirrorView;

  static const double borderWidth = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        color: color,
        boxShadow: const [
          BoxShadow(spreadRadius: 0, blurRadius: 5, offset: Offset(3, 3))
        ],
        image: DecorationImage(
          image: AssetImage(pattern),
          fit: BoxFit.fill,
        ),
      ),
      child: mirrorView,
    );
  }
}
