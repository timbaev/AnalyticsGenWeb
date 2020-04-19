import 'package:AnalyticsGenWeb/Models/Parameter.dart';
import 'package:AnalyticsGenWeb/Models/Tracker.dart';

class Event {
  String id;
  String name;
  String description;
  List<Parameter> parameters;
  List<Tracker> analyticsTrackers;

  Event(this.id, this.name, this.description, this.parameters,
      this.analyticsTrackers);

  Event.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['analyticsTrackers'] != null) {
      analyticsTrackers = new List<Tracker>();
      json['analyticsTrackers'].forEach((v) {
        analyticsTrackers.add(new Tracker.fromJson(v));
      });
    }
    name = json['name'];
    description = json['description'];
    if (json['parameters'] != null) {
      parameters = new List<Parameter>();
      json['parameters'].forEach((v) {
        parameters.add(new Parameter.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.analyticsTrackers != null) {
      data['analyticsTrackers'] =
          this.analyticsTrackers.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    data['description'] = this.description;
    if (this.parameters != null) {
      data['parameters'] = this.parameters.map((v) => v.toJson()).toList();
    }
    return data;
  }
}