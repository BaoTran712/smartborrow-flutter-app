import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;
  bool obscure3 = true;

  @override
  void dispose() {
    oldPassController.dispose();
    newPassController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: oldPassController,
              obscureText: obscure1,
              decoration: InputDecoration(
                labelText: "Mật khẩu cũ",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure1 ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscure1 = !obscure1;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: newPassController,
              obscureText: obscure2,
              decoration: InputDecoration(
                labelText: "Mật khẩu mới",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure2 ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscure2 = !obscure2;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: confirmController,
              obscureText: obscure3,
              decoration: InputDecoration(
                labelText: "Xác nhận mật khẩu",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_reset),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure3 ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscure3 = !obscure3;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (newPassController.text.isEmpty ||
                      confirmController.text.isEmpty ||
                      oldPassController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vui lòng nhập đầy đủ thông tin"),
                      ),
                    );
                    return;
                  }

                  if (newPassController.text != confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Mật khẩu xác nhận không khớp"),
                      ),
                    );
                    return;
                  }

                  final ok = await auth.updatePassword(
                    oldPassController.text,
                    newPassController.text,
                  );

                  if (!context.mounted) return;

                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đổi mật khẩu thành công")),
                    );

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mật khẩu cũ không đúng")),
                    );
                  }
                },
                child: const Text("Đổi mật khẩu"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
