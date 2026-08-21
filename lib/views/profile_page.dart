import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),

            const SizedBox(height: 20),

            Text(
              user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              user.email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// Lịch sử
            Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: const Text("Lịch sử mượn trả"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.go("/history");
                },
              ),
            ),

            /// Cài đặt
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Cài đặt"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text("Thông tin cá nhân"),
                              onTap: () {
                                Navigator.pop(context);
                                context.push("/profile/edit");
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.lock),
                              title: const Text("Đổi mật khẩu"),
                              onTap: () {
                                Navigator.pop(context);
                                context.push("/profile/password");
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            /// Quản lý thiết bị (Admin)
            Card(
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text("Quản lý thiết bị (Admin)"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.push("/admin/devices");
                },
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  authProvider.logout();
                  context.go("/login");
                },
                icon: const Icon(Icons.logout),
                label: const Text("Đăng xuất"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
