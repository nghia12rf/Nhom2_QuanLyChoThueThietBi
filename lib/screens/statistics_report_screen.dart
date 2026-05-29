import 'package:flutter/material.dart';
import '../services/thongke_service.dart';

class StatisticsReportScreen extends StatelessWidget {
  const StatisticsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Báo cáo & Thống kê',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Tồn kho'),
              Tab(icon: Icon(Icons.trending_up), text: 'Hiệu suất'),
              Tab(icon: Icon(Icons.warning_amber_rounded), text: 'Sự cố'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _InventoryReportView(),
            _PerformanceReportView(),
            _IncidentReportView(),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// 1. INVENTORY (TỒN KHO)
////////////////////////////////////////////////////////

class _InventoryReportView extends StatelessWidget {
  const _InventoryReportView();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: ThongKeService().getTonKho(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        // ✅ Parse đúng API dạng List
        int ready = 0, rented = 0, maintenance = 0;
        final data = snapshot.data;

        if (data is List) {
          for (var item in data) {
            final status = item['trangThai'] as String? ?? '';
            final count = (item['soLuong'] as num?)?.toInt() ?? 0;

            if (status == 'SanSang') {
              ready = count;
            } else if (status == 'DangChoThue') {
              rented = count;
            } else if (status == 'BaoTri') {
              maintenance = count;
            }
          }
        }

        int total = ready + rented + maintenance;
        if (total == 0) total = 1;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            const Text(
              'Tỷ trọng trạng thái thiết bị',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    /// 🔥 Thanh tỷ lệ
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: ready > 0 ? ready : 1,
                            child: Container(height: 24, color: Colors.green),
                          ),
                          Expanded(
                            flex: rented > 0 ? rented : 1,
                            child: Container(height: 24, color: Colors.orange),
                          ),
                          Expanded(
                            flex: maintenance > 0 ? maintenance : 1,
                            child: Container(height: 24, color: Colors.red),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildLegend('Sẵn sàng', ready, total, Colors.green),
                    const Divider(),
                    _buildLegend('Đang cho thuê', rented, total, Colors.orange),
                    const Divider(),
                    _buildLegend(
                      'Đang bảo trì',
                      maintenance,
                      total,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend(String label, int value, int total, Color color) {
    double percent = total > 0 ? (value / total) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            '$value máy',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 60,
            child: Text(
              '${percent.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// 2. PERFORMANCE (HIỆU SUẤT)
////////////////////////////////////////////////////////

class _PerformanceReportView extends StatelessWidget {
  const _PerformanceReportView();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: ThongKeService().getHieuSuat(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        final data = snapshot.data;

        if (data is! List || data.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            final name = item['tenThietBi'] ?? '';
            final rentals = (item['soLuotThue'] as num?)?.toInt() ?? 0;
            final revenue = (item['tongDoanhThu'] as num?)?.toInt() ?? 0;

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey.withOpacity(0.1),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$rentals lượt thuê'),
                trailing: Text(
                  '${revenue.toString()} đ',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

////////////////////////////////////////////////////////
/// 3. INCIDENT (SỰ CỐ)
////////////////////////////////////////////////////////

class _IncidentReportView extends StatelessWidget {
  const _IncidentReportView();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: ThongKeService().getSuCo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        final data = snapshot.data;

        if (data is! List || data.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            final name = item['tenSuCo'] ?? '';
            final count = (item['soLuong'] as num?)?.toInt() ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: count / 100, // tuỳ backend chỉnh lại
                    backgroundColor: Colors.grey[200],
                    color: Colors.redAccent,
                    minHeight: 8,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
