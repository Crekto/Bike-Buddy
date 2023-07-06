import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_machine/time_machine.dart' as tm;
import '../../../../notifications/notification_service.dart';

String calculateDateDifference(DateTime startDate, DateTime endDate) {
  tm.LocalDate startDateTM = tm.LocalDate.dateTime(startDate);
  tm.LocalDate endDateTM = tm.LocalDate.dateTime(endDate);

  tm.Period difference = endDateTM.periodSince(startDateTM);

  final years = difference.years;
  final months = difference.months;
  final days = difference.days;

  String result = '';

  if (years > 0) {
    result +=
        '$years ${years > 1 ? "years" : "year"}${months > 0 || days > 0 ? ", " : ""}';
  }

  if (months > 0) {
    result +=
        '$months ${months > 1 ? "months" : "month"}${days > 0 ? ", " : ""}';
  }

  if (days > 0) {
    result += '$days ${days > 1 ? "days" : "day"}';
  }

  return result;
}

// startNotificationId - 100 - IDCard, 200 - Driving License, 300 - CIV, 400 - Insurance
Future<void> scheduleNotifications(int startNotificationId,
    DateTime expirationDate, String documentName) async {
  NotificationService()
      .cancelNotificationFromTo(startNotificationId, startNotificationId + 15);

  DateTime timeToSchedule = expirationDate
      .add(const Duration(hours: 12))
      .subtract(const Duration(days: 30));

  if (DateTime.now().compareTo(timeToSchedule) < 0) {
    await NotificationService().scheduleNotification(
        id: startNotificationId,
        title: "$documentName is expiring",
        body: "Your $documentName is expiring in 30 days",
        notificationDateTime: timeToSchedule);
  }

  for (int i = 1; i <= 14; i++) {
    timeToSchedule = expirationDate
        .add(const Duration(hours: 12))
        .subtract(Duration(days: i));
    if (DateTime.now().compareTo(timeToSchedule) < 0) {
      await NotificationService().scheduleNotification(
          id: startNotificationId + i,
          title: "$documentName is expiring",
          body: "Your $documentName is expiring in $i days",
          notificationDateTime: timeToSchedule);
    }
  }
}

class ApiImage {
  final String imageUrl;
  final String id;
  ApiImage({
    required this.imageUrl,
    required this.id,
  });
}

Future<XFile?> editImage(XFile image) async {
  CroppedFile? editedImage =
      await ImageCropper().cropImage(sourcePath: image.path, uiSettings: []);
  if (editedImage == null) return null;
  return XFile(editedImage.path);
}
