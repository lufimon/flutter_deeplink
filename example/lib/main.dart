import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:deeplink/deeplink.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late Deeplink _deepLink;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLink();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initDeepLink() async {
    _deepLink = Deeplink();

    // Check initial link if app was in cold state (terminated)
    final deepLink = await _deepLink.getInitialAppLink();
    if (deepLink != null) {
      if (kDebugMode) {
        print('getInitialAppLink: $deepLink');
      }
      openAppLink(deepLink);
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _deepLink.uriLinkStream.listen((uri) {
      if (kDebugMode) {
        print('onAppLink: $uri');
      }
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    _navigatorKey.currentState?.pushNamed(uri.fragment);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        Widget routeWidget = defaultScreen();

        // Mimic web routing
        final routeName = settings.name;
        if (routeName != null) {
          if (routeName.startsWith('/book/')) {
            // Navigated to /book/:id
            routeWidget = customScreen(
              routeName.substring(routeName.indexOf('/book/')),
            );
          } else if (routeName == '/book') {
            // Navigated to /book without other parameters
            routeWidget = customScreen("None");
          }
        }

        return MaterialPageRoute(
          builder: (context) => routeWidget,
          settings: settings,
          fullscreenDialog: true,
        );
      },
    );
  }

  Widget defaultScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Default Screen')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText('''
            Launch an intent to get to the second screen.

            On web:
            http://localhost:<port>/#/book/1 for example.

            On windows & macOS, open your browser:
            sample://foo/#/book/hello-deep-linking

            This example code triggers new page from URL fragment.
            '''),
          ],
        ),
      ),
    );
  }

  Widget customScreen(String bookId) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Center(child: Text('Opened with parameter: $bookId')),
    );
  }
}
