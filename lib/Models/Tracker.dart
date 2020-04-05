class Tracker {
  int id;
  String name;
  String import;

  Tracker(this.id, this.name, this.import);

  Tracker.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    import = json['import'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['import'] = this.import;
    return data;
  }
}