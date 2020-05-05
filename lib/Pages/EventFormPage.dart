import 'dart:async';
import 'dart:convert';

import 'package:AnalyticsGenWeb/Models/Event.dart';
import 'package:AnalyticsGenWeb/Models/Tracker.dart';
import 'package:AnalyticsGenWeb/Tools/OnceFutureBuilder.dart';
import 'package:AnalyticsGenWeb/Views/MultiSelectFormField.dart';
import 'package:AnalyticsGenWeb/Views/ParameterForm.dart';
import 'package:AnalyticsGenWeb/Views/RoundedLoadingButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

class EventFormPageContent {
  final List<Tracker> trackers;
  final List<String> parameterTypes;

  EventFormPageContent({this.trackers, this.parameterTypes});
}

class _EventFormData {
  String name = '';
  String description = '';
  List trackers = [];
}

class EventFormPage extends StatefulWidget {
  final String eventID;

  EventFormPage({Key key, this.eventID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EventFormPageState();
  }
}

class EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  _EventFormData _data = new _EventFormData();
  EventFormPageContent content;

  List<ParameterForm> parameterForms = [];

  final _buttonController = new RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: _buildTitle(),
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: onAddParameterClicked,
            icon: Icon(Icons.add),
            label: Text("Параметр")),
        body: Container(
            child: OnceFutureBuilder<EventFormPageContent>(
              future: () => _fetchContent(),
              builder: (context, AsyncSnapshot<EventFormPageContent> snapshot) {
                if (snapshot.hasData) {
                  EventFormPageContent content = snapshot.data;

                  return _buildForm(context, content);
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
        )));
  }

  Future<EventFormPageContent> _fetchContent() {
    final trackersURL = 'http://localhost:8080/v1/tracker';
    final parameterTypesURL = 'http://localhost:8080/v1/parameter/types';

    var futures = [http.get(trackersURL), http.get(parameterTypesURL)];
    var hasEventID = (widget.eventID != null);

    if (hasEventID) {
      final eventURL = 'http://localhost:8080/v1/event/${widget.eventID}';
      futures.add(http.get(eventURL));
    }

    return Future.wait(futures).then((response) {
      List trackersJSONResponse = json.decode(response[0].body);
      Map<String, dynamic> jsonData = json.decode(response[1].body);

      var trackers = trackersJSONResponse
          .map((trackerJSON) => Tracker.fromJson(trackerJSON))
          .toList();

      List<String> parameterTypes = jsonData['types'].cast<String>();

      if (hasEventID) {
        Event event = Event.fromJson(json.decode(response[2].body));

        this.parameterForms = event.parameters.asMap().map((index, parameter) {
          var data = ParameterFormData();

          data.name = parameter.name;
          data.description = parameter.description;
          data.type = parameter.type;
          data.isOptional = parameter.isOptional;

          var parameterForm = ParameterForm(
            data: data,
            initialTitle: "Параметр ${index + 1}",
            titleStreamController: StreamController<String>.broadcast(),
            parameterTypes: parameterTypes,
          );

          return MapEntry(index, parameterForm);
        }).values.toList();

        _data.name = event.name;
        _data.description = event.description;
        // _data.trackers = event.trackers.map((e) => e.toJson()).toList();
      } else {
        this.parameterForms = [
          ParameterForm(
            data: ParameterFormData(),
            initialTitle: "Параметр 1",
            titleStreamController: StreamController<String>.broadcast(),
            parameterTypes: parameterTypes,
          )
        ];
      }

      var content = EventFormPageContent(
          trackers: trackers,
          parameterTypes: parameterTypes
      );

      this.content = content;

      return content;
    });
  }

  Form _buildForm(BuildContext context, EventFormPageContent content) {
    final Size screenSize = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildNameTextFormField(),
              _buildDescriptionTextFormField(),
              _buildTrackerMultiSelectFormField(content.trackers),
              Column(
                children: parameterForms,
              ),
              Container(
                width: screenSize.width,
                child: _buildConfirmButton(context),
                margin: EdgeInsets.only(top: 20.0),
              )
            ],
          ),
        ),
      ),
    );
  }

  Text _buildTitle() {
    var title = '';

    if (widget.eventID != null) {
      title = "Изменить событие";
    } else {
      title = "Создать событие";
    }

    return Text(title);
  }

  TextFormField _buildNameTextFormField() {
    return TextFormField(
      initialValue: _data.name,
      decoration:
          InputDecoration(hintText: 'SomeScreenViewed', labelText: 'Название'),
      validator: _validateUpperCamelCase,
      onSaved: (String value) {
        _data.name = value;
      },
      inputFormatters: [WhitelistingTextInputFormatter(RegExp("[A-Za-z]"))],
    );
  }

  TextFormField _buildDescriptionTextFormField() {
    return TextFormField(
      initialValue: _data.description,
      decoration: InputDecoration(
          hintText: 'Событие открытия некоторого экрана',
          labelText: 'Описание'),
      validator: _validateEmptyText,
      onSaved: (String value) {
        _data.description = value;
      },
    );
  }

  MultiSelectFormField _buildTrackerMultiSelectFormField(
      List<Tracker> trackers
  ) {
    return MultiSelectFormField(
      autovalidate: false,
      titleText: 'Сервисы аналитики',
      validator: (value) {
        if (value == null || value.length == 0) {
          return 'Пожалуйста, выберите один или несколько вариантов';
        } else {
          return null;
        }
      },
      dataSource: trackers.map((e) => e.toJson()).toList(),
      textField: 'name',
      valueField: 'id',
      okButtonLabel: 'OK',
      cancelButtonLabel: 'ОТМЕНА',
      required: true,
      hintText: 'Выберите, в какие сервисы необходимо отправлять событие',
      value: _data.trackers,
      onSaved: (value) {
        if (value != null) {
          setState(() {
            _data.trackers = value;
          });
        }
      },
    );
  }

  RoundedLoadingButton _buildConfirmButton(BuildContext context) {
    var text = '';

    if (widget.eventID != null) {
      text = "Изменить";
    } else {
      text = "Создать";
    }

    return RoundedLoadingButton(
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      controller: _buttonController,
      onPressed: () {
        submit(context);
      },
      animateOnTap: false,
    );
  }

  String _validateUpperCamelCase(String value) {
    Pattern pattern = r'^[A-Z][a-z]+(?:[A-Z][a-z]+)*$';
    RegExp regExp = new RegExp(pattern);

    var emptyTextValidation = _validateEmptyText(value);

    if (emptyTextValidation != null) {
      return emptyTextValidation;
    }

    if (!regExp.hasMatch(value)) {
      return 'Название должно быть в формате UpperCamelCase';
    }

    return null;
  }

  String _validateEmptyText(String value) {
    if (value.isEmpty) {
      return 'Поле не должно быть пустым';
    }

    return null;
  }

  void onAddParameterClicked() {
    setState(() {
      var data = ParameterFormData();

      var parameterForm = ParameterForm(
        key: UniqueKey(),
        data: data,
        initialTitle: "Параметр ${parameterForms.length + 1}",
        onDelete: () => onParameterDeleteClicked(data),
        titleStreamController: StreamController<String>.broadcast(),
        parameterTypes: content.parameterTypes,
      );

      parameterForms.add(parameterForm);
    });
  }

  void onParameterDeleteClicked(ParameterFormData data) {
    setState(() {
      var find = parameterForms.firstWhere((element) => element.data == data,
          orElse: () => null);

      if (find != null) {
        parameterForms.removeAt(parameterForms.indexOf(find));
      }

      parameterForms.forEach((element) {
        var index = parameterForms.indexOf(element);

        element.titleStreamController.add("Параметр ${index + 1}");
      });
    });
  }

  void submit(BuildContext context) {
    var allParametersValid = parameterForms.every((form) => form.isValid());

    if (_formKey.currentState.validate() && allParametersValid) {
      _formKey.currentState.save();

      var parametersData = parameterForms.map((e) => e.data);

      Map json = {
        'name': _data.name,
        'description': _data.description,
        'trackerIDs': _data.trackers,
        'parameters': parametersData.map((parameterData) {
          return {
            'name': parameterData.name,
            'description': parameterData.description,
            'type': parameterData.type,
            'isOptional': parameterData.isOptional
          };
        }).toList()
      };

      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String prettyPrintJSON = encoder.convert(json);
      print(prettyPrintJSON);

      _buttonController.start();

      Future.wait([_createEventRequest(json)]).then((response) {
        print("Create event response: ${response[0]}");

        _buttonController.success();

        Navigator.pop(context);
      });
    }
  }

  Future<String> _createEventRequest(Map jsonMap) async {
    String url = 'http://localhost:8080/v1/event';
    Map<String, String> headers = {"Content-type": "application/json"};
    String rawJSON = jsonEncode(jsonMap);

    var response = await http.post(
        url,
        headers: headers,
        body: rawJSON
    );

    String body = response.body;

    return body;
  }
}
