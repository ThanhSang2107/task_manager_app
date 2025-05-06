import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _status;
  late int _priority;
  late bool _completed;

  final List<String> _statusOptions = ['To do', 'In progress', 'Done', 'Cancelled'];
  final Map<int, String> _priorityLabels = {
    1: 'Thấp',
    2: 'Trung bình',
    3: 'Cao',
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _status = widget.task.status;
    _priority = widget.task.priority;
    _completed = widget.task.completed;
  }

  void _save() async {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      status: _status,
      priority: _priority,
      completed: _completed,
    );

    await TaskService.updateTask(
      updatedTask.id,
      updatedTask.title,
      updatedTask.description,
      updatedTask.completed,
      updatedTask.status,
      updatedTask.priority,
    );

    if (mounted) Navigator.pop(context);
  }

  void _toggleDone() {
    setState(() {
      _completed = !_completed;
    });
  }

  void _delete() async {
    await TaskService.deleteTask(widget.task.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              items: _statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
              decoration: const InputDecoration(labelText: 'Trạng thái'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _priority,
              items: _priorityLabels.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
              decoration: const InputDecoration(labelText: 'Mức độ ưu tiên'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Lưu'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _toggleDone,
                  child: Text(_completed ? 'Đánh dấu chưa xong' : 'Đánh dấu đã xong'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
