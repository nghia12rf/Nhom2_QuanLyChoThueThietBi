import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UserGuideScreen extends StatefulWidget {
  const UserGuideScreen({super.key});

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _guides = [
    {
      'title': 'Khởi tạo hợp đồng thuê thiết bị',
      'category': 'Hợp đồng',
      'icon': Icons.assignment_outlined,
      'steps': [
        'Bước 1: Từ màn hình chính, chọn tab "Hợp đồng" ở thanh điều hướng dưới.',
        'Bước 2: Nhấn vào nút Thêm (+) ở góc dưới bên phải màn hình.',
        'Bước 3: Chọn khách hàng thuê thiết bị từ danh sách (hoặc tạo mới khách hàng trước).',
        'Bước 4: Chọn một hoặc nhiều thiết bị cần cho thuê.',
        'Bước 5: Thiết lập Ngày bắt đầu và Ngày kết thúc dự kiến.',
        'Bước 6: Nhập số tiền đặt cọc (nếu có) và ghi chú liên quan.',
        'Bước 7: Kiểm tra kỹ tổng tiền ước tính và bấm "Tạo hợp đồng" để hoàn thành.',
      ],
      'tip': 'Mẹo: Hệ thống tự động kiểm tra trạng thái thiết bị, chỉ những thiết bị có trạng thái "Sẵn sàng" mới xuất hiện trong danh sách lựa chọn.',
    },
    {
      'title': 'Quét mã QR/Barcode thiết bị',
      'category': 'Thiết bị',
      'icon': Icons.qr_code_scanner,
      'steps': [
        'Bước 1: Mở Drawer (Menu bên trái) hoặc nhấn nút Quét mã trên Trang chủ.',
        'Bước 2: Chọn tính năng "Quét mã thiết bị". Sau đó cấp quyền camera nếu được hỏi.',
        'Bước 3: Hướng camera về phía mã QR hoặc Barcode dán trên thiết bị.',
        'Bước 4: Hệ thống tự động nhận diện và chuyển sang trang Chi tiết thiết bị.',
        'Bước 5: Tại đây, bạn có thể xem thông số kỹ thuật, lịch sử thuê, hoặc tiến hành tạo phiếu bàn giao/thu hồi trực tiếp.',
      ],
      'tip': 'Mẹo: Nếu camera không quét được, bạn có thể nhập trực tiếp Mã định danh thiết bị vào ô tìm kiếm.',
    },
    {
      'title': 'Quy trình thu hồi thiết bị & Lập phiếu',
      'category': 'Thu hồi/Trả',
      'icon': Icons.assignment_return_outlined,
      'steps': [
        'Bước 1: Quét mã QR thiết bị hoặc truy cập chi tiết Hợp đồng đang thuê và bấm "Thu hồi".',
        'Bước 2: Xác nhận ngày trả thực tế của khách hàng.',
        'Bước 3: Kiểm tra thiết bị thực tế. Nếu có hư hỏng, tích chọn "Có hư hỏng".',
        'Bước 4: Nhập mô tả hư hỏng, phụ thu phí hư hỏng (nếu có) và chụp ảnh minh chứng bằng camera điện thoại.',
        'Bước 5: Xác nhận số tiền phạt trễ hạn (hệ thống tự động tính dựa trên ngày kết thúc dự kiến).',
        'Bước 6: Bấm "Xác nhận đã thu tiền & Nhận máy" để cập nhật trạng thái thiết bị về "Sẵn sàng" (hoặc "Bảo trì" nếu có hư hỏng).',
      ],
      'tip': 'Lưu ý: Bắt buộc phải chụp ảnh minh chứng rõ nét nếu thiết bị gặp sự cố hoặc hư hỏng để làm căn cứ đối chiếu.',
    },
    {
      'title': 'Yêu cầu gia hạn hợp đồng',
      'category': 'Gia hạn',
      'icon': Icons.event_repeat_outlined,
      'steps': [
        'Bước 1: Mở Drawer bên trái và chọn mục "Yêu cầu gia hạn".',
        'Bước 2: Nhấn nút "+" để gửi yêu cầu gia hạn mới.',
        'Bước 3: Chọn hợp đồng cần gia hạn (hệ thống chỉ hiển thị hợp đồng đang hiệu lực).',
        'Bước 4: Chọn Ngày kết thúc mới và nhập lý do gia hạn của khách hàng.',
        'Bước 5: Nhấn "Gửi yêu cầu". Quản trị viên (Admin) sẽ duyệt yêu cầu này trên trang quản lý.',
      ],
      'tip': 'Mẹo: Sau khi Admin phê duyệt, thời hạn mới của hợp đồng và tổng tiền thuê sẽ tự động cập nhật.',
    },
    {
      'title': 'Quản lý thông tin khách hàng',
      'category': 'Khách hàng',
      'icon': Icons.people_outline,
      'steps': [
        'Bước 1: Truy cập tab "Khách hàng" ở thanh điều hướng dưới.',
        'Bước 2: Xem danh sách và tìm kiếm khách hàng bằng tên, số điện thoại hoặc mã định danh.',
        'Bước 3: Bấm vào khách hàng để xem chi tiết thông tin công ty, người đại diện và lịch sử thuê.',
        'Bước 4: Bấm Thêm (+) để thêm khách hàng mới. Chọn điền "Mã số thuế" nếu là khách hàng doanh nghiệp.',
      ],
      'tip': 'Lưu ý: Đối với doanh nghiệp, hệ thống tự động lưu tên công ty dựa trên mã số thuế đã xác thực.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách hướng dẫn theo danh mục và từ khóa tìm kiếm
    final filteredGuides = _guides.where((guide) {
      final matchesCategory = _selectedCategory == 'Tất cả' || guide['category'] == _selectedCategory;
      final matchesSearch = guide['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (guide['steps'] as List).any((step) => step.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Hướng dẫn sử dụng'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Gradient với Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Cẩm nang Nhân viên',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tra cứu nhanh quy trình vận hành và sử dụng ứng dụng.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                // Thanh tìm kiếm
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm hướng dẫn (vd: tạo hợp đồng, trả máy...)',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ],
            ),
          ),

          // Bộ lọc ngang (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['Tất cả', 'Hợp đồng', 'Thiết bị', 'Thu hồi/Trả', 'Gia hạn', 'Khách hàng']
                  .map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Danh sách các hướng dẫn dạng ExpansionTile
          Expanded(
            child: filteredGuides.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Không tìm thấy kết quả phù hợp',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Vui lòng thử từ khóa khác hoặc thay đổi bộ lọc.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredGuides.length,
                    itemBuilder: (context, index) {
                      final item = filteredGuides[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            title: Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['category'] as String,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            expandedCrossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 20),
                              ... (item['steps'] as List<String>).map((step) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    step,
                                    style: const TextStyle(
                                      height: 1.4,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }),
                              if (item['tip'] != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.successColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.lightbulb_outline,
                                        color: AppTheme.successColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item['tip'] as String,
                                          style: const TextStyle(
                                            color: AppTheme.successColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Chân trang Hỗ trợ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: const Icon(Icons.support_agent, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bạn cần hỗ trợ kỹ thuật?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Liên hệ Admin để giải đáp thắc mắc thêm.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Thông tin hỗ trợ'),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hệ thống Quản lý thiết bị cho thuê - Nhóm 2'),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 18, color: AppTheme.primaryColor),
                                SizedBox(width: 8),
                                Text('Hotline: 0987.654.321'),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.email, size: 18, color: AppTheme.primaryColor),
                                SizedBox(width: 8),
                                Text('Email: admin.nhom2@gmail.com'),
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('ĐÓNG'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Xem'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
