import 'package:flutter/material.dart';

enum BorrowStatus { borrowing, dueSoon, dueToday, overdue, returned }

// true = test nhanh bằng giây
// false = chạy thật theo ngày
const bool isTestMode = false;

BorrowStatus getBorrowStatus({
  required DateTime dueDate,
  DateTime? returnDate,
}) {
  // Nếu đã trả
  if (returnDate != null) {
    return BorrowStatus.returned;
  }

  final now = DateTime.now();

  // CHẾ ĐỘ TEST (GIÂY)
  if (isTestMode) {
    final remaining = dueDate.difference(now).inSeconds;

    if (remaining > 40) {
      return BorrowStatus.borrowing;
    } else if (remaining > 20) {
      return BorrowStatus.dueSoon;
    } else if (remaining > 0) {
      return BorrowStatus.dueToday;
    } else {
      return BorrowStatus.overdue;
    }
  }

  // CHẾ ĐỘ THẬT (DAYS)
  final today = DateTime(now.year, now.month, now.day);

  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

  final daysLeft = due.difference(today).inDays;

  if (daysLeft < 0) {
    return BorrowStatus.overdue;
  } else if (daysLeft == 0) {
    return BorrowStatus.dueToday;
  } else if (daysLeft == 1) {
    return BorrowStatus.dueSoon;
  } else {
    return BorrowStatus.borrowing;
  }
}

Color getStatusColor(BorrowStatus status) {
  switch (status) {
    case BorrowStatus.borrowing:
      return Colors.green;

    case BorrowStatus.dueSoon:
      return Colors.yellow.shade700;

    case BorrowStatus.dueToday:
      return Colors.orange;

    case BorrowStatus.overdue:
      return Colors.red;

    case BorrowStatus.returned:
      return Colors.blue;
  }
}

String getStatusText(BorrowStatus status) {
  switch (status) {
    case BorrowStatus.borrowing:
      return "Đang mượn";

    case BorrowStatus.dueSoon:
      return "Sắp quá hạn";

    case BorrowStatus.dueToday:
      return "Hạn cuối trả";

    case BorrowStatus.overdue:
      return "Quá hạn";

    case BorrowStatus.returned:
      return "Đã trả";
  }
}
