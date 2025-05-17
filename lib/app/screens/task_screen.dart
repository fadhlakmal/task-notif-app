import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app/services/notification_service.dart';
import 'package:myapp/app/widgets/drawer_widget.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {

  Future<void> _checkAndRequestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hi Mom"), centerTitle: true),
      body: Center(
        child: OutlinedButton(
          onPressed: () async {
            await NotificationService.createNotification(
              id: 1,
              title: 'Notification with Summary',
              body: 'This is the body of the notification',
              summary: 'Small summary',
              notificationLayout: NotificationLayout.Default,
            );
          },
          child: const Text('Notification with Summary'),
        ),
      ),
      drawer: DrawerWidget(),
    );
  }
}
