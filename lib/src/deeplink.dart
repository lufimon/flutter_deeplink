
import 'deeplink_platform_interface.dart';

class Deeplink extends DeeplinkPlatform {
  Deeplink();

  @override
  Future<Uri?> getInitialAppLink() {
    return DeeplinkPlatform.instance.getInitialAppLink();
  }

  @override
  Future<String?> getInitialAppLinkString() async {
    return DeeplinkPlatform.instance.getInitialAppLinkString();
  }

  @override
  Future<Uri?> getLatestAppLink() async {
    return DeeplinkPlatform.instance.getLatestAppLink();
  }

  @override
  Future<String?> getLatestAppLinkString() async {
    return DeeplinkPlatform.instance.getLatestAppLinkString();
  }

  @override
  Stream<String> get stringLinkStream {
    return DeeplinkPlatform.instance.stringLinkStream;
  }

  @override
  Stream<Uri> get uriLinkStream {
    return DeeplinkPlatform.instance.uriLinkStream;
  }

  @override
  Stream<String> get allStringLinkStream {
    return DeeplinkPlatform.instance.allStringLinkStream;
  }

  @override
  Stream<Uri> get allUriLinkStream {
    return DeeplinkPlatform.instance.allUriLinkStream;
  }
}
