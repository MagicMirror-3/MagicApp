import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:magic_app/mirror/mirror_data.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/util/utility.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';

/// Handles the communication with the MagicController on the Raspberry pi via HTTP.
class CommunicationHandler {
  const CommunicationHandler._();

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
  }

  /// A (potential) persistent connection to the mirror
  static http.Client? _mirrorClient;

  /// Discovers devices on the local network and returns the IP-addresses of MagicMirrors
  static Future<List<String>> findLocalMirrors() {
    // Get the IP of the current device
    return NetworkInfo().getWifiIP().then((wifiIP) async {
      // Do the computation in a separate isolate to stop the UI freezing
      return await compute((String? wifiIP) async {
        List<String> mirrorList = [];

        if (wifiIP != null) {
          final String subnet = wifiIP.substring(0, wifiIP.lastIndexOf("."));
          print("Searching on subnet $subnet...");
          final hostStream = HostScanner.discover(subnet);

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
        } else {
          print("failed to retrieve IP");
        }
        return mirrorList;
      }, wifiIP);
    });
  }

  /// Checks whether the given [host] is a MagicMirror.
  ///
  /// It calls the route '/isMagicMirror' with a http get request.
  static Future<bool> isMagicMirror(String host) async {
    http.Response response = await _makeRequest(
      MagicRoutes.isMagicMirror,
      host: host,
    );

    return response.statusCode == 200;
  }

  /// Try connecting to the previously saved IP or discover devices on the network
  /// potentially being a network.
  ///
  /// If multiple mirrors are found, it returns a [List<String>] representing the
  /// IPs of every mirror in the local network. If only one is found, the [Future]
  /// returns nothing.
  static Future<void> connectToMirror(
      {bool autoConnect = false, String? mirrorIP}) async {
    String mirrorAddress = mirrorIP ??
        SharedPreferencesHandler.getValue(SettingKeys.mirrorAddress);

    // Try connecting to the saved address
    if (mirrorAddress.isNotEmpty) {
      _connected = await isMagicMirror(mirrorAddress);
    }

    if (autoConnect || _connected) {
      // Otherwise, start the local network discovery
      if (mirrorAddress.isEmpty || !_connected) {
        final List<String> foundDevices = await findLocalMirrors();

        if (foundDevices.length == 1 && autoConnect) {
          _connected = true;
          mirrorAddress = foundDevices.first;
        }
      }

      // Create a persistent client and save the mirror address
      _mirrorClient = http.Client();
      address = mirrorAddress;
    }
  }

  /// This method makes a request to the specified [route] and returns the response.
  ///
  /// [payload] can be both the query params of a GET request and the body of a
  /// POST request.
  /// If [host] is specified, this IP address will be used for the request. Otherwise,
  /// this method will fall back to [_mirrorClient].
  /// [timeout] defaults to 0.5 seconds.
  ///
  /// The response is of the class [_MagicResponse], which contains a JSON-formatted
  /// body by default.
  static Future<http.Response> _makeRequest(_MagicRoute route,
      {dynamic payload, String? host, Duration? timeout}) async {
    if (_mirrorClient == null && host == null) {
      throw ArgumentError(
          "Please provide a host name if the mirror is not connected yet!");
    }

    Uri targetURI = createRouteURI(route, host: host, getParams: payload);
    timeout ??= const Duration(milliseconds: 500);

    late http.Response response;
    switch (route.type) {
      case _RouteType.GET:
        if (host != null) {
          response = await http.get(targetURI).timeout(
                timeout,
                onTimeout: () => http.Response("timeout", 408),
              );
        } else {
          response = await _mirrorClient!.get(targetURI).timeout(
                timeout,
                onTimeout: () => http.Response("timeout", 408),
              );
        }

        break;
      case _RouteType.POST:
        if (host != null) {
          response = await http
              .post(
                targetURI,
                body: payload,
              )
              .timeout(
                timeout,
                onTimeout: () => http.Response("timeout", 408),
              );
        } else {
          response = await _mirrorClient!
              .post(
                targetURI,
                body: payload,
              )
              .timeout(
                timeout,
                onTimeout: () => http.Response("timeout", 408),
              );
        }
        break;
    }

    return response;
  }

  /// Creates an URI for a given [route] at the [host].
  ///
  /// [MagicRoutes] contains every supported route.
  ///
  /// The [host] param is optional and wil default to the [_address] field of
  /// this class.
  /// [getParams] are needed for a GET request with query params in the URI.
  static Uri createRouteURI(_MagicRoute route,
      {String? host, Map<String, dynamic>? getParams}) {
    host ??= _address;
    getParams ??= {};

    String uriString = "http://$host:$_port/${route.route}";

    // Check whether GET params are necessary and provided
    // POST routes don't need special treatment
    if (route.type == _RouteType.GET) {
      if (route.params != null && route.params!.isNotEmpty) {
        if (getParams.isNotEmpty) {
          // Construct the param string
          String paramString = "?";
          for (String paramName in route.params!) {
            paramString +=
                "$paramName=${Uri.encodeQueryComponent(getParams[paramName]!.toString())}";
          }

          uriString += paramString;
        } else {
          throw Error();
        }
      }
    }

    return Uri.parse(uriString);
  }

  /// Closes the persistent connection to the mirror.
  static void closeConnection() {
    _mirrorClient?.close();
    _connected = false;
  }

  // ---------- [Implementations for predefined routes] ---------- //
  // TODO: consider retrieving the userID from SharedPreferencesHandler

  /// Create a new user in the mirror database and returns whether the creation
  /// was successful.
  ///
  /// [images] should be a list of base64-encoded images.
  static Future<bool> createUser(String firstname, String surname,
      String password, List<String> images) async {
    return (await _makeRequest(
          MagicRoutes.createUser,
          payload: {
            "firstname": firstname,
            "surname": surname,
            "password": password,
            "images": images,
          },
        ))
            .statusCode ==
        201;
  }

  /// Gets all registered users
  static Future<List<MagicUser>> getUsers() async {
    List<dynamic>? users =
        (await _makeRequest(MagicRoutes.getUsers)).parseJson();

    return users != null
        ? users
            .map(
              (userMap) => MagicUser(
                userMap["user_id"],
                userMap["firstname"],
                userMap["surname"],
                "random string",
              ),
            )
            .toList()
        : [];
  }

  /// Updates the data of a given user identified by their [userID].
  static Future<bool> updateUserData(
      int userID, String firstname, String surname, String password) async {
    return (await _makeRequest(
          MagicRoutes.updateUser,
          payload: {
            "user_id": userID,
            "firstname": firstname,
            "surname": surname,
            "new_password": password,
          },
        ))
            .statusCode ==
        201;
  }

  /// Retrieve the mirror layout of the current user
  static Future<MirrorLayout?> getMirrorLayout(String username) async {
    http.Response response =
        await _makeRequest(MagicRoutes.getLayout, payload: {"user_id": 1});

    // print("Server responded with the body: ${response.body}");
    switch (response.statusCode) {
      case 200:
        return MirrorLayout.fromString(response.body);
      default:
        print("Invalid response: '${response.body}' (${response.statusCode})");
    }

    return null;
  }

  /// Updates the layout of the given user
  static Future<bool> updateLayout(int userID, MirrorLayout layout) async {
    return (await _makeRequest(
          MagicRoutes.setLayout,
          payload: {"user_id": userID.toString(), "layout": layout.toString()},
        ))
            .statusCode ==
        201;
  }

  /// Gets all available modules
  static Future<List<Module>> getModules() async {
    String moduleString = (await _makeRequest(
      MagicRoutes.getModules,
      payload: {"user_id": 1},
    ))
        .body;

    return modulesFromJSON(moduleString);
  }
}

/// Contains all valid routes a MagicMirror has
class MagicRoutes {
  const MagicRoutes._();

  static const isMagicMirror = _MagicRoute(route: "isMagicMirror");

  static const createUser = _MagicRoute(
    route: "createUser",
    params: [
      "firstname",
      "surname",
      "password",
      "current_layout",
      "images",
    ],
  );
  static const getUsers = _MagicRoute(route: "getUsers");
  static const updateUser = _MagicRoute(
    route: "updateUser",
    type: _RouteType.POST,
    params: [
      "user_id",
      "firstname",
      "surname",
      "new_password",
    ],
  );

  static const getLayout = _MagicRoute(route: "getLayout", params: ["user_id"]);
  static const setLayout = _MagicRoute(
    route: "setLayout",
    type: _RouteType.POST,
    params: ["user_id", "layout"],
  );

  static const getModules = _MagicRoute(
    route: "getModules",
    params: ["user_id"],
  );
}

/// Contains information about a route
class _MagicRoute {
  const _MagicRoute(
      {required this.route, this.type = _RouteType.GET, this.params});

  /// The name of the route
  final String route;

  /// The type of the route. Either GET or POST
  final _RouteType type;

  /// Every parameter the request has to contain
  final List<String>? params;
}

/// Contains all valid types of mirror routes
// ignore: constant_identifier_names
enum _RouteType { GET, POST }

/// Automatically parses the JSON in the body of the response.
/// A extension for {http.Response} with additional functionality.
extension _MagicResponseExtension on http.Response {
  T? parseJson<T>() {
    try {
      return jsonDecode(body) as T;
    } catch (e) {
      print("Error while parsing JSON: $e");
      print("The body was: '$body'");
      return null;
    }
  }
}
