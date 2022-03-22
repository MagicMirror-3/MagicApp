import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/utility.dart';

class UserEdit extends StatefulWidget {
  const UserEdit({Key? key}) : super(key: key);

  @override
  _UserEditState createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  /// Needed to validate all inputs in the form
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "FormKey");

  late String _firstName;
  late String _lastName;

  @override
  void initState() {
    MagicUser user = SharedPreferencesHandler.getValue(SettingKeys.user);

    _firstName = user.firstName;
    _lastName = user.lastName;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.always,
      // TODO: Implement the edit fields here
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              const DefaultPlatformText("First Name"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: PlatformTextFormField(
                  initialValue: _firstName,
                  hintText: "Enter your first name here",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              const DefaultPlatformText("Last Name"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: PlatformTextFormField(
                  initialValue: _lastName,
                  hintText: "Enter your last name here",
                ),
              ),
            ],
          ),
          PlatformTextButton(
            child: const DefaultPlatformText("Submit"),
          ),
        ],
      ),
    );
  }
}
