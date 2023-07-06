class MaintenanceRecord {
  MaintenanceRecord(this.images, this.type, this.km, this.note, this.date);

  List<String> images;
  String type;
  int km;
  String? note;
  DateTime date;

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    List<String> tempImages = [];
    json['images'].forEach((image) {
      tempImages.add(image);
    });
    return MaintenanceRecord(tempImages, json['type'], json['km'], json['note'],
        json['date'].toDate());
  }

  Map<String, dynamic> toJson() => {
        'images': images,
        'type': type,
        'km': km,
        'note': note,
        'date': date,
      };
}
