import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/app/models/task_model.dart';
import 'package:myapp/app/services/notification_service.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get _tasks => _db.collection('tasks');

  String? get _uid => _auth.currentUser?.uid;

  Stream<List<Task>> getTasks() {
    if (_uid == null) {
      return Stream.value(<Task>[]);
    }

    return _tasks
        .where('uid', isEqualTo: _uid)
        .orderBy('dueDate')
        .snapshots()
        .map<List<Task>>( 
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map<Task>((doc) => Task.fromMap(doc))
              .toList(),
        );
  }

  Future<String?> addTask(Task task) async {
    if (_uid == null) return null;
    
    DocumentReference docRef = await _tasks.add(task.toMap());
    
    if (task.hasNotification) {
      await _scheduleTaskNotification(task.copyWith(id: docRef.id));
    }
    
    return docRef.id;
  }
  
  Future<void> updateTask(Task task) async {
    if (_uid == null) return;
    
    await NotificationService.cancelNotification(task.id.hashCode);
    await NotificationService.cancelNotification(task.id.hashCode + 10000);

    await _tasks.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'dueDate': Timestamp.fromDate(task.dueDate),
      'isCompleted': task.isCompleted,
      'hasNotification': task.hasNotification,
      'category': task.category,
      'priority': task.priority,
    });
    
    if (task.hasNotification && !task.isCompleted) {
      await _scheduleTaskNotification(task);
    }
  }
  
  Future<void> deleteTask(String taskId) async {
    if (_uid == null) return;
    
    await _tasks.doc(taskId).delete();
    
    await NotificationService.cancelNotification(taskId.hashCode);
    await NotificationService.cancelNotification(taskId.hashCode + 10000);
  }
  
  Future<void> toggleTaskCompletion(Task task) async {
    if (_uid == null) return;
        
    await _tasks.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
    
    if (!task.isCompleted) {
      await NotificationService.cancelNotification(task.id.hashCode);
      await NotificationService.cancelNotification(task.id.hashCode + 10000);
      
      await NotificationService.createNotification(
        id: 9000 + task.id.hashCode,
        title: 'Task Completed ✅',
        body: 'You\'ve completed: ${task.title}',
      );
    } else if (task.hasNotification) {
      await _scheduleTaskNotification(task);
    }
  }
  
  Future<void> _scheduleTaskNotification(Task task) async {    
    final now = DateTime.now();
    final timeUntilDue = task.dueDate.difference(now);
    
    if (timeUntilDue.isNegative) return;
    
    await NotificationService.createNotification(
      id: task.id.hashCode,
      title: '⏰ Task Reminder',
      body: task.title,
      summary: task.description,
      scheduled: true,
      interval: timeUntilDue,
      actionButtons: [
        NotificationActionButton(
          key: 'MARK_COMPLETED',
          label: 'Mark as Completed',
        ),
      ],
    );
    
    if (timeUntilDue.inMinutes > 30) {
      await NotificationService.createNotification(
        id: task.id.hashCode + 10000, 
        title: '⏰ Upcoming Task',
        body: '${task.title} - in 30 minutes',
        summary: task.description,
        scheduled: true,
        interval: timeUntilDue - const Duration(minutes: 30),
      );
    }
  }
}
