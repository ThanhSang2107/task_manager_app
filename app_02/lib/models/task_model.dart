import 'package:intl/intl.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool completed;
  final String status; // To do, In progress, Done, Cancelled
  final int priority; // 1: Thấp, 2: Trung bình, 3: Cao

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.completed = false,
    this.status = 'To do',
    this.priority = 1,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      completed: json['completed'] ?? false,
      status: json['status'] ?? 'To do',
      priority: json['priority'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completed': completed,
      'status': status,
      'priority': priority,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? completed,
    String? status,
    int? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completed: completed ?? this.completed,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }

  String getFormattedDate() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(createdAt.toLocal());
  }
}
