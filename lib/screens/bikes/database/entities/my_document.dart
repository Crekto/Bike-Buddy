class MyDocument {
  MyDocument(
    this.images,
    this.expiration,
  );

  List<String> images;
  DateTime expiration;

  factory MyDocument.fromJson(Map<String, dynamic> json) {
    List<String> tempImages = [];
    json['images'].forEach((image) {
      tempImages.add(image);
    });
    return MyDocument(tempImages, json['expiration'].toDate());
  }

  Map<String, dynamic> toJson() => {
        'images': images,
        'expiration': expiration,
      };
}
