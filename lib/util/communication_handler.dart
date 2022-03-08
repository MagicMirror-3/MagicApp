import 'package:http/http.dart' as http;
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';

/// Handles the communication with the MagicController on the Raspberry pi via HTTP.
class CommunicationHandler {
  /// The port the mirror backend runs on
  static const int _port = 5000;

  /// Whether a mirror is connected
  static bool _connected = false;

  /// Whether a mirror is connected
  static bool get isConnected => _connected;

  /// The IP-address of the mirror
  static String? _address;

  /// Saves the given address both locally and in the SharedPreferences.
  static set address(String address) {
    _address = address;
    SharedPreferencesHandler.saveValue(
      SettingKeys.mirrorAddress,
      address,
    );
    print("Address $address saved");
  }

  /// A (potential) persistent connection to the mirror
  static late http.Client _mirrorClient;

  /// Discovers devices on the local network and returns the IP-addresses of MagicMirrors
  static Future<List<String>> findLocalMirrors() async {
    final String? wifiIP = await NetworkInfo().getWifiIP();

    if (wifiIP != null) {
      final String subnet = wifiIP.substring(0, wifiIP.lastIndexOf("."));
      print("Searching on subnet $subnet...");
      final hostStream = HostScanner.discover(subnet);

      List<String> mirrorList = [];

      // Go through every device
      await for (ActiveHost host in hostStream) {
        // Check if the desired port is open
        if ((await PortScanner.isOpen(host.ip, _port)).isOpen) {
          // Check if the device has magic mirror routes
          print("device found at ${host.ip}. Checking routes...");
          bool isMirror = await isMagicMirror(host.ip);

          if (isMirror) {
            print("This is indeed a mirror!");
            mirrorList.add(host.ip);
          } else {
            print("this device does not have the mirror routes");
          }
        }
      }

      return mirrorList;
    } else {
      print("failed to retrieve IP");
      return [];
    }
  }

  /// Checks whether the given [host] is a MagicMirror.
  ///
  /// It calls the route '/isMagicMirror' with a http get request.
  static Future<bool> isMagicMirror(String host) async {
    http.Response response = await http
        .get(
          createRouteURI(_MagicRoutes.isMagicMirror, host),
        )
        .timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => http.Response("timeout", 408),
        );

    return response.statusCode == 200;
  }

  /// Try connecting to the previously saved IP or discover devices on the network
  /// potentially being a network.
  ///
  /// If multiple mirrors are found, it returns a [List<String>] representing the
  /// IPs of every mirror in the local network. If only one is found, the [Future]
  /// returns nothing.
  static Future<dynamic> connectToMirror() async {
    String mirrorAddress =
        SharedPreferencesHandler.getValue(SettingKeys.mirrorAddress);

    print("Saved Address: $mirrorAddress");
    if (mirrorAddress.isNotEmpty) {
      _connected = await isMagicMirror(mirrorAddress);
    }

    if (mirrorAddress.isEmpty || !_connected) {
      final List<String> foundDevices = await findLocalMirrors();
      print("all devices: $foundDevices");

      if (foundDevices.length == 1) {
        print("Thankfully, only one mirror found: ");
        _connected = true;
        mirrorAddress = foundDevices.first;
      } else {
        print("somehow make the user choose");
        return foundDevices;
      }
    }

    // Create a persistent client and save the mirror address
    _mirrorClient = http.Client();
    address = mirrorAddress;
  }

  /// Creates an URI for a given [route] at the [host].
  ///
  /// [_MagicRoutes] contains every supported route.
  ///
  /// The [host] param is optional and wil default to the [_address] field of
  /// this class.
  static Uri createRouteURI(_MagicRoute route, String? host) {
    host ??= _address;

    return Uri.parse("http://$host:$_port/${route.route}");
  }

  /// Closes the persistent connection to the mirror.
  static void closeConnection() {
    _mirrorClient.close();
  }
}

/// Contains all valid routes a MagicMirror has
class _MagicRoutes {
  static const _MagicRoute isMagicMirror = _MagicRoute(route: "isMagicMirror");
  static const _MagicRoute createUser = _MagicRoute(
    route: "createUser",
    params: [
      "name",
    ],
  );
}

/// Contains information about a route
class _MagicRoute {
  const _MagicRoute({required this.route, this.params});

  /// The name of the route
  final String route;

  /// Every parameter the request has to contain
  final List<String>? params;
}
