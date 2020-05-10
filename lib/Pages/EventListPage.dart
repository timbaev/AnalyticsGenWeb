import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:AnalyticsGenWeb/Models/Event.dart';
import 'package:flutter/cupertino.dart';
import 'package:progress_dialog/progress_dialog.dart';

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
      trailing: IconButton(
        icon: Icon(Icons.delete_forever),
        tooltip: 'Delete event',
        onPressed: () {
          _showConfirmDeleteEventDialog(context, event);
        },
      )
    );
  }

  void _showConfirmDeleteEventDialog(BuildContext context, Event event) {
    FlatButton deleteButton = FlatButton(
        child: Text(
          "Delete",
          style: TextStyle(color: Colors.red),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          _deleteEvent(context, event);
        }
    );

    FlatButton cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Confirm delete"),
      content: Text(
        "Event ${event.name} will be deleted with related parameters"
      ),
      actions: <Widget>[
        deleteButton,
        cancelButton
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      }
    );
  }

  void _deleteEvent(BuildContext context, Event event) {
    ProgressDialog progressDialog = new ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
      showLogs: false
    );

    progressDialog.style(
      message: "Deleting event...",
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: TextStyle(
        color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600
      )
    );

    progressDialog.show().then((value) {
      return _deleteEventRequest(event);
    }).then((response) {
      setState(() {
        // Do nothing, refresh FutureBuilder
      });

      return progressDialog.hide();
    });
  }

  Future<String> _deleteEventRequest(Event event) async {
    String url = 'http://localhost:8080/v1/event/${event.id}';
    Map<String, String> headers = {"Content-type": "application/json"};

    var response = await http.delete(url, headers: headers);
    var body = response.body;

    return body;
  }
}