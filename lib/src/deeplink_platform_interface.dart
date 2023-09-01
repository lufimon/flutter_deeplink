import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'deeplink_method_channel.dart';

typedef OnAppLinkFunction = void Function(Uri uri, String stringUri);

abstract class DeeplinkPlatform extends PlatformInterface {

  DeeplinkPlatform() : super(token: _token);

  static final Object _token = Object();

  static DeeplinkPlatform _instance = MethodChannelDeeplink();

  static DeeplinkPlatform get instance => _instance;

  static set instance(DeeplinkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Uri?> getInitialAppLink() => throw UnimplementedError(
    'getInitialAppLink() not implemented on the current platform.',
  );

  Future<String?> getInitialAppLinkString() => throw UnimplementedError(
    'getInitialAppLinkString not implemented on the current platform.',
  );

  Future<Uri?> getLatestAppLink() => throw UnimplementedError(
    'getLatestAppLink not implemented on the current platform.',
  );

  Future<String?> getLatestAppLinkString() {
    throw UnimplementedError(
      'getLatestAppLinkString not implemented on the current platform.',
    );
  }

  Stream<String> get stringLinkStream => throw UnimplementedError(
      'stringUriStream not implemented on the current platform.');

  Stream<Uri> get uriLinkStream => throw UnimplementedError(
      'uriStream not implemented on the current platform.');

  Stream<Uri> get allUriLinkStream => throw UnimplementedError(
      'allUriLinkStream not implemented on the current platform.');

  Stream<String> get allStringLinkStream => throw UnimplementedError(
      'allStringLinkStream not implemented on the current platform.');
}
