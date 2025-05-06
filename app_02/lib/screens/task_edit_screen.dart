import 'package:flutter/material.dart';
import '../services/task_service.dart'; // Đảm bảo import TaskService đúng
import '../models/task_model.dart';    // Đảm bảo import TaskModel đúng

class TaskEditScreen extends StatefulWidget {
  final String taskId;

  const TaskEditScreen({super.key, required this.taskId});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  late TaskModel task;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  // Hàm tải chi tiết công việc
  Future<void> _loadTaskDetails() async {
    task = await TaskService.getTaskById(widget.taskId); // Lấy công việc từ TaskService
    titleController.text = task.title;
    descriptionController.text = task.description;
    setState(() {}); // Cập nhật giao diện sau khi tải dữ liệu
  }

  // Hàm lưu công việc
  void save() async {
    if (task != null) {
      await TaskService.updateTask(
        task.id,  // ID công việc
        titleController.text,  // Tiêu đề
        descriptionController.text,  // Mô tả
        task.completed,  // Trạng thái hoàn thành
        task.status,  // Trạng thái công việc (ví dụ: "In Progress", "Completed", ...)
        task.priority,  // Ưu tiên công việc (ví dụ: 1, 2, 3)
      );
      Navigator.pop(context);  // Quay lại màn hình trước
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa công việc')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: task == null
            ? const Center(child: CircularProgressIndicator()) // Chờ tải công việc
            : Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: save,
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
