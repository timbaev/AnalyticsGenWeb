import 'dart:async';

import 'package:AnalyticsGenWeb/Models/Parameter.dart';
import 'package:AnalyticsGenWeb/Views/DropDownFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnDelete();

class ParameterFormData {
  String id;
  String name = '';
  String description = '';
  String type = '';
  bool isOptional = false;

  ParameterFormData(Parameter parameter) {
    this.id = parameter.id;
    this.name = parameter.name;
    this.description = parameter.description;
    this.type = parameter.type;
    this.isOptional = parameter.isOptional;
  }

  ParameterFormData.empty();
}

class ParameterForm extends StatefulWidget {
  final ParameterFormData data;
  final state = _ParameterFormState();
  final String initialTitle;
  final OnDelete onDelete;
  final StreamController<String> titleStreamController;
  final List<String> parameterTypes;

  ParameterForm(
      {
        Key key,
        @required this.data,
        @required this.initialTitle,
        @required this.titleStreamController,
        @required this.parameterTypes,
        this.onDelete,
      }
  ) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  bool isValid() {
    return state.validate();
  }
}

class _ParameterFormState extends State<ParameterForm> {

  final _formKey = GlobalKey<FormState>();
  String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: _buildForm(),
    );
  }

  Form _buildForm() {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildAppBar(),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Column(
                children: <Widget>[
                  _buildNameTextFormField(),
                  _buildDescriptionTextFormField(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: _buildParameterTypesDropDownFormField(
                          widget.parameterTypes
                        ),
                      ),
                      Expanded(
                        child: _buildOptionalCheckboxListTile(),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        )
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: Container(),
      elevation: 0,
      title: _buildTitle(),
      backgroundColor: Theme.of(context).accentColor,
      centerTitle: true,
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (widget.onDelete != null) {
      return [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: widget.onDelete,
        )
      ];
    } else {
      return [];
    }
  }

  StreamBuilder<String> _buildTitle() {
    return StreamBuilder<String>(
      initialData: widget.initialTitle,
      stream: widget.titleStreamController.stream,
      builder: (context, snapshot) {
        String title = ' - ';

        if (snapshot != null && snapshot.hasData) {
          title = snapshot.data;
        }

        return Text(title);
      }
    );
  }

  TextFormField _buildNameTextFormField() {
    return TextFormField(
      initialValue: widget.data.name,
      decoration: InputDecoration(
          hintText: 'parameterName',
          labelText: 'Название'
      ),
      validator: _validateLowerCamelCase,
      onSaved: (String value) {
        widget.data.name = value;
      },
      inputFormatters: [
        WhitelistingTextInputFormatter(
            RegExp("[A-Za-z]")
        )
      ],
    );
  }

  TextFormField _buildDescriptionTextFormField() {
    return TextFormField(
        initialValue: widget.data.description,
        decoration: InputDecoration(
            hintText: 'Описание параметра',
            labelText: 'Описание'
        ),
        validator: _validateEmptyText,
        onSaved: (String value) {
          widget.data.description = value;
        }
    );
  }

  DropDownFormField _buildParameterTypesDropDownFormField(
      List<String> parameterTypes
  ) {
    List<Map<String, String>> dataSource = parameterTypes
        .map((parameterType) {
          return {'display': parameterType, 'value': parameterType };
        })
        .toList();

    return DropDownFormField(
      titleText: 'Тип переменной',
      hintText: 'Пожалуйста, выберите один',
      value: widget.data.type,
      onSaved: (value) {
        setState(() {
          widget.data.type = value;
        });
      },
      onChanged: (value) {
        setState(() {
          widget.data.type = value;
        });
      },
      dataSource: dataSource,
      textField: 'display',
      valueField: 'value',
      filled: false,
    );
  }

  CheckboxListTile _buildOptionalCheckboxListTile() {
    return CheckboxListTile(
      value: widget.data.isOptional,
      onChanged: (value) {
        setState(() {
          widget.data.isOptional = !widget.data.isOptional;
        });
      },
      title: Text(
        "Опциональность",
        style: TextStyle(
            fontSize: 14.0
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.green,
    );
  }

  String _validateLowerCamelCase(String value) {
    Pattern pattern = r'^[a-z]+(?:[A-Z][a-z]+)*$';
    RegExp regExp = new RegExp(pattern);

    var emptyTextValidation = _validateEmptyText(value);

    if (emptyTextValidation != null) {
      return emptyTextValidation;
    }

    if (!regExp.hasMatch(value)) {
      return 'Название должно быть в формате LowerCamelCase';
    }

    return null;
  }

  String _validateEmptyText(String value) {
    if (value.isEmpty) {
      return 'Поле не должно быть пустым';
    }

    return null;
  }

  bool validate() {
    var valid = _formKey.currentState.validate();
    if (valid) {
      _formKey.currentState.save();
    }
    return valid;
  }
}