import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription _intentDataStreamSubscription1;
  StreamSubscription _intentDataStreamSubscription2;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription1 = ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value?.isNotEmpty == true) {
        openThatFile(value.first.path);
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value?.isNotEmpty == true) {
        openThatFile(value.first.path);
      }
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription2 = ReceiveSharingIntent.getTextStream().listen((String value) {
      openThatFile(value);
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      if (value != null) {
        openThatFile(value);
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription1.cancel();
    _intentDataStreamSubscription2.cancel();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Centhe middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> openThatFile(String rawPath) async {
    if (rawPath == null) return;
    final decodedComponent = Uri.decodeComponent(rawPath);

    File file;
    if (Platform.isAndroid) {
      final filePath = await FlutterAbsolutePath.getAbsolutePath(decodedComponent);
      if (filePath == null) {
        return;
      }
      file = File(filePath);
    } else {
      file = File.fromUri(Uri.parse(decodedComponent));
    }
    print(file.existsSync());
  }
}
