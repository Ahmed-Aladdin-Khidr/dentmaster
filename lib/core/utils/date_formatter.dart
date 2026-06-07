import 'package:intl/intl.dart';

class DateFormatter {
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, HH:mm');
  static final _short = DateFormat('dd/MM/yyyy');

  static String formatDate(DateTime date) => _date.format(date);
  static String formatDateTime(DateTime date) => _dateTime.format(date);
  static String formatShort(DateTime date) => _short.format(date);
  static String formatOrDash(DateTime? date) =>
      date != null ? _date.format(date) : '—';
}
