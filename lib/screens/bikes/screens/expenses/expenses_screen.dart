import 'dart:collection';
import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/bikes/database/entities/expense.dart';
import 'package:bike_buddy/screens/bikes/screens/expenses/add_expense.dart';
import 'package:bike_buddy/screens/bikes/screens/expenses/components/grouped_by_day_expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/entities/category_data.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late Future<List<Expense>?> future;
  late List<Expense> expenses;
  late List<Expense> selectedExpenses;
  SplayTreeMap<DateTime, List<Expense>> groupedExpenses =
      SplayTreeMap<DateTime, List<Expense>>(
    (a, b) => b.compareTo(a),
  );

  String currency = "";

  String selectedRange = 'All time';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  List<String> ranges = [
    'All time',
    'This week',
    'This month',
    'This year',
    'Custom range',
  ];

  @override
  void initState() {
    fetchCurrency();
    future = readExpenses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Expenses"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 22, right: 16),
        child: FutureBuilder<List<Expense>?>(
          future: future,
          builder: (context, AsyncSnapshot<List<Expense>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text("No expenses yet."));
              } else {
                expenses = snapshot.data!;

                selectedExpenses = filterRecords();

                if (selectedExpenses.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showTimeRangeMenu(context);
                          },
                          child: Text(
                            selectedRange == 'Custom range'
                                ? "${DateFormat("d MMM ''yy").format(startDate)} - ${DateFormat("d MMM ''yy").format(endDate)}"
                                : selectedRange,
                            style: myTextStyleBold.copyWith(
                                fontSize: 20, color: myBlueColor),
                          ),
                        ),
                        const SizedBox(height: 250),
                        const Text("No expenses for selected range")
                      ],
                    ),
                  );
                }

                groupedExpenses.clear();
                for (var expense in selectedExpenses) {
                  var dateKey = DateTime(
                      expense.date.year, expense.date.month, expense.date.day);

                  if (groupedExpenses.containsKey(dateKey)) {
                    groupedExpenses[dateKey]!.add(expense);
                  } else {
                    groupedExpenses[dateKey] = [expense];
                  }
                }

                return WillPopScope(
                  onWillPop: () async {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    return true;
                  },
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showTimeRangeMenu(context);
                        },
                        child: Text(
                          selectedRange == 'Custom range'
                              ? "${DateFormat("d MMM ''yy").format(startDate)} - ${DateFormat("d MMM ''yy").format(endDate)}"
                              : selectedRange,
                          style: myTextStyleBold.copyWith(
                              fontSize: 20, color: myBlueColor),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Total"),
                              Text(
                                  "${formatPrice(selectedExpenses.fold<double>(0, (double previousValue, Expense expense) => previousValue + expense.amount))} $currency"),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("Avg/day"),
                              Text(
                                  "${formatPrice((selectedExpenses.fold<double>(0, (double previousValue, Expense expense) => previousValue + expense.amount) / (endDate.difference(startDate).inDays + 1)))} $currency")
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: getPieChartData(),
                            centerSpaceRadius: 50,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: getLegend(),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Expanded(
                        child: SingleChildScrollView(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: groupedExpenses.length,
                            itemBuilder: (context, index) {
                              final DateTime date =
                                  groupedExpenses.keys.elementAt(index);
                              final List<Expense> dayExpenses =
                                  groupedExpenses[date]!;

                              return GroupedByDayExpenses(
                                key: UniqueKey(),
                                date: date,
                                expenses: dayExpenses,
                                refreshParent: refresh,
                                deleteFromSelectedExpenses:
                                    deleteFromSelectedExpenses,
                                undoDeleteFromSelectedExpenses:
                                    undoDeleteFromSelectedExpenses,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: myBlueColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddExpenseScreen(function: refresh)));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void refresh() {
    setState(() {
      future = readExpenses();
    });
  }

  String formatPrice(double price) {
    return price.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)$"), "");
  }

  void showDatePickerDialog(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: startDate,
      end: endDate,
    );

    final selectedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      initialDateRange: initialDateRange,
      initialEntryMode: DatePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: myBlueColor,
              surface: myBlueColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: myBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (selectedDateRange != null) {
      setState(() {
        startDate = selectedDateRange.start;
        endDate = selectedDateRange.end;
        setFilterRecords(filterRecords());
      });
    }
  }

  void showTimeRangeMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero);

    final List<PopupMenuEntry<String>> menuItems = [
      const PopupMenuItem<String>(
        value: 'All time',
        child: Text('All time'),
      ),
      const PopupMenuItem<String>(
        value: 'This week',
        child: Text('This week'),
      ),
      const PopupMenuItem<String>(
        value: 'This month',
        child: Text('This month'),
      ),
      const PopupMenuItem<String>(
        value: 'This year',
        child: Text('This year'),
      ),
      const PopupMenuItem<String>(
        value: 'Custom range',
        child: Text('Custom range'),
      ),
    ];

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        115,
        120,
        buttonPosition.dx + button.size.width,
        buttonPosition.dy + button.size.height,
      ),
      color: myGreyColor,
      items: menuItems,
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedRange = value;
          if (selectedRange == "Custom range") {
            showDatePickerDialog(context);
          } else {
            setFilterRecords(filterRecords());
          }
        });
      }
    });
  }

  List<Expense> filterRecords() {
    late List<Expense> filteredExpenses;
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);
    if (selectedRange == 'All time') {
      startDate = expenses
          .map((expense) => expense.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      endDate = now;
      filteredExpenses = expenses;
    } else if (selectedRange == 'This week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      endDate = now;
      filteredExpenses = expenses.where((expense) {
        return expense.date.compareTo(startDate) >= 0 &&
            expense.date.compareTo(endDate) <= 0;
      }).toList();
    } else if (selectedRange == 'This month') {
      startDate = DateTime(now.year, now.month, 1);
      endDate = now;
      filteredExpenses = expenses.where((expense) {
        return expense.date.year == now.year && expense.date.month == now.month;
      }).toList();
    } else if (selectedRange == 'This year') {
      startDate = DateTime(now.year, 1, 1);
      endDate = now;
      filteredExpenses = expenses.where((expense) {
        return expense.date.year == now.year;
      }).toList();
    } else if (selectedRange == 'Custom range') {
      filteredExpenses = expenses.where((expense) {
        return expense.date.compareTo(startDate) >= 0 &&
            expense.date.compareTo(endDate) <= 0;
      }).toList();
    }

    return filteredExpenses;
  }

  void setFilterRecords(List<Expense> filteredExpenses) {
    setState(() {
      selectedExpenses = filteredExpenses;
    });
  }

  List<PieChartSectionData> getPieChartData() {
    Map<String, double> categoryTotals = {};

    for (Expense expense in selectedExpenses) {
      if (categoryTotals.containsKey(expense.category)) {
        categoryTotals[expense.category] =
            categoryTotals[expense.category]! + expense.amount;
      } else {
        categoryTotals[expense.category] = expense.amount;
      }
    }

    List<PieChartSectionData> pieChartData =
        categoryTotals.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;

      return PieChartSectionData(
        value: amount,
        title: category,
        showTitle: false,
        color: getCategoryColor(category),
      );
    }).toList();

    return pieChartData;
  }

  List<Widget> getLegend() {
    Map<String, double> categoryTotals = {};

    for (Expense expense in selectedExpenses) {
      if (categoryTotals.containsKey(expense.category)) {
        categoryTotals[expense.category] =
            categoryTotals[expense.category]! + expense.amount;
      } else {
        categoryTotals[expense.category] = expense.amount;
      }
    }

    double totalAmount = categoryTotals.values.reduce((a, b) => a + b);

    List<Widget> legendWidgets = categoryTotals.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      final percentage = (amount / totalAmount) * 100;
      final color = getCategoryColor(category);

      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 4),
              width: 16,
              height: 16,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            Text('$category (${formatPrice(percentage)}%)'),
          ],
        ),
      );
    }).toList();

    return legendWidgets;
  }

  Color? getCategoryColor(String categoryName) {
    Category? categoryObject = CategoryData.categories
        .where((category) => category.name == categoryName)
        .firstOrNull;

    return categoryObject?.color;
  }

  void deleteFromSelectedExpenses(Expense expense) {
    setState(() {
      expenses.remove(expense);
    });
  }

  void undoDeleteFromSelectedExpenses(Expense expense) {
    setState(() {
      expenses.add(expense);
    });
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

    String? tempCurrency = prefs.getString('currency');
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
