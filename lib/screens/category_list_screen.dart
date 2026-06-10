import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // 1. GET: Lấy danh sách danh mục từ API
  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService().get('/DanhMucThietBi');
      if (!mounted) return;
      setState(() {
        _categories = data is List ? data : (data['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Lỗi tải danh mục: $e', isError: true);
    }
  }

  // 2. POST / PUT: Xử lý Thêm mới hoặc Cập nhật danh mục
  void _showCategoryDialog({Map<String, dynamic>? category}) {
    final isEdit = category != null;
    final textController = TextEditingController(
      text: isEdit ? category['tenDanhMuc'] : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Chỉnh sửa danh mục' : 'Thêm danh mục mới'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tên danh mục',
              hintText: 'Ví dụ: Thiết bị nâng hạ, Xe lu...',
            ),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Không được để trống' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);

              final body = {
                'TenDanhMuc': textController.text.trim(),
              };

              try {
                if (isEdit) {
                  // Put yêu cầu truyền MaDanhMuc cả trên URL và Body trùng nhau
                  body['MaDanhMuc'] = category['maDanhMuc'];
                  await ApiService().put('/DanhMucThietBi/${category['maDanhMuc']}', body);
                  _showSnackBar('Cập nhật danh mục thành công');
                } else {
                  await ApiService().post('/DanhMucThietBi', body);
                  _showSnackBar('Thêm danh mục mới thành công');
                }
                _fetchCategories();
              } catch (e) {
                // Đọc thông báo lỗi dạng JSON từ API nếu có (ví dụ: Tên danh mục đã tồn tại)
                _showSnackBar('Lỗi thực hiện: $e', isError: true);
              }
            },
            child: Text(isEdit ? 'CẬP NHẬT' : 'LƯU'),
          ),
        ],
      ),
    );
  }

  // 3. DELETE: Xóa danh mục
  Future<void> _deleteCategory(int id) async {
    try {
      await ApiService().delete('/DanhMucThietBi/$id');
      _showSnackBar('Xóa danh mục thành công');
      _fetchCategories();
    } catch (e) {
      // Backend chặn không cho xóa nếu danh mục đang gắn liền với thiết bị nào đó
      _showSnackBar('Không thể xóa: Danh mục này đang chứa thiết bị!', isError: true);
    }
  }

  void _showDeleteDialog(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: Text('Bạn có chắc chắn muốn xóa danh mục "${category['tenDanhMuc']}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category['maDanhMuc']);
            },
            child: const Text('XÓA', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('Chưa có danh mục nào.'))
              : RefreshIndicator(
                  onRefresh: _fetchCategories,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index] as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Icon(Icons.folder_open, color: AppTheme.primaryColor),
                          ),
                          title: Text(
                            cat['tenDanhMuc'] ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Mã danh mục: ${cat['maDanhMuc']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                onPressed: () => _showCategoryDialog(category: cat),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _showDeleteDialog(cat),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}