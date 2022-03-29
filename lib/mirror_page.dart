import 'package:flutter/material.dart';
import 'package:magic_app/mirror/mirror_container.dart';
import 'package:magic_app/mirror/mirror_layout_handler.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/magic_widgets.dart';
import 'package:magic_app/util/text_types.dart';

import 'generated/l10n.dart';

/// Displays a greeting message and the [MirrorContainer]
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// Whether the layout is being retrieved from the backend
  bool loading = PreferencesAdapter.mirrorRefresh;

  /// Tries getting the layout from the backend
  Future<bool> getLayout() async {
    if (!loading) {
      setState(() {
        loading = true;
      });
    }

    if (CommunicationHandler.isConnected) {
      await MirrorLayoutHandler.refresh();

      if (MirrorLayoutHandler.isReady) {
        // Wait for cosmetic purposes
        Future.delayed(const Duration(seconds: 1)).then(
          (_) {
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          },
        );
      }
    }

    return MirrorLayoutHandler.isReady;
  }

  @override
  Widget build(BuildContext context) {
    // Get the name of the user
    String userName = PreferencesAdapter.activeUser.name;

    // Wrap the widget in a drag down refresher
    return MagicRefresher(
      initialRefresh: loading,
      onRefresh: getLayout,
      childWidget: Column(
        children: [
          HeaderPlatformText(S.of(context).greetings(userName.trim())),
          MirrorContainer(
            key: Key("MirrorContainer_MirrorPage:$loading"),
            displayLoading: loading,
          )
        ],
      ),
    );
  }
}
