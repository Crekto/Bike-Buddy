import 'my_document.dart';

class Documents {
  Documents(
    this.idCard,
    this.drivingLicense,
    this.civ,
    this.insurance,
  );

  MyDocument? idCard;
  MyDocument? drivingLicense;
  MyDocument? civ;
  MyDocument? insurance;

  factory Documents.fromJson(Map<String, dynamic> json) {
    return Documents(
        json['idCard'] != null ? MyDocument.fromJson(json['idCard']) : null,
        json['drivingLicense'] != null
            ? MyDocument.fromJson(json['drivingLicense'])
            : null,
        json['civ'] != null ? MyDocument.fromJson(json['civ']) : null,
        json['insurance'] != null
            ? MyDocument.fromJson(json['insurance'])
            : null);
  }

  Map<String, dynamic> toJson() => {
        'idCard': idCard?.toJson(),
        'drivingLicense': drivingLicense?.toJson(),
        'civ': civ?.toJson(),
        'insurance': insurance?.toJson(),
      };
}
