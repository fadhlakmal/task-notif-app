import 'package:flutter/material.dart';
import 'package:myapp/app/models/task_model.dart';
import 'package:myapp/app/services/task_service.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  DateTime? _selectedDueDate;
  late bool _hasNotification;
  late int _priority;

  final TaskService _taskService = TaskService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _categoryController = TextEditingController(text: widget.task.category ?? '');
    _selectedDueDate = widget.task.dueDate;
    _hasNotification = widget.task.hasNotification;
    _priority = widget.task.priority;
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past dates for editing if needed
      lastDate: DateTime(2420),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDueDate!,
      hasNotification: _hasNotification,
      category: _categoryController.text.isEmpty ? null : _categoryController.text,
      priority: _priority,
    );

    try {
      await _taskService.updateTask(updatedTask);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully!')),
      );
      if (mounted) {
        Navigator.pop(context); // Go back after editing
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text(
                  _selectedDueDate == null
                      ? 'Select Due Date and Time'
                      : 'Due: ${MaterialLocalizations.of(context).formatFullDate(_selectedDueDate!)} ${TimeOfDay.fromDateTime(_selectedDueDate!).format(context)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDueDate(context),
              ),
              const SizedBox(height: 16.0),
              SwitchListTile(
                title: const Text('Enable Notification Reminder'),
                value: _hasNotification,
                onChanged: (bool val) {
                  setState(() {
                    _hasNotification = val;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (Optional)',
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Priority'),
                value: _priority,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('High')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('Low')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _priority = value;
                    });
                  }
                },
                validator: (value) => value == null ? 'Please select a priority' : null,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}