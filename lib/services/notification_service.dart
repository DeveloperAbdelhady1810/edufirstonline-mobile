import '../models/notification_item.dart';
import 'api_client.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<List<NotificationItem>> list() async {
    final data = await ApiClient.instance.get('/notifications') as List<dynamic>;
    return data.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> unreadCount() async {
    final data = await ApiClient.instance.get('/notifications/unread-count') as Map<String, dynamic>;
    return (data['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(int id) => ApiClient.instance.post('/notifications/$id/read');

  Future<void> markAllRead() => ApiClient.instance.post('/notifications/mark-all-read');
}
