import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/task_service.dart';
import '../models/task_model.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<TaskModel>> _taskFuture;
  List<TaskModel> _allTasks = [];
  List<TaskModel> _filteredTasks = [];

  String _searchQuery = '';
  String _selectedStatus = 'Tất cả';
  int? _selectedPriority;
  bool _isKanbanView = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    setState(() {
      _taskFuture = TaskService.getTasks();
      _taskFuture.then((tasks) {
        _allTasks = tasks;
        _applyFilters();
      });
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _selectedStatus == 'Tất cả' || task.status == _selectedStatus;
        final matchesPriority = _selectedPriority == null || task.priority == _selectedPriority;
        return matchesSearch && matchesStatus && matchesPriority;
      }).toList();
    });
  }

  void _toggleDone(TaskModel task) async {
    await TaskService.toggleTaskDone(task);
    _fetchTasks();
  }

  void _deleteTask(String id) async {
    await TaskService.deleteTask(id);
    _fetchTasks();
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedStatus = 'To do';
    int selectedPriority = 2;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm công việc mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Tiêu đề'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Mô tả'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: ['To do', 'In progress', 'Done', 'Cancelled']
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Trạng thái'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedPriority,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Thấp')),
                        DropdownMenuItem(value: 2, child: Text('Trung bình')),
                        DropdownMenuItem(value: 3, child: Text('Cao')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPriority = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Mức độ ưu tiên'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newTask = TaskModel(
                      id: const Uuid().v4(),
                      title: titleController.text,
                      description: descriptionController.text,
                      createdAt: DateTime.now(),
                      completed: false,
                      status: selectedStatus,
                      priority: selectedPriority,
                    );
                    await TaskService.addTask(newTask);
                    Navigator.pop(context);
                    _fetchTasks();
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _filteredTasks.length,
      itemBuilder: (context, index) {
        final task = _filteredTasks[index];
        return ListTile(
          leading: Icon(
            Icons.flag,
            color: _getPriorityColor(task.priority),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
              '${task.description}\nTrạng thái: ${task.status}\nThời gian: ${task.getFormattedDate()}'),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: task.completed,
                onChanged: (_) => _toggleDone(task),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTask(task.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKanbanView() {
    final statuses = ['To do', 'In progress', 'Done', 'Cancelled'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final tasksByStatus =
          _filteredTasks.where((task) => task.status == status).toList();
          return Container(
            width: 300,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blue,
                  child: Text(status,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                ...tasksByStatus.map((task) => ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description),
                  trailing: Icon(
                    Icons.flag,
                    color: _getPriorityColor(task.priority),
                  ),
                )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTasks,
          ),
          IconButton(
            icon: Icon(_isKanbanView ? Icons.list : Icons.view_column),
            onPressed: () {
              setState(() {
                _isKanbanView = !_isKanbanView;
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedStatus,
                    items: ['Tất cả', 'To do', 'In progress', 'Done', 'Cancelled']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedStatus = value;
                        _applyFilters();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _selectedPriority,
                    hint: const Text('Ưu tiên'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 1, child: Text('Thấp')),
                      DropdownMenuItem(value: 2, child: Text('Trung bình')),
                      DropdownMenuItem(value: 3, child: Text('Cao')),
                    ],
                    onChanged: (value) {
                      _selectedPriority = value;
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<TaskModel>>(
              future: _taskFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (_filteredTasks.isEmpty) {
                  return const Center(child: Text('Không có công việc nào'));
                }

                return _isKanbanView ? _buildKanbanView() : _buildListView();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
