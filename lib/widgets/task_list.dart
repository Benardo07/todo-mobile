// lib/widgets/task_list.dart
import 'package:flutter/material.dart';
import '../models/task.dart';  // Import your Task model

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  const TaskList({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        Task task = tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          trailing: Text(task.dueDate.toIso8601String()),
          tileColor: task.isDone ? Colors.grey[300] : Colors.white,
        );
      },
    );
  }
}
