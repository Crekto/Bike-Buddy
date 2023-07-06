class Expense {
  String category;
  String description;
  double amount;
  DateTime date;

  Expense(
    this.category,
    this.description,
    this.amount,
    this.date,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.category == category &&
        other.description == description &&
        other.amount == amount &&
        other.date == date;
  }

  @override
  int get hashCode =>
      category.hashCode ^
      description.hashCode ^
      amount.hashCode ^
      date.hashCode;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(json['category'], json['description'], json['amount'],
        json['date'].toDate());
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'description': description,
        'amount': amount,
        'date': date,
      };
}
