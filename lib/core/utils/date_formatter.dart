/// Date formatting utilities
library;

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _thaiDateFormat = DateFormat('d MMMM yyyy', 'th');
  static final DateFormat _shortDateFormat = DateFormat('d/M/yy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  
  /// แปลงวันที่เป็นรูปแบบไทย เช่น "5 ธันวาคม 2567"
  static String toThaiDate(DateTime date) {
    try {
      return _thaiDateFormat.format(date);
    } catch (_) {
      return _shortDateFormat.format(date);
    }
  }
  
  /// แปลงวันที่เป็นรูปแบบสั้น เช่น "5/12/67"
  static String toShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }
  
  /// แปลงเวลา เช่น "14:30"
  static String toTime(DateTime date) {
    return _timeFormat.format(date);
  }
  
  /// แปลงเป็น relative time เช่น "เมื่อวาน", "3 วันที่แล้ว"
  static String toRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} นาทีที่แล้ว';
      }
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays == 1) {
      return 'เมื่อวาน';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inDays < 30) {
      return '${difference.inDays ~/ 7} สัปดาห์ที่แล้ว';
    } else {
      return toShortDate(date);
    }
  }
  
  /// ตรวจว่าเป็นวันเดียวกันหรือไม่
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  /// ตรวจว่าเป็นวันนี้หรือไม่
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
}
