import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Make sure to add intl package to your pubspec.yaml
import '../services/api_service.dart';
import '../models/task.dart';  // Ensure this import path matches where your Task model is defined

class TaskCard extends StatelessWidget {
  final Task task;
  final void Function(Task) onTaskChanged;
  final void Function(String) onDeleteTask;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTaskChanged,
    required this.onDeleteTask,
  }) : super(key: key);

  void _handleTaskToggle(bool? newValue) async {
    if (newValue != null) {
      Task updatedTask = task.copyWith(isDone: newValue);
      bool success = await ApiService().markTaskDone(updatedTask.id); // Using the API to mark the task
      if (success) {
        // Handle successful update
        // For example, trigger a state update in the parent widget
      } else {
        // Handle error, possibly show a Snackbar with an error message
      }
    }
  }

   void _handleDeleteTask() async {
    bool success = await ApiService().deleteTask(task.id); // Using the API to delete the task
    if (success) {
      // Handle successful deletion
      // For example, trigger a state update in the parent widget
    } else {
      // Handle error, possibly show a Snackbar with an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () {
          onTaskChanged(task);
        },
        leading: Checkbox(
          value: task.isDone,
          onChanged: (bool? value) {
            // Create a new Task with updated status or you can modify the state directly if using state management
            Task updatedTask = task.copyWith(isDone: value);
            onTaskChanged(updatedTask);
          },
          activeColor: Colors.blue,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description ?? 'No description provided',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text(
              'Due: ${task.dueDate != null ? DateFormat('yyyy-MM-dd – kk:mm').format(task.dueDate!.toLocal()) : "No due date"}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => onDeleteTask(task.id),
        ),
      ),
    );
  }
}
