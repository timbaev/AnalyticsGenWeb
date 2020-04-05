import 'dart:async';

import 'package:AnalyticsGenWeb/Views/MultiSelectFormField.dart';
import 'package:AnalyticsGenWeb/Views/ParameterForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _EventFormData {
  String name = '';
  String description = '';
  List trackers = [];
  List parameters = [];
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

  List<ParameterForm> parameterForms = [
    ParameterForm(
      data: ParameterFormData(),
      initialTitle: "Параметр 1",
      titleStreamController: StreamController<String>.broadcast(),
    )
  ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: _buildTitle(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: onAddParameterClicked,
          icon: Icon(Icons.add),
          label: Text("Параметр")
        ),
        body: Container(
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: 'SomeScreenViewed',
                          labelText: 'Название'
                      ),
                      validator: _validateUpperCamelCase,
                      onSaved: (String value) {
                        _data.name = value;
                      },
                      inputFormatters: [
                        WhitelistingTextInputFormatter(
                            RegExp("[A-Za-z]")
                        )
                      ],
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Событие открытия некоторого экрана',
                          labelText: 'Описание'),
                      validator: _validateEmptyText,
                      onSaved: (String value) {
                        _data.description = value;
                      },
                    ),
                    MultiSelectFormField(
                      autovalidate: false,
                      titleText: 'Сервисы аналитики',
                      validator: (value) {
                        if (value == null || value.length == 0) {
                          return 'Пожалуйста, выберите один или несколько вариантов';
                        } else {
                          return null;
                        }
                      },
                      dataSource: [
                        {"display": "Fabric", "value": 1},
                        {"display": "Firebase", "value": 2},
                        {"display": "AppCenter", "value": 3}
                      ],
                      textField: 'display',
                      valueField: 'value',
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
                    ),
                    Column(
                      children: parameterForms,
                    ),
                    Container(
                      width: screenSize.width,
                      child: RaisedButton(
                        child: Text(
                          'Обновить',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: submit,
                        color: Colors.blue,
                      ),
                      margin: EdgeInsets.only(top: 20.0),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
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
      );

      parameterForms.add(parameterForm);
    });
  }

  void onParameterDeleteClicked(ParameterFormData data) {
    setState(() {
      var find = parameterForms.firstWhere(
          (element) => element.data == data,
          orElse: () => null
      );

      if (find != null) {
        parameterForms.removeAt(parameterForms.indexOf(find));
      }

      parameterForms.forEach((element) {
        var index = parameterForms.indexOf(element);

        element.titleStreamController.add("Параметр ${index + 1}");
      });
    });
  }

  void submit() {
    var allParametersValid = parameterForms.every((form) => form.isValid());
    
    if (_formKey.currentState.validate() && allParametersValid) {
      _formKey.currentState.save();

      var formsData = parameterForms.map((e) => e.data);

      debugPrint('Event form data');
      debugPrint('name: ${_data.name}');
      debugPrint('description: ${_data.description}');
      debugPrint('tracker: ${_data.trackers}');

      formsData.forEach((element) {
        debugPrint('Parameter - ${element.name}');
        debugPrint('description: ${element.description}');
        debugPrint('type: ${element.type}');
        debugPrint('isOptional: ${element.isOptional}');
      });
    }
  }
}
