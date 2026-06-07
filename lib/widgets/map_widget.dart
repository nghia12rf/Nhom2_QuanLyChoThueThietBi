import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';

/// Model cho marker trên bản đồ
class MapMarker {
  final String id;
  final String name;
  final LatLng location;
  final String? description;
  final String? icon;
  final Color? color;

  MapMarker({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    this.icon,
    this.color,
  });
}

/// Widget bản đồ sử dụng OpenStreetMap
class MapView extends StatefulWidget {
  final List<MapMarker> markers;
  final LatLng? initialCenter;
  final double initialZoom;
  final ValueChanged<LatLng>? onLocationSelected;
  final VoidCallback? onRefresh;
  final bool showCurrentLocation;

  const MapView({
    required this.markers,
    this.initialCenter,
    this.initialZoom = 12.0,
    this.onLocationSelected,
    this.onRefresh,
    this.showCurrentLocation = false,
    super.key,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late MapController _mapController;
  late List<MapMarker> _markers;
  LatLng? _userLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _markers = widget.markers;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      // Simulated location - in production, use geolocator package
      // For now, use Hanoi as default location
      final location = LatLng(21.0285, 105.8542);
      setState(() => _userLocation = location);
      _mapController.move(location, 15.0);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi lấy vị trí: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Tính toán bounds từ danh sách markers
  LatLngBounds _calculateBounds() {
    if (_markers.isEmpty) {
      return LatLngBounds(
        const LatLng(21.0285, 105.8542),
        const LatLng(21.0285, 105.8542),
      );
    }

    double maxLat = _markers[0].location.latitude;
    double minLat = _markers[0].location.latitude;
    double maxLng = _markers[0].location.longitude;
    double minLng = _markers[0].location.longitude;

    for (var marker in _markers) {
      final lat = marker.location.latitude;
      final lng = marker.location.longitude;

      if (lat > maxLat) {
        maxLat = lat;
      }
      if (lat < minLat) {
        minLat = lat;
      }
      if (lng > maxLng) {
        maxLng = lng;
      }
      if (lng < minLng) {
        minLng = lng;
      }
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  /// Zoom tới tất cả markers
  void _zoomToMarkers() {
    if (_markers.isEmpty) return;
    final bounds = _calculateBounds();
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(100)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Bản đồ chính
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  widget.initialCenter ?? const LatLng(21.0285, 105.8542),
              initialZoom: widget.initialZoom,
              minZoom: 5.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                widget.onLocationSelected?.call(point);
              },
            ),
            children: [
              // Layer Bản đồ OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'nhom2_quanlythietbichothue',
              ),

              // Layer Markers
              MarkerLayer(
                markers: [
                  // User location marker (nếu có)
                  if (_userLocation != null && widget.showCurrentLocation)
                    Marker(
                      point: _userLocation!,
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          _showMarkerInfoDialog(
                            MapMarker(
                              id: 'current',
                              name: 'Vị trí hiện tại',
                              location: _userLocation!,
                              description: 'Vị trí của bạn',
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Equipment markers
                  ..._markers.map((marker) {
                    return Marker(
                      point: marker.location,
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () => _showMarkerInfoDialog(marker),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: marker.color ?? AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [AppTheme.shadowMedium],
                              ),
                              child: Icon(
                                _getIconData(marker.icon),
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            Text(
                              marker.name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  FloatingActionButton.small(
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    // Refresh button
                    FloatingActionButton.small(
                      onPressed: widget.onRefresh,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.refresh,
                        color: AppTheme.primaryColor,
                      ),
                    ),

                    // Current location button
                    if (widget.showCurrentLocation)
                      FloatingActionButton.small(
                        onPressed: _getCurrentLocation,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.my_location,
                          color: AppTheme.primaryColor,
                        ),
                      ),

                    // Zoom to markers button
                    if (_markers.isNotEmpty)
                      FloatingActionButton.small(
                        onPressed: _zoomToMarkers,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.zoom_out_map,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog thông tin marker
  void _showMarkerInfoDialog(MapMarker marker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(marker.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (marker.description != null) ...[
              Text(marker.description!),
              const SizedBox(height: 12),
            ],
            Text(
              'Vị trí: ${marker.location.latitude.toStringAsFixed(4)}, ${marker.location.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Lấy IconData từ chuỗi icon
  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'equipment':
        return Icons.inventory_2;
      case 'location':
        return Icons.location_on;
      case 'customer':
        return Icons.business;
      case 'warehouse':
        return Icons.warehouse;
      default:
        return Icons.location_on;
    }
  }
}

/// Widget bản đồ nhỏ (có thể sử dụng trong danh sách)
class MiniMapView extends StatelessWidget {
  final List<MapMarker> markers;
  final LatLng? center;
  final VoidCallback? onTap;
  final double height;

  const MiniMapView({
    required this.markers,
    this.center,
    this.onTap,
    this.height = 200,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: ClipRRect(
          borderRadius: AppTheme.radiusMedium,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: center ?? const LatLng(21.0285, 105.8542),
                  initialZoom: 13.0,
                  interactionOptions: const InteractionOptions(
                    enableMultiFingerGestureRace: false,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'nhom2_quanlythietbichothue',
                  ),
                  MarkerLayer(
                    markers: markers
                        .map(
                          (marker) => Marker(
                            point: marker.location,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              color: marker.color ?? AppTheme.primaryColor,
                              size: 30,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              // Overlay để hiện tap hint
              if (onTap != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: AppTheme.radiusSmall,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Nhấn để xem chi tiết',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
