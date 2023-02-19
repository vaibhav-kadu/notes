import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context
          .read<NotificationProvider>()
          .loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {

    final provider =
    context.watch<NotificationProvider>();

    return Scaffold(

      appBar: AppBar(
        title: const Text('Notifications'),
      ),

      body: provider.isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : provider.notifications.isEmpty
          ? const Center(
        child: Text('No notifications'),
      )
          : ListView.builder(

        itemCount:
        provider.notifications.length,

        itemBuilder: (context, index) {

          final item =
          provider.notifications[index];

          return ListTile(

            leading: CircleAvatar(
              child: Icon(
                item.type == 'teacher_request'
                    ? Icons.admin_panel_settings
                    : Icons.notifications,
              ),
            ),

            title: Text(item.title),

            subtitle: Text(item.message),

            isThreeLine:
            item.type == 'teacher_request',

            trailing: item.type == 'teacher_request'

                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                IconButton(
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  onPressed: () async {

                    await context
                        .read<NotificationProvider>()
                        .approveTeacher(item);
                  },
                ),

                IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  onPressed: () async {

                    await context
                        .read<NotificationProvider>()
                        .rejectTeacher(item);
                  },
                ),
              ],
            )

                : item.isRead
                ? null
                : const Icon(
              Icons.brightness_1,
              size: 10,
              color: Colors.red,
            ),

            onTap: () async {

              await provider.markAsRead(
                item.id,
              );
            },
          );
        },
      ),
    );
  }
}