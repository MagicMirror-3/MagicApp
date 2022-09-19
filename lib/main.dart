import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/mirror/mirror_layout_handler.dart';
import 'package:magic_app/profile_page.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/settings_page.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/themes.dart';
import 'package:magic_app/util/utility.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'generated/l10n.dart';
import 'introduction/connect_mirror.dart';
import 'introduction/introduction_page.dart';
import 'mirror_page.dart';

void main() async {
  // debugPrintGestureArenaDiagnostics = true;

  // Preserve the splash screen until init is finished
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Init ping on iOS for mirror connection
  DartPingIOS.register();

  // Init settings first
  await SharedPreferencesHandler.init();

  // Refresh the mirror layout on startup
  PreferencesAdapter.setMirrorRefresh(true);

  // Try connecting to the mirror
  await CommunicationHandler.connectToMirror();

  // Remove the screen
  FlutterNativeSplash.remove();

  // Start the app
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (_) => const MagicApp(),
    ),
  );
}

/// The main widget of this application
class MagicApp extends StatefulWidget {
  const MagicApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MagicAppState();

  /// Returns the state to trigger a refresh
  static MagicAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MagicAppState>();
}

class MagicAppState extends State<MagicApp> {
  /// Triggers a rebuild by calling [setState]
  void refreshApp() {
    _checkUserValidity();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _checkUserValidity();
  }

  /// Checks whether the logged in user still exists
  void _checkUserValidity() async {
    if (CommunicationHandler.isConnected) {
      List<MagicUser> users = await CommunicationHandler.getUsers();
      MagicUser activeUser = PreferencesAdapter.activeUser;

      // Check whether the user is still known to the backend
      for (MagicUser knownUser in users) {
        if (activeUser.id == knownUser.id) {
          return;
        }
      }

      // Otherwise, reset the user -> Take the user to the select page
      PreferencesAdapter.setActiveUser(const MagicUser());

      setState(() {});
    }
  }

  @override
  void dispose() {
    // Close the client connection to the raspberry pi
    CommunicationHandler.closeConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget = Container();
    if (PreferencesAdapter.isFirstUse) {
      // Show the introduction if it's the first time the user launched the app
      mainWidget = const IntroductionPage();
    } else {
      if (!CommunicationHandler.isConnected) {
        // Show the Connect screen, if no mirror is connected
        mainWidget = ConnectMirror(onSuccessfulConnection: () => refreshApp());
      } else {
        MagicUser user = PreferencesAdapter.activeUser;
        if (!user.isRealUser) {
          // Force the user to select a MagicUser if none is logged in
          mainWidget = IntroductionPage(
            showPages: IntroductionPages.user,
            onDone: refreshApp,
          );
        } else {
          // Show the main app layout
          mainWidget = const MagicHomePage();
        }
      }
    }

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
          locale: Locale(PreferencesAdapter.language),
          title: "Magic App",
          // Material wrapper is needed for some widgets to work
          home: Material(type: MaterialType.transparency, child: mainWidget),
          // Load the android themes
          material: (_, __) => MaterialAppData(
            theme: lightMaterialTheme,
            darkTheme: darkMaterialTheme,
            themeMode: PreferencesAdapter.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
          ),
          // Load the cupertino themes
          cupertino: (_, __) => CupertinoAppData(
            theme: PreferencesAdapter.isDarkMode
                ? darkCupertinoTheme
                : lightCupertinoTheme,
          ),
          useInheritedMediaQuery: true, // Needed because of DevicePreview
        ),
        // Selected the correct platform
        initialPlatform:
            PreferencesAdapter.isAltAppearance || !isMaterial(context)
                ? TargetPlatform.iOS
                : TargetPlatform.android,
      ),
    );
  }
}

/// The general layout of the app with a bottom navigation bar
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

    // Init the layout handler
    MirrorLayoutHandler.init();
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
    final List<TabItem> bottomNavigationList = [
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

    // The app layout consists of the content and navigation footer
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: centerWidget,
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
              items: bottomNavigationList,
              initialActiveIndex: _selectedNavigationIndex,
              onTap: _onMenuItemTapped,
            ),
          ),
        ],
      ),
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
  TextStyle textStyle(Color color, String? fontFamily) {
    return magicTextTheme.bodyText2!;
  }
}
