// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'my_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

double bottonesize = 0.0;
String username = "";
String roomcode = "";

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

keyboarsize(isKeyboard) {
  if (isKeyboard) {
    bottonesize = 0.7;
  } else {
    bottonesize = 0.4;
  }
}

class _HomeState extends State<Home> {
  final _username = TextEditingController();
  final _roomcode = TextEditingController();
  String? deviceid;
  final _channel =
      WebSocketChannel.connect(Uri.parse('ws://instagram.ns0.it:62181'));

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      var wDeviceInfo = await deviceInfo.webBrowserInfo;
      return wDeviceInfo.appCodeName; // ID WEB

    }
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  void initDevInfo() async {
    deviceid = await _getId();
  }

  @override
  void initState() {
    super.initState();
    initDevInfo();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    keyboarsize(isKeyboard);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text("HI!!"),
      ),
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.blue,
            Colors.purple,
            Colors.red,
          ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
          child: Center(
            child: Column(
              children: [
                StreamBuilder(
                  stream: _channel.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      print('${snapshot.data}');

                      try {
                        Map<String, dynamic> data =
                            jsonDecode('${snapshot.data}');

                        if (data['cmd'] == "player_list_update") {
                          print("LIST OF PLAYERS:" +
                              data['player_list'].toString()); // is a array
                        }
                        if (data['cmd'] == "start") {
                        
                          // start the game
                        }
                        if (data['cmd'] == "stats") {
                        
                          // statistics of the game
                        }
                        if (data['cmd'] == "stop") {
                        
                          // end of the game
                        }
                      } catch (e) {
                        print("ERROR:" + e.toString());
                      }
                    }
                    return Text('');
                  },
                ),
                Flexible(
                    child: FractionallySizedBox(
                  heightFactor: 1,
                )),
                Container(padding: EdgeInsets.all(25)),
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: 0.6,
                    widthFactor: 0.8,
                    child: TextField(
                      controller: _username,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        hintText: 'Enter your username',
                      ),
                    ),
                  ),
                ),
                if (isKeyboard) Container(padding: EdgeInsets.all(15)),
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: 0.6,
                    widthFactor: 0.8,
                    child: TextField(
                      controller: _roomcode,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        hintText: "Enter your room's code",
                      ),
                    ),
                  ),
                ),
                if (isKeyboard) Container(padding: EdgeInsets.all(15)),
                Flexible(
                    child: FractionallySizedBox(
                        heightFactor: bottonesize,
                        widthFactor: 0.6,
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Mybutton("Join", () {
                              setState(() {
                                username = _username.text;
                                roomcode = _roomcode.text;
                                print("username: " + username);
                                print("roomcode: " + roomcode);
                              });
                              _join();
                            })))),
              ],
            ),
          )),
    );
  }

  void _join() {
    if (_username.text.isNotEmpty) {
      var obj = {
        'cmd': "request_to_join",
        'player': _username.text,
        'room': _roomcode.text,
        'device': deviceid
      };
      _channel.sink
          .add(JsonEncoder().convert(obj)); // convert into a JSON STRING
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
