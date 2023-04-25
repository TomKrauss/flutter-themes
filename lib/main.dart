import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(ThemeControllerWidget(child: DemoApplication()));
}

///
/// Stateful widget providing the stream to the theme data.
///
class ThemeControllerWidget extends StatefulWidget {
  final Widget child;
  ThemeControllerWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeControllerWidgetState();
}

class ThemeControllerWidgetState extends State<ThemeControllerWidget> {
  final StreamController<ThemeData> themeDataController = BehaviorSubject.seeded(ThemeData(primarySwatch: Colors.blue));

  @override
  void dispose() {
    super.dispose();
    themeDataController.close();
  }
  @override
  Widget build(BuildContext context) {
    return ThemeDataWidget(child: widget.child, themeDataController: themeDataController);
  }
}

///
/// An inherited widget containing a stream of themeData objects to be listened to
/// in the home widget.
///
class ThemeDataWidget extends InheritedWidget {
  final StreamController<ThemeData> themeDataController;
  ThemeDataWidget({Key? key, required Widget child, required this.themeDataController}) : super(key: key, child: child);

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
          ThemeData data = snapshot.data != null ? snapshot.data as ThemeData : ThemeData(primarySwatch: Colors.blue, useMaterial3: true);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: data,
            home: MyHomePage(title: 'Flutter dynamic Theme Demo'),
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
    ThemeData(useMaterial3: true, colorSchemeSeed: Colors.pink),
    ThemeData(useMaterial3: true, primarySwatch: Colors.amber),
    ThemeData(useMaterial3: true, primarySwatch: Colors.red, scaffoldBackgroundColor: Colors.yellow),
    ThemeData(
        primarySwatch: Colors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(padding: EdgeInsets.all(20)))),
    // the following two themes cause a bogus message being logged. For details refer to: https://github.com/flutter/flutter/issues/56639
    ThemeData.dark().copyWith(
      primaryColor: Colors.grey,
    ),
    ThemeData.dark().copyWith(
        primaryColor: Colors.pink,
        snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.deepPurple,
            contentTextStyle: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold)),
        textTheme: TextTheme(
            displayMedium: TextStyle(color: Colors.greenAccent, fontSize: 30),
            bodyLarge: TextStyle(color: Colors.yellowAccent, fontSize: 22, shadows: [
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
            Text("Flutter Theme Demo", style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Press the FAB Button on the lower right to switch themes ->",
                  style: Theme.of(context).textTheme.bodyMedium),
              Icon(Icons.palette)
            ]),
            const SizedBox(height: 10),
            Text("You've selected theme number $_currentThemeIdx", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: _showMessage,
                child: Text(
                  "Say hello",
                  textScaleFactor: 2,
                )),
            const SizedBox(height: 15),
            OutlinedButton(
                onPressed: _showMessage,
                child: Text(
                  "Outlined Button",
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
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hello")));
  }
}
