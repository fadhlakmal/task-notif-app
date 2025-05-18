import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app/models/user_model.dart';
import 'package:myapp/app/screens/login_screen.dart';
import 'package:myapp/app/services/task_service.dart';
import 'package:myapp/app/services/user_service.dart';
import 'package:myapp/app/widgets/drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final TaskService _taskService = TaskService();

  void logout(context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (context, authSnapshot) {
        if (!authSnapshot.hasData) {
          return LoginScreen();
        }

        final uid = _auth.currentUser?.uid;
        if (uid == null) {
          return LoginScreen();
        }

        return StreamBuilder<UserModel?>(
          stream: _userService.userStream(uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (userSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: const Text("Home"), centerTitle: true),
                body: Center(
                  child: Text('Error loading user data: ${userSnapshot.error}'),
                ),
                drawer: const DrawerWidget(),
              );
            }

            if (!userSnapshot.hasData) {
              return Scaffold(
                appBar: AppBar(title: const Text("Home"), centerTitle: true),
                body: const Center(child: Text('User data not found')),
                drawer: const DrawerWidget(),
              );
            }

            final userData = userSnapshot.data!;

            return StreamBuilder(
              stream: _taskService.getTasks(),
              builder: (context, taskSnapshot) {
                int completedTasks = 0;
                int pendingTasks = 0;

                if (taskSnapshot.hasData) {
                  final tasks = taskSnapshot.data!;
                  completedTasks =
                      tasks.where((task) => task.isCompleted).length;
                  pendingTasks =
                      tasks.where((task) => !task.isCompleted).length;
                }

                return Scaffold(
                  appBar: AppBar(
                    title: const Text("Home"),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () => logout(context),
                        tooltip: "Logout",
                      ),
                    ],
                  ),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Hello, ${userData.username}!",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "You have $pendingTasks pending tasks.",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "You have completed $completedTasks tasks.",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'task');
                            },
                            child: const Text('View All Tasks'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  drawer: const DrawerWidget(),
                );
              },
            );
          },
        );
      },
    );
  }
}
