import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {

  List<AppNotification> notifications = [];

  bool isLoading = false;

  Future<void> loadNotifications() async {

    final user = supabase.auth.currentUser;

    if (user == null) return;

    isLoading = true;

    notifyListeners();

    final data = await supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    notifications = (data as List)
        .map((e) => AppNotification.fromJson(e))
        .toList();

    isLoading = false;

    notifyListeners();
  }

  int get unreadCount =>
      notifications.where((e) => !e.isRead).length;

  Future<void> markAsRead(int id) async {

    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);

    await loadNotifications();
  }
}