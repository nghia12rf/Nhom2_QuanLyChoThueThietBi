import 'package:nhom2_quanlythietbichothue/models/notification_model.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  Future<List<NotificationModel>> getNotifications() async {
    final data = await _api.get('/ThongBao');

    if (data is List) {
      return data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<Map<String, int>> getStatistics() async {
    final data = await _api.get('/ThongBao/ThongKe');

    return {
      'tongThongBao': data['tongThongBao'] ?? 0,
      'thongBaoChuaDoc': data['thongBaoChuaDoc'] ?? 0,
      'thongBaoDaDoc': data['thongBaoDaDoc'] ?? 0,
    };
  }

  Future<void> markAsRead(int id) async {
    await _api.put('/ThongBao/$id/DaDoc', {});
  }

  Future<void> markAllAsRead() async {
    await _api.put('/ThongBao/DocTatCa', {});
  }

  Future<void> deleteReadNotifications() async {
    await _api.delete('/ThongBao/XoaDaDoc');
  }

  Future<void> deleteNotification(int id) async {
    await _api.delete('/ThongBao/$id');
  }
}