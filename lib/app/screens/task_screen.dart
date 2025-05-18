import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app/services/task_service.dart';
import 'package:myapp/app/widgets/drawer_widget.dart';
import 'package:myapp/app/widgets/task_tile_widget.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {

  final TaskService _taskService = TaskService();

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
      appBar: AppBar(title: const Text("Tasks"), centerTitle: true),
      body: StreamBuilder(
        stream: _taskService.getTasks(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found.'));
          }

          final tasks = snapshot.data!;
          final completedTasks = tasks.where((task) => task.isCompleted).toList();
          final nonCompletedTasks = tasks.where((task) => !task.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              if (nonCompletedTasks.isNotEmpty) ...[
                Text('Pending Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                ...nonCompletedTasks.map((task) => TaskTileWidget(task: task, taskService: _taskService)),
                Divider(),
              ],
              if (completedTasks.isNotEmpty) ...[
                Text('Completed Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                ...completedTasks.map((task) => TaskTileWidget(task: task, taskService: _taskService)),
              ],
            ],
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add task button pressed')),
          );
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
      drawer: DrawerWidget(),
    );
  }
}
