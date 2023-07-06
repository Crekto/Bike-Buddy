import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/bikes/database/entities/expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../database/entities/category_data.dart';

class GroupedByDayExpenses extends StatefulWidget {
  final VoidCallback refreshParent;
  final Function deleteFromSelectedExpenses;
  final Function undoDeleteFromSelectedExpenses;
  final DateTime date;
  final List<Expense> expenses;

  const GroupedByDayExpenses(
      {super.key,
      required this.date,
      required this.expenses,
      required this.refreshParent,
      required this.deleteFromSelectedExpenses,
      required this.undoDeleteFromSelectedExpenses});

  @override
  State<GroupedByDayExpenses> createState() => _GroupedByDayExpensesState();
}

class _GroupedByDayExpensesState extends State<GroupedByDayExpenses> {
  late List<Expense> expenses;
  bool expenseDeleted = false;
  String currency = "";

  @override
  void initState() {
    fetchCurrency();
    expenses = widget.expenses;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: expenses.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(getDisplayDate(widget.date),
                      style: myTextStyleBold.copyWith(
                        fontSize: 18,
                        color: myBlueColor,
                      )),
                ),
                Text(
                  "${formatPrice(expenses.fold<double>(0, (double previousValue, Expense expense) => previousValue + expense.amount))} $currency",
                ),
              ],
            ),
            const Divider(
              thickness: 1,
              color: Color.fromARGB(255, 125, 125, 125),
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: expenses
                  .map(
                    (expense) => Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        expenseDeleted = true;
                        showUndoSnackBar(expense);
                      },
                      background: Container(color: Colors.red),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          borderRadius: expenses.length == 1
                              ? BorderRadius.circular(16)
                              : expenses.indexOf(expense) == 0
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16))
                                  : expenses.indexOf(expense) ==
                                          expenses.length - 1
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16))
                                      : BorderRadius.circular(0),
                          color: myGreyColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(expense.description,
                                    style: myTextStyleBold.copyWith(
                                      fontSize: 18,
                                    )),
                                Text("${formatPrice(expense.amount)} $currency",
                                    style: myTextStyle.copyWith(
                                      fontSize: 16,
                                    )),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                              decoration: BoxDecoration(
                                color: getCategoryColor(expense.category)
                                    ?.withAlpha(80),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(expense.category,
                                  style: myTextStyleBold.copyWith(
                                    color: getCategoryColor(expense.category),
                                    fontSize: 14,
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String getDisplayDate(DateTime date) {
    DateTime today = DateTime.now();
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (today.year == date.year &&
        today.month == date.month &&
        today.day == date.day) {
      return "Today";
    } else if (yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day) {
      return "Yesterday";
    }
    return DateFormat('E, d MMM yyyy').format(date);
  }

  Color? getCategoryColor(String categoryName) {
    Category? categoryObject = CategoryData.categories
        .where((category) => category.name == categoryName)
        .firstOrNull;

    return categoryObject?.color;
  }

  String formatPrice(double price) {
    return price.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)$"), "");
  }

  void showUndoSnackBar(Expense expense) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    List<Expense> initialExpenses = List.from(expenses);
    setState(() {
      expenses.remove(expense);
    });

    widget.deleteFromSelectedExpenses(expense);

    final snackBar = SnackBar(
      content: const Text('Expense deleted'),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          expenseDeleted = false;
          widget.undoDeleteFromSelectedExpenses(expense);
          if (mounted) {
            setState(() {
              expenses = initialExpenses;
            });
          }
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((value) {
      if (expenseDeleted == true) {
        deleteExpense(expense);
      }
    });
  }

  Future<void> deleteExpense(Expense expense) async {
    List<Expense>? expenses = await readExpenses();

    expenses!.remove(expense);

    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid);

    userDoc.update(
        {"expenses": expenses.map((expense) => expense.toJson()).toList()});
    widget.refreshParent;
  }

  Future<List<Expense>?> readExpenses() async {
    final docUser = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      List<Expense> expenses = [];
      if (snapshot.data()!['expenses'] != null) {
        snapshot.data()!['expenses'].forEach((expense) {
          expenses.add(Expense.fromJson(expense));
        });
      }

      return expenses;
    }
    return null;
  }

  Future<void> fetchCurrency() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? tempCurrency = prefs.getString('action');
    if (tempCurrency == null) {
      prefs.setString('currency', 'RON');
      setState(() {
        currency = 'RON';
      });
    } else {
      setState(() {
        currency = tempCurrency;
      });
    }
  }
}
