import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/notifications/notification_service.dart';
import 'package:bike_buddy/screens/bikes/screens/reminders/components/reminder_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Widget> maintenanceRecordWidgets = [];
  int currentPage = 0;
  int pageSize = 4;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Reminders"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 46, right: 16),
        child: Column(
          children: [
            Center(
              child: Text(
                "Your Reminders",
                style: myTextStyleBold,
              ),
            ),
            const SizedBox(height: 46),
            FutureBuilder<List<PendingNotificationRequest>?>(
              future: getNotifications(),
              builder: (context,
                  AsyncSnapshot<List<PendingNotificationRequest>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null || snapshot.data?.isEmpty == true) {
                    return const Text("No reminders yet.");
                  } else {
                    maintenanceRecordWidgets = [];

                    for (var data in snapshot.data!) {
                      maintenanceRecordWidgets
                          .add(ReminderCard(notification: data));
                    }

                    return WillPopScope(
                      onWillPop: () async {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        return true;
                      },
                      child: SizedBox(
                        height: 440,
                        child: SingleChildScrollView(
                          child: Column(
                            children: maintenanceRecordWidgets,
                          ),
                        ),
                      ),
                    );
                  }
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myBlueColor,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    scrollable: true,
                    title: const Text("Add reminder"),
                    backgroundColor: myBackgroundColor,
                    content: FormBuilder(
                      key: formKey,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 25,
                            width: 999999,
                          ),
                          FormBuilderTextField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            name: 'body',
                            maxLength: 26,
                            decoration: InputDecoration(
                              counterStyle:
                                  const TextStyle(color: Colors.white),
                              labelText: "Note",
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              filled: true,
                              fillColor: myGreyColor,
                            ),
                            validator: FormBuilderValidators.required(),
                            textInputAction: TextInputAction.next,
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
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                name: 'date',
                                initialEntryMode: DatePickerEntryMode.calendar,
                                initialValue: DateTime.now(),
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      formKey.currentState!.fields['date']
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
                                  if (selectedDate.isBefore(DateTime.now())) {
                                    return "You cannot select a date from the past.";
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
                                    if (formKey.currentState
                                            ?.saveAndValidate() ??
                                        false) {
                                      NotificationService().scheduleReminder(
                                          body: formKey.currentState
                                              ?.fields['body']!.value,
                                          notificationDateTime: formKey
                                              .currentState
                                              ?.fields['date']!
                                              .value);

                                      if (context.mounted) {
                                        Navigator.pop(
                                          context,
                                        );
                                        setState(() {});
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
                                    formKey.currentState?.reset();
                                  },
                                  child: Text(
                                    'Reset',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ));
              });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }

  Future<List<PendingNotificationRequest>?> getNotifications() async {
    List<PendingNotificationRequest>? notifications =
        await NotificationService().retrievePendingNotifications();

    List<PendingNotificationRequest>? reminders =
        notifications.where((notification) => notification.id >= 1000).toList();
    return reminders.reversed.toList();
  }
}
