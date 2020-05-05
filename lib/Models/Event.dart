import 'package:AnalyticsGenWeb/Models/Parameter.dart';
import 'package:AnalyticsGenWeb/Models/Tracker.dart';

class Event {
  String id;
  String name;
  String description;
  List<Parameter> parameters;
  List<Tracker> trackers;

  Event(this.id, this.name, this.description, this.parameters, this.trackers);

  Event.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['trackers'] != null) {
      trackers = new List<Tracker>();
      json['trackers'].forEach((v) {
        trackers.add(new Tracker.fromJson(v));
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
    if (this.trackers != null) {
      data['trackers'] = this.trackers.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    data['description'] = this.description;
    if (this.parameters != null) {
      data['parameters'] = this.parameters.map((v) => v.toJson()).toList();
    }
    return data;
  }
}