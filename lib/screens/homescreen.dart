import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';

import 'package:sip_ua_phone/screens/register.dart';
import 'package:sip_ua_phone/screens/callscreen.dart';

class HomeScreen extends StatefulWidget {
  final SIPUAHelper? _helper;
  static String id = 'home_screen';
  const HomeScreen(this._helper, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements SipUaHelperListener {
  String? _dest;
  SIPUAHelper? get helper => widget._helper;
  TextEditingController? _textController;
  late SharedPreferences _preferences;

  String? receivedMsg;

  @override
  initState() {
    super.initState();
    receivedMsg = "";
    _bindEventListeners();
    _loadSettings();
  }

  void _loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
    _dest = _preferences.getString('dest') ?? 'sip:hello_jssip@tryit.jssip.net';
    _textController = TextEditingController(text: _dest);
    _textController!.text = _dest!;

    setState(() {});
  }

  void _bindEventListeners() {
    helper!.addSipUaHelperListener(this);
  }

  Future<Widget?> _handleCall(BuildContext context,
      [bool voiceOnly = false]) async {
    var dest = _textController?.text;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await Permission.microphone.request();
      await Permission.camera.request();
    }
    if (dest == null || dest.isEmpty) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Target is empty.'),
            content: Text('Please enter a SIP URI or username!'),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return null;
    }

    final mediaConstraints = <String, dynamic>{'audio': true, 'video': true};

    MediaStream mediaStream;

    if (kIsWeb && !voiceOnly) {
      mediaStream =
      await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      mediaConstraints['video'] = false;
      MediaStream userStream =
      await navigator.mediaDevices.getUserMedia(mediaConstraints);
      mediaStream.addTrack(userStream.getAudioTracks()[0], addToNative: true);
    } else {
      mediaConstraints['video'] = !voiceOnly;
      mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    }

    helper!.call(dest, voiceonly: voiceOnly, mediaStream: mediaStream);
    _preferences.setString('dest', dest);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    const int tabsCount = 3;

    return DefaultTabController(
      initialIndex: 0,
      length: tabsCount,
      child: SafeArea(
        child: Scaffold(
          /*drawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('Drawer Header'),
                ),
                ListTile(
                  title: const Text('Accounts'),
                  onTap: () {
                    print(1);
                  },
                ),
                ListTile(
                  title: const Text('About'),
                  onTap: () {
                    print(1);
                  },
                ),
                ListTile(
                  title: const Text('Quit'),
                  onTap: () {
                    print(1);
                  },
                ),
              ],
            ),
          ),*/
          appBar: AppBar(
            title: const Text('SIP Phone'),
            actions: [
              CupertinoButton(
                onPressed: () {
                  Navigator.pushNamed(context, RegisterWidget.id);
                },
                padding: EdgeInsetsGeometry.lerp(
                  EdgeInsets.zero,
                  EdgeInsets.zero,
                  0.0,
                ),
                child: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
              ),
              CupertinoButton(
                onPressed: () {
                  print(115);
                },
                padding: EdgeInsetsGeometry.lerp(
                  EdgeInsets.zero,
                  EdgeInsets.zero,
                  0.0,
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
              CupertinoButton(
                onPressed: () {
                  print(11);
                },
                padding: EdgeInsetsGeometry.lerp(
                  EdgeInsets.zero,
                  EdgeInsets.zero,
                  0.0,
                ),
                child: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
              ),
            ],
            notificationPredicate: (ScrollNotification notification) {
              return notification.depth == 1;
            },
            backgroundColor: Colors.black87,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
            scrolledUnderElevation: 4.0,
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(
                    Icons.call,
                  ),
                  child: Text(
                    'Contacts',
                    style: TextStyle(
                    ),
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.history,
                  ),
                  child: Text(
                    'History',
                    style: TextStyle(
                    ),
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.message,
                  ),
                  child: Text(
                    'Messages',
                    style: TextStyle(
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              ListView.builder(
                itemCount: 25,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    tileColor: index.isOdd ? oddItemColor : evenItemColor,
                    title: Text('h $index'),
                  );
                },
              ),
              ListView.builder(
                itemCount: 25,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    tileColor: index.isOdd ? oddItemColor : evenItemColor,
                    title: Text('i $index'),
                  );
                },
              ),
              ListView.builder(
                itemCount: 25,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    tileColor: index.isOdd ? oddItemColor : evenItemColor,
                    title: Text('t $index'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    setState(() {});
  }

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void callStateChanged(Call call, CallState callState) {
    print("-------111111111--------");
    if (callState.state == CallStateEnum.CALL_INITIATION) {
      print("-------22222222222222--------");
      Navigator.pushNamed(context, CallScreenWidget.id, arguments: call);
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    //Save the incoming message to DB
    String? msgBody = msg.request.body as String?;
    setState(() {
      // receivedMsg = msgBody;
    });
  }

  @override
  void onNewNotify(Notify ntf) {

  }
}


