import 'package:flutter/material.dart';

import '../main.dart';

// Tab "Cá nhân": avatar + tên + email, danh sách menu, và nút Đăng xuất
// (màu đỏ) đưa người dùng quay lại WelcomeScreen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _notAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng đang phát triển')),
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cá nhân',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1769E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nguyễn Văn A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'nguyenvana@example.com',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.person_outline,
                  label: 'Thông tin cá nhân',
                  onTap: () => _notAvailable(context),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.pie_chart_outline,
                  label: 'Cài đặt ngân sách',
                  onTap: () => _notAvailable(context),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.category_outlined,
                  label: 'Danh mục chi tiêu',
                  onTap: () => _notAvailable(context),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.cloud_upload_outlined,
                  label: 'Sao lưu dữ liệu',
                  onTap: () => _notAvailable(context),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.lock_outline,
                  label: 'Đổi mật khẩu',
                  onTap: () => _notAvailable(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: _MenuTile(
              icon: Icons.logout,
              label: 'Đăng xuất',
              color: const Color(0xFFEB5757),
              onTap: () => _logout(context),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (color == Colors.black87)
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}