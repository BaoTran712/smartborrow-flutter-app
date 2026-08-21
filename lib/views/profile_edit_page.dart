import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../viewmodels/auth_provider.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().currentUser!;

    nameController = TextEditingController(text: user.name);
    emailController = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin cá nhân")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Họ tên",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newUser = User(
                    id: user.id,
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    password: user.password,
                    role: user.role,
                  );

                  await auth.updateProfile(newUser);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cập nhật thành công")),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Lưu thay đổi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
