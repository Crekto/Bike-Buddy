import 'package:flutter/material.dart';

class Category {
  String name;
  Color color;

  Category({required this.name, required this.color});
}

class CategoryData {
  static List<Category> categories = [
    Category(name: 'Fuel', color: Colors.red),
    Category(name: 'Maintenance', color: Colors.purple),
    Category(name: 'Repairs', color: Colors.teal),
    Category(name: 'Parts', color: Colors.green),
    Category(name: 'Accessories', color: Colors.lightGreen),
    Category(name: 'Registration', color: Colors.brown),
    Category(name: 'Licensing', color: Colors.yellow),
    Category(name: 'Gear', color: Colors.blueGrey),
    Category(name: 'Modifications', color: Colors.pink),
    Category(name: 'Parking', color: Colors.deepPurple),
    Category(name: 'Tolls', color: Colors.deepOrange),
    Category(name: 'Events', color: Colors.indigo),
    Category(name: 'Other', color: Colors.grey),
  ];
}
