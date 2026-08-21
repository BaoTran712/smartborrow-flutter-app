import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: settings);
  }

  Future<void> showBorrowSuccess(int count) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'borrow_channel_id',
      'Thông báo mượn thiết bị',
      channelDescription: 'Thông báo khi mượn thiết bị thành công',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 0,
      title: 'Mượn thành công!',
      body: 'Bạn đã mượn thành công $count thiết bị.',
      notificationDetails: platformDetails,
    );
  }

  Future<void> showDueSoonNotification(String deviceName, String dueDate) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'due_soon_channel_id',
      'Thông báo sắp đến hạn trả',
      channelDescription: 'Thông báo khi thiết bị sắp đến hạn trả',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 1,
      title: 'Thiết bị sắp đến hạn trả!',
      body: 'Thiết bị "$deviceName" sẽ đến hạn trả vào ngày $dueDate.',
      notificationDetails: platformDetails,
    );
  }

  Future<void> showDueTodayNotification(
    String deviceName,
    String dueDate,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'due_today_channel_id',
          'Thông báo hạn cuối trả',
          channelDescription: 'Thông báo vào ngày cuối cùng phải trả',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      id: 4,
      title: 'Hôm nay là hạn cuối trả!',
      body:
          'Thiết bị "$deviceName" cần được trả trước khi kết thúc ngày $dueDate.',
      notificationDetails: platformDetails,
    );
  }

  Future<void> showOverdueNotification(String deviceName, String dueDate) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'overdue_channel_id',
      'Thông báo quá hạn trả',
      channelDescription: 'Thông báo khi thiết bị đã quá hạn trả',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 2,
      title: 'Thiết bị đã quá hạn trả!',
      body: 'Thiết bị "$deviceName" đã quá hạn trả từ ngày $dueDate.',
      notificationDetails: platformDetails,
    );
  }

  Future<void> showReturnSuccess(String deviceName) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'return_channel_id',
          'Thông báo trả thiết bị',
          channelDescription: 'Thông báo khi trả thiết bị thành công',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      id: 3,
      title: 'Trả thiết bị thành công!',
      body: 'Bạn đã trả "$deviceName" thành công.',
      notificationDetails: platformDetails,
    );
  }
}