import 'dart:async';

import 'package:flutter/services.dart';

import 'deeplink_platform_interface.dart';

class MethodChannelDeeplink extends DeeplinkPlatform {

  static const String _messagesChannel = 'com.quantam.deeplink/messages';
  static const String _eventsChannel = 'com.quantam.deeplink/events';

  static const _method = MethodChannel(_messagesChannel);
  static const _event = EventChannel(_eventsChannel);

  /// [getInitialAppLink] method call name
  static const String _getInitialAppLinkMethod = 'getInitialAppLink';

  /// [getLatestAppLink] method call name
  static const String _getLatestAppLinkMethod = 'getLatestAppLink';

  @override
  Future<Uri?> getInitialAppLink() async {
    final result = await getInitialAppLinkString();
    return result != null ? Uri.tryParse(result) : null;
  }

  @override
  Future<String?> getInitialAppLinkString() async {
    final link = await _method.invokeMethod<String?>(_getInitialAppLinkMethod);
    return link != null && link.isNotEmpty ? link : null;
  }

  @override
  Future<Uri?> getLatestAppLink() async {
    final result = await getLatestAppLinkString();
    return result != null ? Uri.tryParse(result) : null;
  }

  @override
  Future<String?> getLatestAppLinkString() async {
    final link = await _method.invokeMethod<String?>(_getLatestAppLinkMethod);
    return link != null && link.isNotEmpty ? link : null;
  }

  @override
  Stream<String> get stringLinkStream => _event
      .receiveBroadcastStream()
      .where((link) => link != null && link.isNotEmpty)
      .map<String>((dynamic link) => link as String);

  @override
  Stream<Uri> get uriLinkStream {
    return stringLinkStream.transform<Uri>(
      StreamTransformer<String, Uri>.fromHandlers(
        handleData: (String uri, EventSink<Uri> sink) {
          sink.add(Uri.parse(uri));
        },
      ),
    );
  }

  @override
  Stream<Uri> get allUriLinkStream async* {
    final initial = await getInitialAppLink();
    if (initial != null) yield initial;
    yield* uriLinkStream;
  }

  @override
  Stream<String> get allStringLinkStream async* {
    final initial = await getInitialAppLinkString();
    if (initial != null) yield initial;
    yield* stringLinkStream;
  }


}
