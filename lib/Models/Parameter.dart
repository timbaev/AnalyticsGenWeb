class Parameter {
  String id;
  bool isOptional;
  String name;
  String description;
  String type;
  int eventID;

  Parameter(this.id, this.isOptional, this.name, this.description, this.type,
      this.eventID);

  Parameter.fromJson(Map<String, dynamic> json) {
    isOptional = json['isOptional'];
    id = json['id'];
    eventID = json['eventID'];
    name = json['name'];
    description = json['description'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isOptional'] = this.isOptional;
    data['id'] = this.id;
    data['eventID'] = this.eventID;
    data['name'] = this.name;
    data['description'] = this.description;
    data['type'] = this.type;
    return data;
  }
}
