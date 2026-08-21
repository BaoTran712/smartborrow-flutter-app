import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes/app_router.dart';
import 'services/database_helper.dart';
import 'services/notification_service.dart';

import 'viewmodels/auth_provider.dart';
import 'viewmodels/device_provider.dart';
import 'viewmodels/cart_provider.dart';
import 'viewmodels/borrow_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dùng khi muốn reset database
  final dbPath = await getDatabasesPath();
  await deleteDatabase(join(dbPath, 'app_database.db'));

  // Khởi tạo database
  await DatabaseHelper.instance.database;

  // Khởi tạo Notification
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => BorrowProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QL Thiết Bị',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: AppRouter.router,
    );
  }
}
