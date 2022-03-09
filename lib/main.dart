import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/introduction/connect_mirror.dart';
import 'package:magic_app/introduction/introduction_page.dart';
import 'package:magic_app/profile_page.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/settings_page.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/themes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'generated/l10n.dart';
import 'mirror/mirror_data.dart';
import 'mirror_page.dart';

// TODO: Introduction
// TODO: spinner

void main() async {
  // debugPrintGestureArenaDiagnostics = true;

  // Preserve the splash screen until init is finished
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Init settings first
  await SharedPreferencesHandler.init();

  // Retrieve the default layout from the file and persist it to storage
  defaultMirrorLayout =
      await rootBundle.loadString("assets/default_layout.json");
  defaultValues[SettingKeys.mirrorLayout] =
      MirrorLayout.fromString(defaultMirrorLayout);

  // Refresh the mirror layout on startup
  SharedPreferencesHandler.saveValue(SettingKeys.mirrorRefresh, true);

  // Try connecting to the mirror
  await CommunicationHandler.connectToMirror();

  // Remove the screen
  FlutterNativeSplash.remove();

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
    // Close the client connection to the raspberry pi
    CommunicationHandler.closeConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget = !CommunicationHandler.isConnected
        ? const ConnectMirror()
        : SharedPreferencesHandler.getValue(SettingKeys.firstUse)
            ? const IntroductionPage()
            : const MagicHomePage();

    return Theme(
      data: ThemeData(),
      child: PlatformProvider(
        // No special settings
        settings: PlatformSettingsData(),
        builder: (_) => PlatformApp(
          // Delegate all localizations to support multiple languages
          localizationsDelegates: const [
            S.delegate,
            RefreshLocalizations.delegate,
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
          home: mainWidget,
          // Load the android themes
          material: (_, __) => MaterialAppData(
            theme: lightMaterialTheme,
            darkTheme: darkMaterialTheme,
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

  /// Controls the style of the nav bar
  static const double _navTop = -20;
  static const double _navHeight = 50;
  static const double _navCurveSize = 75;

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
    final List<TabItem> _bottomNavigationList = [
      TabItem(
        title: S.of(context).profile,
        icon: Icon(PlatformIcons(context).accountCircle),
        activeIcon: Icon(PlatformIcons(context).accountCircleSolid),
        isIconBlend: true,
      ),
      const TabItem(
        // title: S.of(context).magicMirror,
        icon: Icon(
          Icons.crop_portrait,
          size: 35,
        ),
        isIconBlend: true,
      ),
      TabItem(
        title: S.of(context).settings,
        icon: Icon(PlatformIcons(context).settings),
        activeIcon: Icon(PlatformIcons(context).settingsSolid),
        isIconBlend: true,
      ),
    ];

    final Widget centerWidget = Container(
      decoration: BoxDecoration(
        color: isMaterial(context)
            ? Theme.of(context).scaffoldBackgroundColor
            : darkCupertinoTheme.scaffoldBackgroundColor,
      ),
      child: Center(
        child: _menuItemsContents[_selectedNavigationIndex],
      ),
    );

    // The app layout consists of an AppBar, content and navigation footer
    return Column(
      children: [
        PlatformAppBar(
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
        Expanded(
          child: PlatformWidget(
            material: (_, __) => Material(
              type: MaterialType.transparency,
              child: centerWidget,
            ),
            cupertino: (_, __) => centerWidget,
          ),
        ),
        StyleProvider(
          style: _NavBarStyle(),
          child: ConvexAppBar(
            top: _navTop,
            height: _navHeight,
            curveSize: _navCurveSize,
            style: TabStyle.fixedCircle,
            backgroundColor: isMaterial(context)
                ? Theme.of(context).bottomAppBarColor
                : darkCupertinoTheme.barBackgroundColor,
            activeColor: Colors.white,
            items: _bottomNavigationList,
            initialActiveIndex: _selectedNavigationIndex,
            onTap: _onMenuItemTapped,
          ),
        ),
      ],
    );
  }
}

/// Needed to customize the text size of the labels
class _NavBarStyle extends StyleHook {
  @override
  double get activeIconMargin => 6;

  @override
  double get activeIconSize => 35;

  @override
  double? get iconSize => 25;

  @override
  TextStyle textStyle(Color color) {
    return TextStyle(
      fontSize: 12,
      fontFamily: "Roboto",
      fontWeight: FontWeight.normal,
      color: color,
      decoration: TextDecoration.none,
    );
  }
}
