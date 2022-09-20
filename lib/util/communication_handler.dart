import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isolate_handler/isolate_handler.dart';
import 'package:magic_app/mirror/module.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/util/utility.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';

import '../mirror/mirror_layout_handler.dart';

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
    PreferencesAdapter.setMirrorAddress(address);
  }

  /// Get the currently logged in user
  static MagicUser get _localUser => PreferencesAdapter.activeUser;

  /// A (potential) persistent connection to the mirror
  static http.Client? _mirrorClient;

  /// Executes the network discovery
  @pragma('vm:entry-point')
  static _mirrorSearchIsolate(Map<String, dynamic> context) {
    final messenger = HandledIsolate.initialize(context);

    // Start the search once the ip is received
    messenger.listen((wifiIP) async {
      // Init ping on iOS for mirror connection
      DartPingIOS.register();

      List<String> mirrorList = [];

      if (wifiIP != null) {
        final String subnet = wifiIP!.substring(0, wifiIP!.lastIndexOf("."));
        // print("Searching on subnet $subnet...");

        // TODO: Maybe display the progress as some sort of bar or whatever
        final mirrorHostStream =
            HostScanner.scanDevicesForSinglePort(subnet, _port);

        await for (ActiveHost mirrorHost in mirrorHostStream) {
          final devicePort = mirrorHost.openPort[0];

          if (devicePort.isOpen) {
            bool isMirror = await isMagicMirror(mirrorHost.address);

            if (isMirror) {
              // print("This is indeed a mirror!");
              mirrorList.add(mirrorHost.address);
            }
          }
        }
      } else {
        // TODO: Handle error
        print("failed to retrieve IP");
      }

      // Send the list back to the main isolate
      messenger.send(mirrorList);
    });
  }

  //  TODO: Beautify this into a stream
  /// Discovers devices on the local network and returns the IP-addresses of MagicMirrors
  static Future<List<String>> findLocalMirrors() {
    // Get the IP of the current device
    return NetworkInfo().getWifiIP().then((ip) async {
      List<String> foundMirrors = [];

      // Do the computation in a separate isolate to stop the UI freezing
      final isolateHandler = IsolateHandler();

      final receiverPort = ReceivePort();
      isolateHandler.spawn(_mirrorSearchIsolate,
          onReceive: (List<String> mirrorList) {
            foundMirrors = mirrorList;

            // Trigger the await statement
            receiverPort.sendPort.send("exit");

            // Kill the isolate
            isolateHandler.kill("MirrorSearch", priority: Isolate.immediate);
          },
          name: "MirrorSearch",
          onInitialized: () => isolateHandler.send(ip, to: "MirrorSearch"));

      // Wait for the search to complete
      await receiverPort.first;

      return foundMirrors;
    });
  }

  /// Checks whether the given [host] is a MagicMirror.
  ///
  /// It calls the route '/isMagicMirror' with a http get request.
  static Future<bool> isMagicMirror(String host) async {
    http.Response response = await _makeRequest(
      MagicRoutes.isMagicMirror,
      host: host,
      timeout: const Duration(milliseconds: 500),
    );

    return response.statusCode == 200;
  }

  /// Try connecting to the previously saved IP or discover devices on the network
  /// potentially being a network.
  ///
  /// Returns true if a mirror was connected.
  static Future<bool> connectToMirror({
    bool autoConnect = false,
    String? mirrorIP,
  }) async {
    String mirrorAddress = mirrorIP ?? PreferencesAdapter.mirrorAddress;

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
        } else {
          return false;
        }
      }

      // Create a persistent client and save the mirror address
      _mirrorClient = http.Client();
      address = mirrorAddress;
      return true;
    }

    return false;
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
  static Future<http.Response> _makeRequest(
    MagicRoute route, {
    dynamic payload,
    String? host,
    Duration? timeout,
  }) async {
    if (_mirrorClient == null && host == null) {
      throw ArgumentError(
          "Please provide a host name if the mirror is not connected yet!");
    }

    Uri targetURI = createRouteURI(route, host: host, getParams: payload);
    timeout ??= const Duration(seconds: 2);

    late http.Response response;
    switch (route.type) {
      case RouteType.GET:
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
      case RouteType.POST:
        // Convert every value of the payload to a string to prevent errors
        payload = payload.map((key, value) => MapEntry(key, value.toString()));

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
  static Uri createRouteURI(
    MagicRoute route, {
    String? host,
    Map<String, dynamic>? getParams,
  }) {
    host ??= _address;
    getParams ??= {};

    // Currently, the MM² is not using HTTPS and therefore has to be accessed via HTTP
    String uriString = "http://$host:$_port/${route.route}";

    // Check whether GET params are necessary and provided
    // POST routes don't need special treatment
    if (route.type == RouteType.GET) {
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

  /// Create a new user in the mirror database and returns the new user id or -1
  /// if failed.
  /// [images] should be a list of base64-encoded images.
  static Future<int> createUser(
    String firstname,
    String lastname,
    List<String> images,
  ) async {
    assert(_connected);

    final response = await _makeRequest(
      MagicRoutes.createUser,
      payload: {
        "firstname": firstname,
        "lastname": lastname,
        "images": images,
      },
      timeout: const Duration(seconds: 60),
    );

    if (response.statusCode == 201) {
      return int.parse(response.body);
    }
    return -1;
  }

  /// Gets all registered users
  static Future<List<MagicUser>> getUsers() async {
    assert(_connected);

    List<dynamic>? users =
        (await _makeRequest(MagicRoutes.getUsers)).parseJson();

    return users != null
        ? users
            .map(
              (userMap) => MagicUser(
                id: userMap["user_id"] ?? -1,
                firstName: userMap["firstname"] ?? "",
                lastName: userMap["lastname"] ?? "",
              ),
            )
            .toList()
        : [];
  }

  /// Updates the data of the currently logged in user
  ///
  /// Throws [ArgumentError], if no user is logged in
  static Future<bool> updateUserData() async {
    assert(_connected);

    if (_localUser.isRealUser) {
      return (await _makeRequest(
            MagicRoutes.updateUser,
            payload: {
              "user_id": _localUser.id,
              "firstname": _localUser.firstName,
              "lastname": _localUser.lastName,
            },
          ))
              .statusCode ==
          201;
    } else {
      throw ArgumentError("There is no user logged in at the moment!");
    }
  }

  /// Delete the currently logged in user
  ///
  static Future<bool> deleteUser() async {
    assert(_connected);

    if (_localUser.isRealUser) {
      return (await _makeRequest(
            MagicRoutes.deleteUser,
            payload: {
              "user_id": _localUser.id,
            },
          ))
              .statusCode ==
          201;
    } else {
      throw ArgumentError("User could not be deleted!");
    }
  }

  /// Retrieve the mirror layout of the current user
  ///
  /// Throws [ArgumentError], if no user is logged in
  static Future<MirrorLayout?> getMirrorLayout() async {
    assert(_connected);

    if (_localUser.isRealUser) {
      http.Response response = await _makeRequest(
        MagicRoutes.getLayout,
        payload: {
          "user_id": _localUser.id,
        },
      );

      // print("Server responded with the body: ${response.body}");
      switch (response.statusCode) {
        case 200:
          return MirrorLayout.fromString(response.body);
        default:
          debugPrint(
              "Invalid response: '${response.body}' (${response.statusCode})");
      }
    } else {
      throw ArgumentError("There is no user logged in at the moment!");
    }

    return null;
  }

  /// Updates the layout of the current user
  ///
  /// Throws [ArgumentError], if no user is logged in
  static Future<bool> updateLayout(MirrorLayout layout) async {
    assert(_connected);

    if (_localUser.isRealUser) {
      return (await _makeRequest(
            MagicRoutes.setLayout,
            payload: {"user_id": _localUser.id, "layout": layout.toString()},
          ))
              .statusCode ==
          201;
    } else {
      throw ArgumentError("There is no user logged in at the moment!");
    }
  }

  /// Gets all available modules
  static Future<List<Module>> getModules() async {
    assert(_connected);

    List<Module> modules = [];
    if (_localUser.isRealUser) {
      String moduleString = (await _makeRequest(
        MagicRoutes.getModules,
        payload: {"user_id": _localUser.id},
        timeout: const Duration(seconds: 1),
      ))
          .body;

      modules = modulesFromJSON(moduleString);
    }

    return modules;
  }

  /// Updates the configuration of a given module in the catalog
  static Future<bool> updateModuleConfiguration(Module module) async {
    if (_localUser.isRealUser) {
      return (await _makeRequest(
            MagicRoutes.updateModuleConfiguration,
            payload: {
              "user_id": _localUser.id,
              "module": module.name,
              "configuration": json.encode(module.config ?? {}),
            },
          ))
              .statusCode ==
          201;
    } else {
      throw ArgumentError("There is no user logged in at the moment!");
    }
  }
}

/// Contains all valid routes a MagicMirror has
class MagicRoutes {
  // No instantiation wanted
  const MagicRoutes._();

  /// Needed to check whether a device is a MagicMirror
  static const isMagicMirror = MagicRoute(route: "isMagicMirror");

  /// Registers a new user
  static const createUser = MagicRoute(
    route: "createUser",
    type: RouteType.POST,
    params: [
      "firstname",
      "lastname",
      "images",
    ],
  );

  /// Gets all registered users
  static const getUsers = MagicRoute(route: "getUsers");

  /// Updates the data of a user
  static const updateUser = MagicRoute(
    route: "updateUser",
    type: RouteType.POST,
    params: [
      "user_id",
      "firstname",
      "lastname",
    ],
  );

  /// Deletes a user
  static const deleteUser = MagicRoute(
    route: "deleteUser",
    type: RouteType.POST,
    params: ["user_id"],
  );

  /// Gets the layout of a given user
  static const getLayout = MagicRoute(route: "getLayout", params: ["user_id"]);

  /// Updates the layout of a user
  static const setLayout = MagicRoute(
    route: "setLayout",
    type: RouteType.POST,
    params: ["user_id", "layout"],
  );

  /// Gets all available modules
  static const getModules = MagicRoute(
    route: "getModules",
    params: ["user_id"],
  );

  /// Updates the configuration of a module in the catalog
  static const updateModuleConfiguration = MagicRoute(
    route: "updateModuleConfiguration",
    type: RouteType.POST,
    params: ["user_id", "module", "configuration"],
  );
}

/// Contains information about a route
class MagicRoute {
  const MagicRoute({
    required this.route,
    this.type = RouteType.GET,
    this.params,
  });

  /// The name of the route
  final String route;

  /// The type of the route. Either GET or POST
  final RouteType type;

  /// Every parameter the request has to contain
  final List<String>? params;
}

/// Contains all valid types of mirror routes
// ignore: constant_identifier_names
enum RouteType { GET, POST }

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
