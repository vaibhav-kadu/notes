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

  Future<void> approveTeacher(
      AppNotification notification,
      ) async {

    if (notification.referenceId == null) return;

    // Approve teacher
    await supabase
        .from('users')
        .update({
      'is_verified': true,
    })
        .eq('id', notification.referenceId!);

    // Notify teacher
    await supabase.from('notifications').insert({
      'user_id': notification.referenceId,
      'title': 'Teacher Access Approved',
      'message':
      'Your teacher account has been approved by admin.',
      'type': 'teacher_approved',
    });

    // Mark notification read
    await markAsRead(notification.id);

    await loadNotifications();
  }

  Future<void> rejectTeacher(
      AppNotification notification,
      ) async {

    if (notification.referenceId == null) return;

    // Notify teacher
    await supabase.from('notifications').insert({
      'user_id': notification.referenceId,
      'title': 'Teacher Request Rejected',
      'message':
      'Your teacher request was rejected by admin.',
      'type': 'teacher_rejected',
    });

    // Mark read
    await markAsRead(notification.id);

    await loadNotifications();
  }
}