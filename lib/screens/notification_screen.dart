import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom2_quanlythietbichothue/models/notification_model.dart';
import 'package:nhom2_quanlythietbichothue/services/notification_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationModel>> _future;
  String _filter = 'all'; // all, unread, read

  @override
  void initState() {
    super.initState();
    _future = NotificationService().getNotifications();
  }

  Future<void> _reload() async {
    setState(() {
      _future = NotificationService().getNotifications();
    });
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService().markAllAsRead();
      await _reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'HopDong':
        return Icons.assignment;
      case 'BaoTri':
        return Icons.build;
      case 'QuaHan':
        return Icons.warning_amber_rounded;
      case 'ThuHoi':
        return Icons.assignment_return;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'HopDong':
        return AppTheme.infoColor;
      case 'BaoTri':
        return AppTheme.warningColor;
      case 'QuaHan':
        return AppTheme.errorColor;
      case 'ThuHoi':
        return AppTheme.successColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final selected = _filter == value;

    return ChoiceChip(
      selected: selected,
      label: Text('$label $count'),
      onSelected: (_) {
        setState(() {
          _filter = value;
        });
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.15),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    final color = _getColor(item.loaiThongBao);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: item.daDoc ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.daDoc ? Colors.grey.shade200 : color.withOpacity(0.35),
        ),
      ),
      color: item.daDoc ? Colors.white : color.withOpacity(0.08),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(_getIcon(item.loaiThongBao), color: color),
        ),
        title: Text(
          item.tieuDe,
          style: TextStyle(
            fontSize: 16,
            fontWeight: item.daDoc ? FontWeight.w600 : FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.noiDung,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(item.ngayTao),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        trailing: item.daDoc
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                tooltip: 'Đánh dấu đã đọc',
                icon: const Icon(Icons.mark_email_read_outlined),
                color: color,
                onPressed: () async {
                  try {
                    await NotificationService().markAsRead(item.maThongBao);
                    await _reload();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                  }
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> notifications,
  ) {
    if (_filter == 'unread') {
      return notifications.where((item) => !item.daDoc).toList();
    }

    if (_filter == 'read') {
      return notifications.where((item) => item.daDoc).toList();
    }

    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Thông báo'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Đọc tất cả',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<NotificationModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildEmptyState('Không tải được thông báo'),
                ],
              );
            }

            final notifications = snapshot.data ?? [];

            final total = notifications.length;
            final unread = notifications.where((item) => !item.daDoc).length;
            final read = notifications.where((item) => item.daDoc).length;
            final filteredNotifications = _filterNotifications(notifications);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả', 'all', total),
                      const SizedBox(width: 8),
                      _buildFilterChip('Chưa đọc', 'unread', unread),
                      const SizedBox(width: 8),
                      _buildFilterChip('Đã đọc', 'read', read),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (notifications.isEmpty)
                  _buildEmptyState('Chưa có thông báo nào')
                else if (filteredNotifications.isEmpty)
                  _buildEmptyState('Không có thông báo phù hợp')
                else
                  ...filteredNotifications.map(_buildNotificationCard),
              ],
            );
          },
        ),
      ),
    );
  }
}