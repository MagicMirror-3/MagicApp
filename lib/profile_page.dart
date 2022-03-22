import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/main.dart';
import 'package:magic_app/user/user_edit.dart';
import 'package:magic_app/user/user_select.dart';
import 'package:magic_app/util/safe_material_area.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SafeMaterialArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            PlatformIcons(context).personOutline,
            size: 150,
            color: Colors.white,
          ),
          const UserEdit(),
          PlatformTextButton(
            child: const Text("Open widget"),
            onPressed: () => Navigator.push(
              context,
              platformPageRoute(
                context: context,
                builder: (_) => UserSelect(
                  onUserSelected: () {
                    // Remove the user selection and refresh the entire app
                    Navigator.pop(context);
                    MagicApp.of(context)?.refreshApp();
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
