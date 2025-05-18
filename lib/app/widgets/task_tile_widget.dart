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
            title: Text('Task Options'),
            content: Text('What would you like to do with "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'edit_task', arguments: task);
                },
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  bool? confirmDelete = await showDialog(
                    context: context, 
                    builder: (context) => AlertDialog(
                      title: Text('Delete Task?'),
                      content: Text('Are you sure you want to delete "${task.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirmDelete == true) {
                    await taskService.deleteTask(task.id);
                  }
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          )
        );
      },
    );
  }

}