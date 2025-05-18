import 'package:flutter/material.dart';
import 'package:myapp/app/models/task_model.dart';
import 'package:myapp/app/services/task_service.dart';

class TaskTileWidget extends StatelessWidget {

  final Task task;
  final TaskService taskService;

  const TaskTileWidget({super.key, required this.task, required this.taskService});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.description),
      trailing: Checkbox(
        value: task.isCompleted, 
        onChanged: (bool? val) {
          if (val != null) {
            taskService.toggleTaskCompletion(task);
          }
        },
      ),
      onLongPress: () {
        showDialog(
          context: context, 
          builder: (context) => AlertDialog(
            title: Text('Delete Task?'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await taskService.deleteTask(task.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          )
        );
      },
    );
  }

}