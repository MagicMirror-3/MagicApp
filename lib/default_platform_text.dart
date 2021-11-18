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
        material: (_) => const TextStyle(),
        cupertino: (data) => data.textTheme.textStyle,
      ),
    );
  }
}
