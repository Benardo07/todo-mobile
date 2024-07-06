class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.isDone = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

    factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isDone: json['isDone'] ?? false,
      createdAt: DateTime.parse(json['createdAt']), // Parse the DateTime from the string
      updatedAt: DateTime.parse(json['updatedAt']), 
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {

      'title': title,
      'isDone': isDone,
    };

    // Only add description to the JSON if it is not null
    if (description != null) {
      data['description'] = description;
    }else{
      data['description'] = "";
    }

    // Only add dueDate to the JSON if it is not null
    if (dueDate != null) {
      data['dueDate'] = dueDate!.toIso8601String();
    }

    return data;
  }
}
