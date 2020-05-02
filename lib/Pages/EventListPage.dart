import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:AnalyticsGenWeb/Models/Event.dart';
import 'package:flutter/cupertino.dart';

class EventListPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return EventListPageState();
  }
}

class EventListPageState extends State<EventListPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("AnalyticsGen Admin Panel"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onAddEventButtonClicked(context);
        },
        child: Icon(Icons.add),
      ),
      body: Center(
        child: FutureBuilder<List<Event>>(
            future: _fetchEventList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Event> events = snapshot.data;

                return _eventListView(context, events);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return CircularProgressIndicator();
              }
            }),
      ),
    );
  }

  void _onAddEventButtonClicked(BuildContext context) {
    Navigator.pushNamed(context, '/new/event').then((res) {
      setState(() {
        // Do nothing, refresh FutureBuilder
      });
    });
  }

  Future<List<Event>> _fetchEventList() async {
    final eventListAPIURL = 'http://localhost:8080/v1/event';
    final response = await http.get(eventListAPIURL);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      return jsonResponse
          .map((eventJSON) => Event.fromJson(eventJSON))
          .toList();
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  ListView _eventListView(BuildContext context, List<Event> events) {
    return ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return _tile(context, events[index]);
        });
  }

  ListTile _tile(BuildContext context, Event event) {
    return ListTile(
      title: Text(
        event.name,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
      ),
      subtitle: Text(event.description),
      onTap: () {
        Navigator.pushNamed(
            context,
            "/events/${event.id.toString()}"
        ).then((res) {
          setState(() {
            // Do nothing, refresh FutureBuilder
          });
        });
      },
    );
  }
}