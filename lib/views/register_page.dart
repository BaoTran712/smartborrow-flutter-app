import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Họ tên"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mật khẩu"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Nhập lại mật khẩu"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Đăng ký"),

                onPressed: () async {
                  if (password.text != confirm.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Mật khẩu xác nhận không khớp"),
                      ),
                    );
                    return;
                  }

                  final ok = await auth.register(
                    name.text,
                    email.text,
                    password.text,
                  );

                  if (!context.mounted) return;

                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đăng ký thành công")),
                    );

                    context.pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Email đã tồn tại")),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
