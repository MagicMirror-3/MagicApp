import 'package:flutter/material.dart';
import 'package:magic_app/user/user_edit.dart';

import '../util/utility.dart';

class UserCreate extends StatelessWidget {
  const UserCreate({required this.onInputChanged, Key? key}) : super(key: key);

  final Function(bool) onInputChanged;

  @override
  Widget build(BuildContext context) {
    // TODO: Beautify
    return UserEdit(
      baseUser: const MagicUser(),
      onInputChanged: onInputChanged,
    );
  }
}
