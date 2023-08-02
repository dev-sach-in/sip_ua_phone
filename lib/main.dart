import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sip_ua/sip_ua.dart';

import 'package:sip_ua_phone/screens/register.dart';
import 'package:sip_ua_phone/screens/callscreen.dart';
import 'package:sip_ua_phone/screens/dialpad.dart';
import 'package:sip_ua_phone/screens/homescreen.dart';


void main() {
  if (WebRTC.platformIsDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
  runApp(MyApp());
}

typedef PageContentBuilder = Widget Function([SIPUAHelper? helper, Object? arguments]);

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final SIPUAHelper _helper = SIPUAHelper();
  Map<String, PageContentBuilder> routes = {
    HomeScreen.id: ([SIPUAHelper? helper, Object? arguments]) => HomeScreen(helper),
    DialPadWidget.id: ([SIPUAHelper? helper, Object? arguments]) => DialPadWidget(helper),
    RegisterWidget.id: ([SIPUAHelper? helper, Object? arguments]) =>
        RegisterWidget(helper),
    CallScreenWidget.id: ([SIPUAHelper? helper, Object? arguments]) =>
        CallScreenWidget(helper, arguments as Call?),
  };

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final PageContentBuilder? pageContentBuilder = routes[name!];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        final Route route = MaterialPageRoute<Widget>(
            builder: (context) =>
                pageContentBuilder(_helper, settings.arguments));
        return route;
      } else {
        final Route route = MaterialPageRoute<Widget>(
            builder: (context) => pageContentBuilder(_helper));
        return route;
      }
    }
    return null;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      initialRoute: HomeScreen.id,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}


