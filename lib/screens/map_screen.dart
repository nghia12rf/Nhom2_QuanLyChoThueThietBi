import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/widgets/map_widget.dart';

/// Màn hình bản đồ danh sách thiết bị
class EquipmentMapScreen extends StatefulWidget {
  const EquipmentMapScreen({super.key});

  @override
  State<EquipmentMapScreen> createState() => _EquipmentMapScreenState();
}

class _EquipmentMapScreenState extends State<EquipmentMapScreen> {
  late List<MapMarker> _equipmentMarkers;
  String _filterStatus = 'all'; // all, ready, renting, maintenance

  @override
  void initState() {
    super.initState();
    _loadEquipmentData();
  }

  /// Tải dữ liệu thiết bị và chuyển đổi thành markers
  void _loadEquipmentData() {
    _equipmentMarkers = [
      MapMarker(
        id: 'EQP001',
        name: 'Máy khoan',
        location: const LatLng(21.0285, 105.8542),
        description: 'Máy khoan bê tông - Công ty ABC',
        icon: 'equipment',
        color: AppTheme.successColor,
      ),
      MapMarker(
        id: 'EQP002',
        name: 'Máy phát điện',
        location: const LatLng(21.0350, 105.8600),
        description: 'Máy phát 5kW - Công trình Quận 1',
        icon: 'equipment',
        color: AppTheme.warningColor,
      ),
      MapMarker(
        id: 'EQP003',
        name: 'Máy cẩu',
        location: const LatLng(21.0200, 105.8480),
        description: 'Máy cẩu 10 tấn - Đang bảo trì',
        icon: 'equipment',
        color: AppTheme.errorColor,
      ),
      MapMarker(
        id: 'EQP004',
        name: 'Máy trộn bê tông',
        location: const LatLng(21.0400, 105.8700),
        description: 'Máy trộn 300L - Công ty XYZ',
        icon: 'equipment',
        color: AppTheme.successColor,
      ),
      MapMarker(
        id: 'EQP005',
        name: 'Máy đục tường',
        location: const LatLng(21.0150, 105.8400),
        description: 'Máy đục 2hp - Sẵn sàng',
        icon: 'equipment',
        color: AppTheme.successColor,
      ),
    ];
  }

  /// Lọc theo trạng thái
  List<MapMarker> _getFilteredMarkers() {
    if (_filterStatus == 'all') {
      return _equipmentMarkers;
    }

    return _equipmentMarkers.where((marker) {
      if (_filterStatus == 'ready') {
        return marker.color == AppTheme.successColor;
      }
      if (_filterStatus == 'renting') {
        return marker.color == AppTheme.warningColor;
      }
      if (_filterStatus == 'maintenance') {
        return marker.color == AppTheme.errorColor;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bản Đồ Thiết Bị')),
      body: Stack(
        children: [
          // Bản đồ chính
          MapView(
            markers: _getFilteredMarkers(),
            initialCenter: const LatLng(21.0285, 105.8542),
            initialZoom: 12.0,
            showCurrentLocation: true,
            onRefresh: () {
              setState(_loadEquipmentData);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Làm mới dữ liệu')));
            },
          ),

          // Filter panel (trên cùng)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.radiusMedium,
                  boxShadow: [AppTheme.shadowMedium],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả', 'all', AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Sẵn sàng',
                        'ready',
                        AppTheme.successColor,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Đang thuê',
                        'renting',
                        AppTheme.warningColor,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Bảo trì',
                        'maintenance',
                        AppTheme.errorColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Info panel (dưới cùng)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppTheme.radiusMedium,
                    boxShadow: [AppTheme.shadowMedium],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng thiết bị',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getFilteredMarkers().length}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng filter chip
  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = _filterStatus == value;

    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppTheme.dividerColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
          ),
        ),
      ),
    );
  }
}

/// Màn hình bản đồ danh sách khách hàng
class CustomerMapScreen extends StatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends State<CustomerMapScreen> {
  late List<MapMarker> _customerMarkers;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  /// Tải dữ liệu khách hàng và chuyển đổi thành markers
  void _loadCustomerData() {
    _customerMarkers = [
      MapMarker(
        id: 'CUST001',
        name: 'Công ty ABC',
        location: const LatLng(21.0285, 105.8542),
        description: 'Địa chỉ: 123 Đường Tây Sơn, Hà Nội',
        icon: 'customer',
        color: AppTheme.primaryColor,
      ),
      MapMarker(
        id: 'CUST002',
        name: 'Công ty XYZ',
        location: const LatLng(21.0350, 105.8600),
        description: 'Địa chỉ: 456 Đường Giải Phóng, Hà Nội',
        icon: 'customer',
        color: AppTheme.accentColor,
      ),
      MapMarker(
        id: 'CUST003',
        name: 'Công ty DEF',
        location: const LatLng(21.0200, 105.8480),
        description: 'Địa chỉ: 789 Đường Hoàng Mai, Hà Nội',
        icon: 'customer',
        color: AppTheme.primaryLight,
      ),
      MapMarker(
        id: 'CUST004',
        name: 'Công ty GHI',
        location: const LatLng(21.0400, 105.8700),
        description: 'Địa chỉ: 321 Đường Thanh Xuân, Hà Nội',
        icon: 'customer',
        color: AppTheme.infoColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bản Đồ Khách Hàng')),
      body: MapView(
        markers: _customerMarkers,
        initialCenter: const LatLng(21.0285, 105.8542),
        initialZoom: 12.0,
        showCurrentLocation: true,
        onRefresh: () {
          setState(_loadCustomerData);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Làm mới dữ liệu')));
        },
      ),
    );
  }
}

/// Màn hình bản đồ hợp đồng cho thuê
class RentalMapScreen extends StatefulWidget {
  const RentalMapScreen({super.key});

  @override
  State<RentalMapScreen> createState() => _RentalMapScreenState();
}

class _RentalMapScreenState extends State<RentalMapScreen> {
  late List<MapMarker> _rentalMarkers;

  @override
  void initState() {
    super.initState();
    _loadRentalData();
  }

  /// Tải dữ liệu hợp đồng và chuyển đổi thành markers
  void _loadRentalData() {
    _rentalMarkers = [
      MapMarker(
        id: 'HD001',
        name: 'HD001 - Máy khoan',
        location: const LatLng(21.0285, 105.8542),
        description: 'Khách: Công ty ABC - Công nợ: 5.000.000đ',
        icon: 'equipment',
        color: AppTheme.successColor,
      ),
      MapMarker(
        id: 'HD002',
        name: 'HD002 - Máy phát',
        location: const LatLng(21.0350, 105.8600),
        description: 'Khách: Công ty XYZ - Hạn trả: 20/04/2026',
        icon: 'equipment',
        color: AppTheme.warningColor,
      ),
      MapMarker(
        id: 'HD003',
        name: 'HD003 - Máy cẩu',
        location: const LatLng(21.0200, 105.8480),
        description: 'Khách: Công ty DEF - Đã trả',
        icon: 'equipment',
        color: AppTheme.successColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bản Đồ Hợp Đồng')),
      body: MapView(
        markers: _rentalMarkers,
        initialCenter: const LatLng(21.0285, 105.8542),
        initialZoom: 12.0,
        showCurrentLocation: true,
        onRefresh: () {
          setState(_loadRentalData);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Làm mới dữ liệu')));
        },
      ),
    );
  }
}
