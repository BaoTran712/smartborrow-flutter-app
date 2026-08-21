import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/cart_provider.dart';
import '../viewmodels/borrow_provider.dart';
import '../viewmodels/auth_provider.dart';
import '../viewmodels/device_provider.dart';
import '../models/borrow_record.dart';
import '../services/notification_service.dart';


class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.items.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ mượn thiết bị')),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Giỏ mượn đang trống',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final device = items[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Image.network(
                            device.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image),
                          ),
                          title: Text(
                            device.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(device.category),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              cartProvider.removeItem(device.id);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Xóa thiết bị khỏi giỏ mượn thành công!"),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng: ${items.length} thiết bị',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );

                            final user = authProvider.currentUser;

                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng đăng nhập để mượn thiết bị',
                                  ),
                                ),
                              );
                              return;
                            }

                            final borrowProvider = Provider.of<BorrowProvider>(
                              context,
                              listen: false,
                            );

                            final deviceProvider = Provider.of<DeviceProvider>(
                              context,
                              listen: false,
                            );

                            for (var device in items) {
                              final now = DateTime.now();

                              /*CHẾ ĐỘ TEST (GIÂY)
                              final dueDate = now.add(
                                const Duration(seconds: 60),
                              );*/

                              //CHẾ ĐỘ THẬT (7 NGÀY)
                              final dueDate = now.add(const Duration(days: 7));

                              final record = BorrowRecord(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                userId: user.id,
                                deviceId: device.id,
                                borrowDate: now.toIso8601String(),
                                dueDate: dueDate.toIso8601String(),
                                returnDate: '',
                                status: 'approved',
                              );
                              // Lưu lịch sử
                              await borrowProvider.addBorrowRecord(record);

                              // Đổi trạng thái thiết bị
                              await deviceProvider.updateDeviceStatus(
                                device.id,
                                'borrowed',
                              );
                            }

                            // Refresh danh sách thiết bị
                            await deviceProvider.fetchDevices();

                            cartProvider.clear();

                            await NotificationService().showBorrowSuccess(
                              items.length,
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mượn thiết bị thành công!'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                        'Xác nhận mượn',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
