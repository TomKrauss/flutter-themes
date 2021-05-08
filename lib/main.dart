import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(ThemeDataWidget(child: DemoApplication()));
}

///
/// An inherited widget containing a stream of themeData objects to be listened to
/// in the home widget.
///
class ThemeDataWidget extends InheritedWidget {
  final StreamController<ThemeData> themeDataController = BehaviorSubject.seeded(ThemeData(primarySwatch: Colors.blue));

  ThemeDataWidget({Key? key, required Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return themeDataController != (oldWidget as ThemeDataWidget).themeDataController;
  }

  static ThemeDataWidget _contextWidget(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeDataWidget>()!;

  static StreamController<ThemeData> themeStreamController(BuildContext context) =>
      _contextWidget(context).themeDataController;
}

class DemoApplication extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ThemeDataWidget.themeStreamController(context).stream,
        builder: (context, snapshot) {
          ThemeData data = snapshot.data != null ? snapshot.data as ThemeData : ThemeData(primarySwatch: Colors.blue);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: data,
            home: MyHomePage(title: 'Flutter dynamic Themes Demo'),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ThemeData> _themes = [
    ThemeData(primarySwatch: Colors.blue),
    ThemeData(primarySwatch: Colors.amber),
    ThemeData(primarySwatch: Colors.red, scaffoldBackgroundColor: Colors.yellow),
    ThemeData(
        primarySwatch: Colors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(padding: EdgeInsets.all(20)))),
    // the following two themes cause a bogus message being logged. For details refer to: https://github.com/flutter/flutter/issues/56639
    ThemeData.dark().copyWith(
      primaryColor: Colors.grey,
    ),
    ThemeData.dark().copyWith(
        primaryColor: Colors.pink,
        textTheme: TextTheme(
            headline2: TextStyle(color: Colors.greenAccent, fontSize: 30),
            bodyText1: TextStyle(color: Colors.yellowAccent, fontSize: 22, shadows: [
              Shadow(
                offset: Offset(10.0, 10.0),
                blurRadius: 3.0,
                color: Colors.red,
              )
            ]))),
  ];
  int _currentThemeIdx = 0;

  void _changeTheme() {
    _currentThemeIdx = (_currentThemeIdx + 1) % _themes.length;
    ThemeDataWidget.themeStreamController(context).add(_themes[_currentThemeIdx]);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Headline", style: Theme.of(context).textTheme.headline2),
            SizedBox(height: 10),
            Text("You've selected theme number $_currentThemeIdx", style: Theme.of(context).textTheme.bodyText1),
            SizedBox(height: 15),
            ElevatedButton(
                onPressed: _showMessage,
                child: Text(
                  "Say hello",
                  textScaleFactor: 2,
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _changeTheme,
        tooltip: 'Change Theme',
        child: Icon(Icons.palette),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showMessage() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hello")));
  }
}
