import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/util/themes.dart';
import 'package:magic_app/util/utility.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:settings_ui/settings_ui.dart';

import '../settings/constants.dart';
import '../settings/shared_preferences_handler.dart';

/// Wraps the child in a "pull to refresh" widget
class MagicRefresher extends StatelessWidget {
  MagicRefresher({
    required this.childWidget,
    Key? key,
    this.pullDown = true,
    this.pullUp = false,
    this.onLoading,
    this.onRefresh,
    this.initialRefresh = false,
  }) : super(key: key);

  /// The widget to wrap
  final Widget childWidget;

  /// Whether the pull down gesture is enabled
  final bool pullDown;

  /// Whether the pull up gesture is enabled
  final bool pullUp;

  /// Called once the pull up gesture is executed.
  ///
  /// It should return true if the action completed successfully
  final Future<bool> Function()? onLoading;

  /// Called once the pull down gesture is executed
  ///
  /// It should return true if the action completed successfully
  final Future<bool> Function()? onRefresh;

  /// Whether [onRefresh] should be called upon creation of this widget
  final bool initialRefresh;

  /// A controller to handle the refresh
  late final RefreshController _controller = RefreshController(
    initialRefresh: initialRefresh,
  );

  /// Waits for the provided function ([onRefresh()]) to execute and displays the result accordingly
  void _refreshCallback() async {
    if (onRefresh != null) {
      bool success = await onRefresh!();

      if (success) {
        _controller.refreshCompleted();
      } else {
        _controller.refreshFailed();
      }
    }
  }

  /// Waits for the provided function ([onLoading()])to execute and displays the result accordingly
  void _loadingCallback() async {
    if (onLoading != null) {
      bool success = await onLoading!();

      if (success) {
        _controller.loadComplete();
      } else {
        _controller.loadFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _controller,
      header: const ClassicHeader(),
      child: childWidget,
      enablePullDown: pullDown,
      enablePullUp: pullUp,
      onLoading: _loadingCallback,
      onRefresh: _refreshCallback,
    );
  }
}

/// Displays the settings with a specific theme
class MagicSettingsList extends StatelessWidget {
  const MagicSettingsList({Key? key, required this.sections}) : super(key: key);

  /// A list containing every section the list should consist of
  final List<AbstractSettingsSection> sections;

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      // Select the theme
      darkTheme: isMaterial(context)
          ? darkMaterialSettingsTheme
          : darkCupertinoSettingsTheme,
      lightTheme: isMaterial(context)
          ? lightMaterialSettingsTheme
          : lightCupertinoSettingsTheme,
      brightness: SharedPreferencesHandler.getValue(SettingKeys.darkMode)
          ? Brightness.dark
          : Brightness.light,
      // iOS and Android
      applicationType: ApplicationType.both,
      sections: sections,
    );
  }
}

/// Enables the user to select an item out of a given list of choices.
///
/// Depending on the platform (iOS or Android) a different picker type is used
class MagicChoiceTile extends AbstractSettingsTile {
  const MagicChoiceTile({
    Key? key,
    required this.title,
    required this.items,
    required this.index,
    required this.selectCallback,
    this.leading,
  }) : super(key: key);

  /// The name of this settings option
  final String title;

  /// Every available item
  final List<String> items;

  /// The currently selected item (by index)
  final int index;

  /// The function to call if an item was selected
  final Function(int) selectCallback;

  /// A widget to display in left of the [title]
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      // Open a dropdown popup on iOS
      cupertino: (context, __) => SettingsTile.navigation(
        title: Text(title),
        value: Text(
          items[index],
        ),
        onPressed: (_) => showCupertinoDropdownPopup(
          context: context,
          items: items.map((e) => Text(e)).toList(),
          initialItem: index,
          onIndexSelected: (selectedIndex) => selectCallback(selectedIndex),
        ),
        leading: leading,
      ),
      // Open a dropdown button on Android
      material: (context, __) => SettingsTile.navigation(
        title: Text(title),
        leading: leading,
        trailing: DropdownButton<String>(
          value: items[index],
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (selectedString) =>
              selectCallback(items.indexOf(selectedString!)),
        ),
      ),
    );
  }
}

/// Connects a setting tile straight to the [SharedPreferencesHandler].
///
/// Uses a [MagicChoiceTile] to provide a widget where the user can choose from
class LinkedMagicChoiceTile extends AbstractSettingsTile {
  const LinkedMagicChoiceTile({
    Key? key,
    required this.title,
    required this.settingKey,
    required this.settingChoices,
    required this.selectCallback,
    this.leading,
  }) : super(key: key);

  /// The name of the setting
  final String title;

  /// The key of the setting in the shared preferences. Should be a value contained
  /// in [SettingKeys]
  final String settingKey;

  /// Choices the user can pick from.
  ///
  /// The keys are the values saved in the shared preferences. The values are
  /// displayed to the user
  final Map<String, String> settingChoices;

  /// Function to call if the selection changed
  final Function(String) selectCallback;

  /// A widget to display in left of the [title]
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    int selectedIndex = settingChoices.keys
        .toList()
        .indexOf(SharedPreferencesHandler.getValue(settingKey));

    // Use the MagicChoiceTile
    return MagicChoiceTile(
      title: title,
      items: settingChoices.values.toList(),
      index: selectedIndex,
      selectCallback: (index) =>
          selectCallback(settingChoices.keys.toList()[index]),
      leading: leading,
    );
  }
}

/// Displays a [List<MagicListViewItem>] of [children].
///
/// If [hasDivider] is set, a divider is inserted between each item.
class MagicListView extends StatelessWidget {
  const MagicListView({
    required this.children,
    this.hasDivider = true,
    this.shrinkWrap = false,
    Key? key,
  }) : super(key: key);

  /// The widget to display
  final List<MagicListViewItem> children;

  /// Whether a divider should be inserted between each child widget
  final bool hasDivider;

  /// Whether the list should only take the space it needs
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (hasDivider) {
      return ListView.separated(
        shrinkWrap: shrinkWrap,
        itemCount: children.length,
        itemBuilder: (_, index) => children[index],
        separatorBuilder: (_, __) => const Divider(),
      );
    } else {
      return ListView(
        shrinkWrap: shrinkWrap,
        children: children,
      );
    }
  }
}

/// Represents an item inside a [MagicListView]. It has different styles for
/// cupertino and material
class MagicListViewItem extends StatelessWidget {
  const MagicListViewItem({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool isThreeLine;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
        cupertino: (_, __) => _buildCupertinoItem(context),
        material: (_, __) => _buildMaterialItem(context));
  }

  Widget _buildCupertinoItem(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      shape: const ContinuousRectangleBorder(),
      borderOnForeground: false,
      color: Colors.white10,
      child: ListTile(
        // Cupertino style
        iconColor: Colors.white,
        textColor: Colors.white,
        // Default stuff
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        isThreeLine: isThreeLine,
        onTap: onTap,
      ),
    );
  }

  Widget _buildMaterialItem(BuildContext context) {
    return Card(
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        isThreeLine: isThreeLine,
        onTap: onTap,
      ),
    );
  }
}
