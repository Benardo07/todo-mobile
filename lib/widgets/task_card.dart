import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/task.dart';

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

  @override
  Widget build(BuildContext context) {
    bool isPastDue = task.dueDate != null && !task.isDone && task.dueDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isPastDue ? BorderSide(color: Colors.red, width: 2) : BorderSide.none,
      ),
      child: ListTile(
        onTap: () => onTaskChanged(task),
        leading: Checkbox(
          value: task.isDone,
          onChanged: (bool? value) {
            Task updatedTask = task.copyWith();
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
              'Due: ${task.dueDate != null ? DateFormat('yyyy-MM-dd hh:mm a').format(task.dueDate!.toLocal()) : "No due date"}${isPastDue ? " - Past Due Time" : ""}',
              style: TextStyle(fontSize: 12, color: isPastDue ? Colors.red : Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => onDeleteTask(task.id),
        ),
      ),
      elevation: isPastDue ? 8 : 1,
      shadowColor: isPastDue ? Colors.red : Colors.black,
    );
  }
}
