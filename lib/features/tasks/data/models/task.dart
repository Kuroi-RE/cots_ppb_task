class Task {
  final int? id;
  final String title;
  final String course;
  final String deadline; // Format: YYYY-MM-DD
  final String status; // BERJALAN, SELESAI, TERLAMBAT
  final String note;
  final bool isDone;
  final String? createdAt;
  final String? updatedAt;

  Task({
    this.id,
    required this.title,
    required this.course,
    required this.deadline,
    required this.status,
    this.note = '',
    this.isDone = false,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Task to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'course': course,
      'deadline': deadline,
      'status': status,
      'note': note,
      'is_done': isDone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  // Create Task from JSON response
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      title: json['title'] as String,
      course: json['course'] as String,
      deadline: json['deadline'] as String,
      status: json['status'] as String,
      note: json['note'] as String? ?? '',
      isDone: json['is_done'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // Get DateTime object from deadline string
  DateTime? get deadlineDate {
    try {
      return DateTime.parse(deadline);
    } catch (e) {
      return null;
    }
  }

  // Copy with method for updating task
  Task copyWith({
    int? id,
    String? title,
    String? course,
    String? deadline,
    String? status,
    String? note,
    bool? isDone,
    String? createdAt,
    String? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      course: course ?? this.course,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
