class Note {
  int? id;
  int userId;
  String title;
  String content;
  DateTime createdAt;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        title: map['title'] as String,
        content: map['content'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
