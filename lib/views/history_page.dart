import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/device.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../viewmodels/auth_provider.dart';
import '../viewmodels/borrow_provider.dart';
import 'borrow_status.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Timer? _timer;
  final Set<String> _dueSoonNotified = {};
  final Set<String> _dueTodayNotified = {};
  final Set<String> _overdueNotified = {};

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).currentUser;

      if (user != null) {
        Provider.of<BorrowProvider>(
          context,
          listen: false,
        ).fetchUserRecords(user.id);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borrowProvider = context.watch<BorrowProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử mượn trả")),
      body: borrowProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : borrowProvider.records.isEmpty
          ? const Center(
              child: Text(
                "Bạn chưa mượn thiết bị nào",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: borrowProvider.records.length,
              itemBuilder: (context, index) {
                final record = borrowProvider.records[index];

                return FutureBuilder<Device?>(
                  future: DatabaseHelper.instance.getDeviceById(
                    record.deviceId,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    final device = snapshot.data!;

                    final status = getBorrowStatus(
                      dueDate: DateTime.parse(record.dueDate),
                      returnDate: record.returnDate.isNotEmpty
                          ? DateTime.parse(record.returnDate)
                          : null,
                    );

                    if (record.returnDate.isEmpty &&
                    status == BorrowStatus.dueSoon &&
                    !_dueSoonNotified.contains(record.id)) {
                      _dueSoonNotified.add(record.id);

                      NotificationService().showDueSoonNotification(
                        device.name,
                        DateFormat(
                          'dd/MM/yyyy HH:mm:ss',
                        ).format(DateTime.parse(record.dueDate)),
                      );
                    }

                    if (record.returnDate.isEmpty &&
                        status == BorrowStatus.dueToday &&
                        !_dueTodayNotified.contains(record.id)) {
                      _dueTodayNotified.add(record.id);

                      NotificationService().showDueTodayNotification(
                        device.name,
                        DateFormat(
                          'dd/MM/yyyy HH:mm:ss',
                        ).format(DateTime.parse(record.dueDate)),
                      );
                    }

                   if (record.returnDate.isEmpty &&
                      status == BorrowStatus.overdue &&
                      !_overdueNotified.contains(record.id)) {
                      _overdueNotified.add(record.id);

                      NotificationService().showOverdueNotification(
                        device.name,
                        DateFormat(
                          'dd/MM/yyyy HH:mm:ss',
                        ).format(DateTime.parse(record.dueDate)),
                      );
                    }

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                device.imageUrl,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    device.category,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Ngày mượn: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(record.borrowDate))}",
                                  ),
                                  Text(
                                    "Hạn trả: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(record.dueDate))}",
                                  ),
                                  if (record.returnDate.isNotEmpty)
                                    Text(
                                      "Ngày trả: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(record.returnDate))}",
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  backgroundColor: getStatusColor(status),
                                  label: Text(
                                    getStatusText(status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (status != BorrowStatus.returned) ...[
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

                                  await borrowProvider.returnDevice(
                                    record.id,
                                    record.deviceId,
                                    record.userId,
                                  );

                                  _dueSoonNotified.remove(record.id);
                                  _dueTodayNotified.remove(record.id);
                                  _overdueNotified.remove(record.id);

                                  await NotificationService()
                                      .showReturnSuccess(device.name);

                                  if (!mounted) return;

                                  await borrowProvider.fetchUserRecords(
                                    record.userId,
                                  );

                                  if (!mounted) return;

                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Trả thiết bị thành công",
                                      ),
                                    ),
                                  );
                                },
                              child: const Text("Trả"),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}