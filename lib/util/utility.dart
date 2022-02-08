import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showCupertinoDropdownPopup(
    {required BuildContext context,
    required List<Widget> items,
    required ValueChanged<int> onIndexSelected,
    int initialItem = 0}) {
  int tempIndex = initialItem;

  showCupertinoModalPopup(
    context: context,
    builder: (context) => SizedBox(
      height: 200,
      child: CupertinoPicker(
        itemExtent: 24,
        onSelectedItemChanged: (index) {
          tempIndex = index;
        },
        backgroundColor: Colors.black,
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        children: items,
      ),
    ),
    semanticsDismissible: true,
  ).then((_) => onIndexSelected(tempIndex));
}
