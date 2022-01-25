import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class DefaultPlatformText extends StatelessWidget {
  const DefaultPlatformText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return PlatformText(
      text,
      style: platformThemeData(
        context,
        material: (data) => data.textTheme.bodyText2,
        cupertino: (data) => data.textTheme.textStyle,
      ),
    );
  }
}

class HeaderPlatformText extends StatelessWidget {
  const HeaderPlatformText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 25),
      child: PlatformText(
        text,
        style: platformThemeData(
          context,
          material: (data) => data.textTheme.headline4,
          cupertino: (data) => data.textTheme.navLargeTitleTextStyle,
        ),
      ),
    );
  }
}
