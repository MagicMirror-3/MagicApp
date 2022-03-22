import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/utility.dart';

import '../generated/l10n.dart';
import '../settings/constants.dart';
import '../settings/shared_preferences_handler.dart';

/// Provides a widget to edit the first and last name of the user
class UserEdit extends StatefulWidget {
  const UserEdit({
    required this.baseUser,
    this.hasSaveButton = false,
    Key? key,
  }) : super(key: key);

  /// The user information to display
  final MagicUser baseUser;

  /// Whether a "save" button will be added to the widget
  final bool hasSaveButton;

  @override
  _UserEditState createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  /// Needed to validate all inputs in the form
  final GlobalKey<FormState> _formKey = GlobalKey(debugLabel: "FormKey");

  /// The first name of the user
  late String _firstName;

  /// The last name of the user
  late String _lastName;

  /// Returns the current user information
  MagicUser get userInfo => MagicUser(
        id: widget.baseUser.id,
        firstName: _firstName,
        lastName: _lastName,
      );

  FormState? get formState => _formKey.currentState;

  @override
  void initState() {
    // Init base values
    _firstName = widget.baseUser.firstName;
    _lastName = widget.baseUser.lastName;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              _ProfileInputField(
                autofocus: true,
                textValue: _firstName,
                hint: S.of(context).first_name_hint,
                changedCallback: (newFirstName) => setState(() {
                  _firstName = newFirstName;
                }),
              ),
              const SizedBox(height: 24),
              _ProfileInputField(
                textValue: _lastName,
                hint: S.of(context).last_name_hint,
                changedCallback: (newLastName) => setState(() {
                  _lastName = newLastName;
                }),
                hasValidator: false,
              ),
            ],
          ),
          if (widget.hasSaveButton)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: PlatformElevatedButton(
                child: DefaultPlatformText(S.of(context).saveChanges),
                color: Colors.green,
                onPressed: formState != null && formState!.validate() ||
                        formState == null
                    ? () => setState(() {
                          SharedPreferencesHandler.saveValue(
                            SettingKeys.user,
                            userInfo,
                          );
                        })
                    : null,
                padding: const EdgeInsets.all(8),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileInputField extends StatelessWidget {
  const _ProfileInputField({
    required this.textValue,
    required this.hint,
    required this.changedCallback,
    this.hasValidator = true,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The text value to display in the input field
  final String textValue;

  /// The hint to display if the input field is empty
  final String hint;

  /// Whether the input field has to contain a text
  final bool hasValidator;

  /// Whether the field should have the focus and be selected by default
  final bool autofocus;

  /// The function to call on every change
  final Function(String) changedCallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: PlatformTextFormField(
        autofocus: autofocus,
        initialValue: textValue,
        hintText: !isMaterial(context) ? hint : null,
        validator: hasValidator
            ? (value) {
                if (value == null || value.isEmpty) {
                  return S.of(context).fillOutField;
                }
                return null;
              }
            : null,
        autovalidateMode: AutovalidateMode.always,
        onChanged: changedCallback,
        material: (_, __) => MaterialTextFormFieldData(
          decoration: InputDecoration(
            labelText: hint,
          ),
        ),
        cupertino: (_, __) => CupertinoTextFormFieldData(
          prefix: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DefaultPlatformText(
              autofocus ? S.of(context).first_name : S.of(context).last_name,
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white30,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }
}
