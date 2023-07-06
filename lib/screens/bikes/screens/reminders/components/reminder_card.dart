import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderCard extends StatefulWidget {
  final PendingNotificationRequest notification;

  const ReminderCard({super.key, required this.notification});

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  DateTime? notificationDateTime;
  late bool reminderDeleted;
  @override
  void initState() {
    fetchNotificationDateTIme(widget.notification.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return notificationDateTime == null
        ? const CircularProgressIndicator()
        : Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              reminderDeleted = true;
              showUndoSnackBar();
            },
            background: Container(color: Colors.red),
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 51, 56, 58),
                        blurRadius: 15,
                        offset: Offset(-4, -4),
                      ),
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 15,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      color: myGreyColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.notification.body as String,
                                style: myTextStyleBold.copyWith(fontSize: 18),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy hh:mm a')
                                    .format(notificationDateTime!),
                                style: myTextStyle.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> fetchNotificationDateTIme(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationDateTime =
          DateTime.parse(prefs.getString("notif-$id").toString());
    });
  }

  void showUndoSnackBar() {
    final snackBar = SnackBar(
      content: const Text('Reminder deleted'),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          reminderDeleted = false;
          setState(() {});
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((value) {
      if (reminderDeleted == true) {
        NotificationService().cancelNotification(widget.notification.id);
      }
    });
  }
}
