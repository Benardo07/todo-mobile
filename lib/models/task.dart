class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isDone,
  });
}