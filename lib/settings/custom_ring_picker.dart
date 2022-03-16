import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// Slightly different implementation of the RingPicker contained in the
/// [flutter_colorpicker] package.
///
/// This is needed to adjust the picker to the special needs of this app
class MagicRingPicker extends StatefulWidget {
  const MagicRingPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.portraitOnly = false,
    this.colorPickerHeight = 250.0,
    this.hueRingStrokeWidth = 20.0,
    this.enableAlpha = false,
    this.displayThumbColor = true,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
  }) : super(key: key);

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final bool portraitOnly;
  final double colorPickerHeight;
  final double hueRingStrokeWidth;
  final bool enableAlpha;
  final bool displayThumbColor;
  final BorderRadius pickerAreaBorderRadius;

  @override
  _MagicRingPickerState createState() => _MagicRingPickerState();
}

class _MagicRingPickerState extends State<MagicRingPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);

  @override
  void initState() {
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
    super.initState();
  }

  @override
  void didUpdateWidget(MagicRingPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
  }

  void onColorChanging(HSVColor color) {
    setState(() => currentHsvColor = color);
    widget.onColorChanged(currentHsvColor.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: widget.pickerAreaBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                SizedBox(
                  width: widget.colorPickerHeight,
                  height: widget.colorPickerHeight,
                  child: ColorPickerHueRing(
                    currentHsvColor,
                    onColorChanging,
                    displayThumbColor: widget.displayThumbColor,
                    strokeWidth: widget.hueRingStrokeWidth,
                  ),
                ),
                SizedBox(
                  width: widget.colorPickerHeight /
                      (isMaterial(context) ? 1.75 : 2),
                  height: widget.colorPickerHeight /
                      (isMaterial(context) ? 1.75 : 2),
                  child: ColorPickerArea(
                    currentHsvColor,
                    onColorChanging,
                    PaletteType.hsv,
                  ),
                )
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(width: 10),
            ColorIndicator(currentHsvColor),
            Expanded(
              child: CustomColorPickerInput(
                currentHsvColor.toColor(),
                (Color color) {
                  setState(() => currentHsvColor = HSVColor.fromColor(color));
                  widget.onColorChanged(currentHsvColor.toColor());
                },
                enableAlpha: widget.enableAlpha,
                embeddedText: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomColorPickerInput extends StatefulWidget {
  const CustomColorPickerInput(
    this.color,
    this.onColorChanged, {
    Key? key,
    this.enableAlpha = true,
    this.embeddedText = false,
    this.disable = false,
  }) : super(key: key);

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool enableAlpha;
  final bool embeddedText;
  final bool disable;

  @override
  _CustomColorPickerInputState createState() => _CustomColorPickerInputState();
}

class _CustomColorPickerInputState extends State<CustomColorPickerInput> {
  TextEditingController textEditingController = TextEditingController();
  int inputColor = 0;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (inputColor != widget.color.value) {
      textEditingController.text = '#' +
          widget.color.red.toRadixString(16).toUpperCase().padLeft(2, '0') +
          widget.color.green.toRadixString(16).toUpperCase().padLeft(2, '0') +
          widget.color.blue.toRadixString(16).toUpperCase().padLeft(2, '0') +
          (widget.enableAlpha
              ? widget.color.alpha
                  .toRadixString(16)
                  .toUpperCase()
                  .padLeft(2, '0')
              : '');
    }
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (!widget.embeddedText)
          Text('Hex', style: Theme.of(context).textTheme.bodyText1),
        const SizedBox(width: 10),
        SizedBox(
          width: (Theme.of(context).textTheme.bodyText2?.fontSize ?? 14) * 10,
          child: PlatformTextField(
            enabled: !widget.disable,
            controller: textEditingController,
            inputFormatters: [
              UpperCaseTextFormatter(),
              FilteringTextInputFormatter.allow(RegExp(kValidHexPattern)),
            ],
            onChanged: (String value) {
              String input = value;
              if (value.length == 9) {
                input = value.split('').getRange(7, 9).join() +
                    value.split('').getRange(1, 7).join();
              }
              final Color? color = colorFromHex(input);
              if (color != null) {
                widget.onColorChanged(color);
                inputColor = color.value;
              }
            },
          ),
        ),
      ]),
    );
  }
}
