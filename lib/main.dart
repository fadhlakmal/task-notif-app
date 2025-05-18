import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app/config/firebase_options.dart';
import 'package:myapp/app/models/task_model.dart';
import 'package:myapp/app/screens/add_task_screen.dart';
import 'package:myapp/app/screens/edit_task_screen.dart';
import 'package:myapp/app/screens/home_screen.dart';
import 'package:myapp/app/screens/login_screen.dart';
import 'package:myapp/app/screens/register_screen.dart';
import 'package:myapp/app/screens/task_screen.dart';
import 'package:myapp/app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await NotificationService.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: 'home',
      routes: {
        'home': (context) => const HomeScreen(),
        'login': (constext) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
        'task': (context) => const TaskScreen(),
        'add_task': (context) => const AddTaskScreen(),
        'edit_task': (context) {
          final task = ModalRoute.of(context)!.settings.arguments as Task;
          return EditTaskScreen(task: task);
        },
      },
    );
  }
}
