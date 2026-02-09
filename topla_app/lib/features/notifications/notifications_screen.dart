import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/constants.dart';
import '../../widgets/empty_states.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Bildirishnomalar (hozircha bo'sh)
  final List<Map<String, dynamic>> _notifications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Bildirishnomalar'),
        actions: [
          if (_notifications.any((n) => n['read'] == false))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Barchasini o\'qish'),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyNotificationsWidget()
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isUnread = notification['read'] == false;
    final type = notification['type'] as String;
    final createdAt = notification['createdAt'] as DateTime;

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'order':
        icon = Iconsax.box;
        iconColor = AppColors.primary;
        break;
      case 'promo':
        icon = Iconsax.flash_1;
        iconColor = AppColors.sale;
        break;
      case 'coupon':
        icon = Iconsax.ticket_discount;
        iconColor = AppColors.accent;
        break;
      default:
        icon = Iconsax.notification;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      decoration: BoxDecoration(
        color:
            isUnread ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: isUnread
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.md),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification['title'],
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['body'],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(createdAt),
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () => _markAsRead(notification['id']),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} daqiqa oldin';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} soat oldin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} kun oldin';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['read'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
  }
}
