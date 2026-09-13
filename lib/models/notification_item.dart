class NotificationItem {
  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.readAt,
    required this.createdAt,
  });

  final int id;
  final String type;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] as int,
        type: json['type'] as String? ?? 'general',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        readAt: json['read_at'] != null ? DateTime.tryParse('${json['read_at']}') : null,
        createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      );
}
