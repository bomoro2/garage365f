import 'package:intl/intl.dart';

class DateFormatters {
  static final _date = DateFormat('dd/MM/yyyy');
  static final _time = DateFormat('HH:mm');

  static String ddMMyyyyHHmm(DateTime dt) =>
      '${_date.format(dt)} · ${_time.format(dt)}';
}
