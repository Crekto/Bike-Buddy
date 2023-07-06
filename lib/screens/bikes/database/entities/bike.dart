class Bike {
  Bike(
    this.image,
    this.nickname,
    this.manufacturer,
    this.model,
    this.year,
    this.power,
  );

  String image;
  String nickname;
  String manufacturer;
  String model;
  int year;
  int power;

  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(json['image'], json['nickname'], json['manufacturer'],
        json['model'], json['year'], json['power']);
  }

  Map<String, dynamic> toJson() => {
        'image': image,
        'nickname': nickname,
        'manufacturer': manufacturer,
        'model': model,
        'year': year,
        'power': power,
      };
}
