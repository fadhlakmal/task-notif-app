import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String uid;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool hasNotification;
  final bool isCompleted;
  final String? category;
  final int priority;

  Task({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.hasNotification,
    this.isCompleted = false,
    this.category,
    this.priority = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'hasNotification': hasNotification,
      'isCompleted': isCompleted,
      'category': category,
      'priority': priority,
    };
  }

  factory Task.fromMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id,
      uid: data['uid'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      hasNotification: data['hasNotification'] ?? true,
      isCompleted: data['isCompleted'] ?? false,
      category: data['category'],
      priority: data['priority'] ?? 2,
    );
  }

  get reminderTime => null;

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? hasNotification,
    bool? isCompleted,
    String? category,
    int? priority,
  }) {
    return Task(
      id: id,
      uid: uid,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      hasNotification: hasNotification ?? this.hasNotification,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }
}
