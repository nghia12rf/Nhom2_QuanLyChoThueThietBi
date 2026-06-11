import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/models/user_account.dart';
import 'package:nhom2_quanlythietbichothue/screens/user_account_form_screen.dart';
import 'package:nhom2_quanlythietbichothue/services/user_account_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/screens/user_account_detail_screen.dart';

class UserAccountListScreen extends StatefulWidget {
  const UserAccountListScreen({super.key});

  @override
  State<UserAccountListScreen> createState() => _UserAccountListScreenState();
}

class _UserAccountListScreenState extends State<UserAccountListScreen> {
  late Future<List<UserAccount>> _futureUsers;

  final TextEditingController _searchController = TextEditingController();

  String _keyword = '';
  String _filter = 'all';

  final List<Map<String, String>> _filters = const [
    {'label': 'Tất cả', 'value': 'all'},
    {'label': 'Nhân viên', 'value': 'employee'},
    {'label': 'Admin', 'value': 'admin'},
    {'label': 'Hoạt động', 'value': 'active'},
    {'label': 'Ngừng hoạt động', 'value': 'inactive'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    _futureUsers = UserAccountService().getUsers();
  }

  Future<void> _refresh() async {
    setState(_loadUsers);
    await _futureUsers;
  }

  List<UserAccount> _applyFilter(List<UserAccount> users) {
    List<UserAccount> result = users;

    if (_filter == 'employee') {
      result = result.where((u) => u.vaiTro == 'Employee').toList();
    } else if (_filter == 'admin') {
      result = result.where((u) => u.vaiTro == 'Admin').toList();
    } else if (_filter == 'active') {
      result = result.where((u) => u.trangThaiHoatDong).toList();
    } else if (_filter == 'inactive') {
      result = result.where((u) => !u.trangThaiHoatDong).toList();
    }

    if (_keyword.trim().isNotEmpty) {
      final key = _keyword.trim().toLowerCase();

      result = result.where((u) {
        final name = u.hoTen.toLowerCase();
        final username = u.tenDangNhap.toLowerCase();
        final email = (u.email ?? '').toLowerCase();

        return name.contains(key) ||
            username.contains(key) ||
            email.contains(key);
      }).toList();
    }

    result.sort((a, b) {
      if (a.vaiTro == 'Admin' && b.vaiTro != 'Admin') return -1;
      if (a.vaiTro != 'Admin' && b.vaiTro == 'Admin') return 1;

      if (a.trangThaiHoatDong != b.trangThaiHoatDong) {
        return a.trangThaiHoatDong ? -1 : 1;
      }

      return a.hoTen.toLowerCase().compareTo(b.hoTen.toLowerCase());
    });

    return result;
  }

  String _roleText(String role) {
    return role == 'Admin' ? 'Quản trị viên' : 'Nhân viên';
  }

  Color _roleColor(String role) {
    return role == 'Admin' ? AppTheme.primaryColor : AppTheme.infoColor;
  }

  String _statusText(bool isActive) {
    return isActive ? 'Hoạt động' : 'Ngừng hoạt động';
  }

  Color _statusColor(bool isActive) {
    return isActive ? AppTheme.successColor : AppTheme.errorColor;
  }

  Future<void> _toggleStatus(UserAccount user) async {
    if (user.vaiTro == 'Admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể ngừng hoạt động tài khoản Admin'),
        ),
      );
      return;
    }

    final newStatus = !user.trangThaiHoatDong;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            newStatus ? 'Mở lại tài khoản?' : 'Ngừng hoạt động tài khoản?',
          ),
          content: Text(
            newStatus
                ? 'Tài khoản này sẽ được phép đăng nhập lại.'
                : 'Tài khoản này sẽ không thể đăng nhập nữa, nhưng lịch sử dữ liệu vẫn được giữ lại.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await UserAccountService().updateStatus(
        maNguoiDung: user.maNguoiDung,
        trangThaiHoatDong: newStatus,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'Đã mở lại tài khoản' : 'Đã ngừng hoạt động tài khoản',
          ),
        ),
      );

      _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _showResetPasswordDialog(UserAccount user) async {
    final controller = TextEditingController();
    bool obscure = true;
    String? errorText;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Reset mật khẩu'),
              content: TextField(
                controller: controller,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  errorText: errorText,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final password = controller.text.trim();

                    if (password.length < 6) {
                      setDialogState(() {
                        errorText = 'Mật khẩu phải có ít nhất 6 ký tự';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, password);
                  },
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result.isEmpty) return;

    try {
      await UserAccountService().resetPassword(
        maNguoiDung: user.maNguoiDung,
        matKhauMoi: result,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset mật khẩu thành công')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _keyword = value);
        },
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, username hoặc email...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _keyword.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _keyword = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _filters[index];
          final isSelected = _filter == item['value'];

          return ChoiceChip(
            label: Text(item['label']!),
            selected: isSelected,
            onSelected: (_) {
              setState(() => _filter = item['value']!);
            },
            selectedColor: AppTheme.primaryColor.withOpacity(0.15),
            labelStyle: TextStyle(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(isActive).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor(isActive).withOpacity(0.4)),
      ),
      child: Text(
        _statusText(isActive),
        style: TextStyle(
          color: _statusColor(isActive),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _roleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _roleText(role),
        style: TextStyle(
          color: _roleColor(role),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildUserCard(UserAccount user) {
    final isActive = user.trangThaiHoatDong;
    final isAdmin = user.vaiTro == 'Admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: _statusColor(isActive).withOpacity(0.12),
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: isAdmin ? AppTheme.primaryColor : _statusColor(isActive),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.hoTen.isNotEmpty ? user.hoTen : user.tenDangNhap,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isActive
                          ? AppTheme.textPrimaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.tenDangNhap}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  if (user.email != null && user.email!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildRoleChip(user.vaiTro),
                      _buildStatusChip(isActive),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            SizedBox(
              width: 42,
              child: isAdmin
                  ? Tooltip(
                      message: 'Không thể khóa tài khoản Admin',
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.grey.shade400,
                      ),
                    )
                  : PopupMenuButton<String>(
                      tooltip: 'Thao tác',
                      offset: const Offset(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // onSelected: (value) {
                      //   if (value == 'toggle') {
                      //     _toggleStatus(user);
                      //   }
                      // },
                      onSelected: (value) async {
                        if (value == 'detail') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UserAccountDetailScreen(user: user),
                            ),
                          );
                        } else if (value == 'edit') {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserAccountFormScreen(user: user),
                            ),
                          );

                          if (result == true) {
                            _refresh();
                          }
                        } else if (value == 'reset') {
                          _showResetPasswordDialog(user);
                        } else if (value == 'toggle') {
                          _toggleStatus(user);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                isActive
                                    ? Icons.block
                                    : Icons.check_circle_outline,
                                color: isActive
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor,
                              ),
                              const SizedBox(width: 10),
                              Text(isActive ? 'Ngừng hoạt động' : 'Mở lại'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'detail',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.infoColor,
                              ),
                              SizedBox(width: 10),
                              Text('Xem chi tiết'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.edit_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: 10),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'reset',
                          child: Row(
                            children: const [
                              Icon(
                                Icons.lock_reset,
                                color: AppTheme.warningColor,
                              ),
                              SizedBox(width: 10),
                              Text('Reset mật khẩu'),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  int _countActive(List<UserAccount> users) {
    return users.where((u) => u.trangThaiHoatDong).length;
  }

  int _countEmployees(List<UserAccount> users) {
    return users.where((u) => u.vaiTro == 'Employee').length;
  }

  int _countAdmins(List<UserAccount> users) {
    return users.where((u) => u.vaiTro == 'Admin').length;
  }

  Widget _buildSummary(List<UserAccount> users) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: [AppTheme.shadowSmall],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Tổng', users.length.toString()),
          _summaryItem('Hoạt động', _countActive(users).toString()),
          _summaryItem('Admin', _countAdmins(users).toString()),
          _summaryItem('Nhân viên', _countEmployees(users).toString()),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Không tìm thấy tài khoản phù hợp',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Thử đổi từ khóa tìm kiếm hoặc bộ lọc',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Quản lý nhân viên'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserAccountFormScreen()),
          );

          if (result == true) {
            _refresh();
          }
        },
        // icon: const Icon(Icons.person_add),
        label: const Text('+'),
      ),
      body: FutureBuilder<List<UserAccount>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];
          final filteredUsers = _applyFilter(users);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 90),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildSummary(users),
                _buildSearchBox(),
                _buildFilterChips(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: Row(
                    children: [
                      Text(
                        'Danh sách tài khoản',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${filteredUsers.length}/${users.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (filteredUsers.isEmpty)
                  SizedBox(height: 360, child: _buildEmptyState())
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: filteredUsers.map(_buildUserCard).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
