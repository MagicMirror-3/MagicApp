import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/profile_page.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings_page.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:magic_app/util/themes.dart';

import 'generated/l10n.dart';
import 'mirror/mirror_data.dart';
import 'mirror_page.dart';

void main() async {
  // debugPrintGestureArenaDiagnostics = true;

  // Init settings first
  await SharedPreferencesHandler.init();

  // Retrieve the default layout from the file and persist it to storage
  defaultMirrorLayout =
      await rootBundle.loadString("assets/default_layout.json");
  defaultValues[SettingKeys.mirrorLayout] =
      MirrorLayout.fromString(defaultMirrorLayout);

  // Start the app
  runApp(const MagicApp());
}

class MagicApp extends StatefulWidget {
  const MagicApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MagicAppState();

  static _MagicAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MagicAppState>();
}

class _MagicAppState extends State<MagicApp> {
  /// Triggers a rebuild by calling [setState]
  void refreshApp() {
    setState(() {});
  }

  @override
  void dispose() {
    print("main app disposed");
    CommunicationHandler.closeConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(),
      child: PlatformProvider(
        // No special settings
        settings: PlatformSettingsData(),
        builder: (_) => PlatformApp(
          // Delegate all localizations to support multiple languages
          localizationsDelegates: const [
            S.delegate,
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Only support the translated languages
          supportedLocales: S.delegate.supportedLocales,
          // Set the language by retrieving the value from the local storage
          locale: Locale(
            SharedPreferencesHandler.getValue(SettingKeys.language),
          ),
          title: "Magic App",
          home: const MagicHomePage(),
          // Load the android themes
          material: (_, __) => MaterialAppData(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: SharedPreferencesHandler.getValue(SettingKeys.darkMode)
                ? ThemeMode.dark
                : ThemeMode.light,
          ),
          // Load the cupertino themes
          cupertino: (_, __) => CupertinoAppData(
            theme: SharedPreferencesHandler.getValue(SettingKeys.darkMode)
                ? darkCupertinoTheme
                : lightCupertinoTheme,
          ),
        ),
        // Selected the correct platform
        initialPlatform: SharedPreferencesHandler.getValue(
                    SettingKeys.alternativeAppearance) ||
                !isMaterial(context)
            ? TargetPlatform.iOS
            : TargetPlatform.android,
      ),
    );
  }
}

class MagicHomePage extends StatefulWidget {
  const MagicHomePage({Key? key}) : super(key: key);

  @override
  State<MagicHomePage> createState() => _MagicHomePageState();
}

class _MagicHomePageState extends State<MagicHomePage> {
  /// Controls which page will be displayed
  static int _selectedNavigationIndex = 1;

  /// Contains the pages
  static final List<Widget> _menuItemsContents = [
    const ProfilePage(),
    const MainPage(),
    const SettingsPage()
  ];

  @override
  void initState() {
    super.initState();

    // Force portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Updates the displayed page depending on the selected [newIndex]
  void _onMenuItemTapped(int newIndex) {
    setState(() {
      _selectedNavigationIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create the navigation items
    final List<BottomNavigationBarItem> _bottomNavigationList = [
      BottomNavigationBarItem(
        icon: Icon(PlatformIcons(context).accountCircle),
        activeIcon: Icon(PlatformIcons(context).accountCircleSolid),
        label: S.of(context).profile,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.crop_portrait),
        label: S.of(context).magicMirror,
      ),
      BottomNavigationBarItem(
        icon: Icon(PlatformIcons(context).settings),
        activeIcon: Icon(PlatformIcons(context).settingsSolid),
        label: S.of(context).settings,
      ),
    ];

    // The app layout consists of an AppBar, content and navigation footer
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).appName),
        material: (_, __) => MaterialAppBarData(),
        // Show a slight border on iOS
        cupertino: (_, __) => CupertinoNavigationBarData(
          border: const Border(
            bottom: BorderSide(
              color: Colors.white12,
            ),
          ),
          transitionBetweenRoutes: true,
        ),
      ),
      // Display the selected page
      body: Center(
        child: _menuItemsContents[_selectedNavigationIndex],
      ),
      bottomNavBar: PlatformNavBar(
        items: _bottomNavigationList,
        currentIndex: _selectedNavigationIndex,
        itemChanged: _onMenuItemTapped,
        material: (_, __) => MaterialNavBarData(),
        // Show a slight border on iOS
        cupertino: (_, __) => CupertinoTabBarData(
          inactiveColor: Colors.white70,
          border: const Border(
            top: BorderSide(
              color: Colors.white12,
            ),
          ),
        ),
      ),
    );
  }
}
