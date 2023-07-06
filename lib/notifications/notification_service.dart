import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';

class NotificationService {
  NotificationService();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.low));
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return flutterLocalNotificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  Future scheduleNotification(
      {required int id,
      String? title,
      String? body,
      String? payLoad,
      required DateTime notificationDateTime}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        TZDateTime.from(notificationDateTime, local),
        await notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  void cancelNotificationFromTo(int fromId, int toId) async {
    for (int i = fromId; i <= toId; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }
  }

  void cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>>
      retrievePendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future scheduleReminder(
      {String? body,
      String? payLoad,
      required DateTime notificationDateTime}) async {
    List<PendingNotificationRequest> notifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    List<PendingNotificationRequest>? reminders =
        notifications.where((notification) => notification.id >= 1000).toList();
    reminders.sort((a, b) => a.id.compareTo(b.id));

    int currentId = 1000;
    for (var reminder in reminders) {
      if (reminder.id == currentId) {
        currentId++;
      } else {
        break;
      }
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("notif-$currentId", notificationDateTime.toString());
    await flutterLocalNotificationsPlugin.zonedSchedule(
        currentId,
        "Custom Reminder",
        body,
        TZDateTime.from(notificationDateTime, local),
        const NotificationDetails(
            android: AndroidNotificationDetails('channelId', 'channelName',
                importance: Importance.max)),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
