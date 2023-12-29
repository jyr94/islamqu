import 'package:flutter/material.dart';
import 'package:islamqu/helper/NotificationService.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotifPage extends StatefulWidget {
  NotifPage({Key? key}) : super(key: key);

  // final String title;

  @override
  _NotifPageState createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  NotificationService _notificationService = NotificationService();

  // final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  // tz.TZDateTime scheduledDate =now.add(const Duration(minutes: 1));
  int buttonCount = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text("Test"),
        // ),
        body: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text('Show Notification'),

                    onPressed: () async {
                      await _notificationService.showNotifications();
                    },
                  ),
                  SizedBox(height: 3),
                  ElevatedButton(
                    child: Text('Schedule Notification'),

                    onPressed: () async {

                      var result = DateTime.now().add(Duration(minutes: 1));
                      print(result);
                      await _notificationService.scheduleNotification(
                        id: buttonCount+=1,
                        title: "test guys",
                        body: "test",
                        scheduledNotificationDateTime:result
                      );
                    },
                  ),
                  SizedBox(height: 3),
                  ElevatedButton(
                    child: Text('Cancel Notification'),
                    onPressed: () async {
                      await _notificationService.cancelNotifications(0);
                    },
                  ),
                  SizedBox(height: 3),
                  ElevatedButton(
                    child: Text('Cancel All Notifications'),
                    onPressed: () async {
                      await _notificationService.cancelAllNotifications();
                    },
                  ),
                  SizedBox(height: 3),
                ],
              ),
            )));
  }
}