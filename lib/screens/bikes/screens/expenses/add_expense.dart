import 'package:bike_buddy/screens/bikes/database/entities/category_data.dart';
import 'package:bike_buddy/screens/bikes/database/entities/expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../constants.dart';

class AddExpenseScreen extends StatefulWidget {
  final VoidCallback function;
  const AddExpenseScreen({super.key, required this.function});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Expenses"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 55,
                ),
                Text(
                  "Add new expense",
                  style: myTextStyleBold,
                ),
                const SizedBox(
                  height: 45,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'price',
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'description',
                  maxLength: 26,
                  decoration: InputDecoration(
                    counterStyle: const TextStyle(color: Colors.white),
                    hintStyle: const TextStyle(color: Colors.white54),
                    labelText: "Description",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  validator: FormBuilderValidators.required(),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormBuilderDropdown(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'category',
                  menuMaxHeight: 250,
                  items: CategoryData.categories
                      .map<DropdownMenuItem<String>>((Category category) {
                    return DropdownMenuItem<String>(
                        value: category.name, child: Text(category.name));
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: "Category",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  dropdownColor: myGreyColor,
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(
                  height: 15,
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                        onPrimary: Colors.black,
                        onSurface: myBlueColor,
                        primary: myBlueColor),
                    dialogBackgroundColor: myBackgroundColor,
                  ),
                  child: FormBuilderDateTimePicker(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      name: 'date',
                      initialEntryMode: DatePickerEntryMode.calendar,
                      inputType: InputType.date,
                      initialValue: DateTime.now(),
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            _formKey.currentState!.fields['date']
                                ?.didChange(null);
                          },
                        ),
                        filled: true,
                        fillColor: myGreyColor,
                      ),
                      validator: (selectedDate) {
                        if (selectedDate == null) {
                          return "This field cannot be empty.";
                        }
                        if (selectedDate.isAfter(DateTime.now())) {
                          return "You cannot select a date from the future.";
                        }
                        return null;
                      }),
                ),
                const SizedBox(
                  height: 25,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ));

                            final userDoc = FirebaseFirestore.instance
                                .collection("users")
                                .doc(FirebaseAuth.instance.currentUser?.uid);

                            List<Expense>? expenses = await readExpenses();

                            DateTime date =
                                _formKey.currentState?.fields['date']!.value;
                            date = DateTime(date.year, date.month, date.day);

                            if (expenses == null) {
                              expenses = [
                                Expense(
                                    _formKey.currentState?.fields['category']!
                                        .value,
                                    _formKey.currentState?.fields['description']
                                        ?.value,
                                    double.parse(_formKey
                                        .currentState?.fields['price']!.value),
                                    date)
                              ];
                            } else {
                              expenses.insert(
                                  0,
                                  Expense(
                                      _formKey.currentState?.fields['category']!
                                          .value,
                                      _formKey.currentState
                                          ?.fields['description']?.value,
                                      double.parse(_formKey.currentState
                                          ?.fields['price']!.value),
                                      date));
                            }

                            userDoc.update({
                              "expenses": expenses
                                  .map((expense) => expense.toJson())
                                  .toList()
                            });

                            widget.function();
                            if (context.mounted) {
                              Navigator.pop(
                                context,
                              );
                              Navigator.pop(
                                context,
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: () {
                          _formKey.currentState?.reset();
                        },
                        child: Text(
                          'Reset',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<List<Expense>?> readExpenses() async {
  final docUser = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid);
  final snapshot = await docUser.get();
  if (snapshot.exists) {
    List<Expense> tempExpenses = [];
    if (snapshot.data()!['expenses'] != null) {
      snapshot.data()!['expenses'].forEach((expense) {
        tempExpenses.add(Expense.fromJson(expense));
      });
    }
    return tempExpenses;
  }
  return null;
}
