import 'package:AnalyticsGenWeb/Pages/EventListPage.dart';
import 'package:AnalyticsGenWeb/Routing/FluroRouter.dart';
import 'package:AnalyticsGenWeb/Views/SplitView.dart';
import 'package:flutter/material.dart';

void main() {
  FluroRouter.setupRouter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'events',
      onGenerateRoute: FluroRouter.router.generator,
    );
  }
}
