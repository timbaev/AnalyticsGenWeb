import 'package:AnalyticsGenWeb/Pages/EventFormPage.dart';
import 'package:AnalyticsGenWeb/Pages/EventListPage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class FluroRouter {
  static Router router = Router();

  static Handler _eventListHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          EventListPage());

  static Handler _eventHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
        return EventFormPage(eventID: params['eventID'][0]);
      });

  static Handler _newEventHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return EventFormPage();
    });

  static void setupRouter() {
    router.define(
        "events",
        handler: _eventListHandler,
        transitionType: TransitionType.fadeIn
    );

    router.define(
        "events/:eventID",
        handler: _eventHandler,
        transitionType: TransitionType.fadeIn
    );

    router.define(
        "new/event",
        handler: _newEventHandler,
        transitionType: TransitionType.fadeIn
    );
  }
}
