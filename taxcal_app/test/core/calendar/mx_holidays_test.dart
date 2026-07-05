import 'package:flutter_test/flutter_test.dart';
import 'package:taxcal_app/core/calendar/mx_holidays.dart';

void main() {
  group('MxHolidays', () {
    test('fixed-date holidays for 2026', () {
      expect(MxHolidays.isHoliday(DateTime(2026, 1, 1)), isTrue);
      expect(MxHolidays.isHoliday(DateTime(2026, 5, 1)), isTrue);
      expect(MxHolidays.isHoliday(DateTime(2026, 9, 16)), isTrue);
      expect(MxHolidays.isHoliday(DateTime(2026, 12, 25)), isTrue);
    });

    test('first Monday of February 2026 is Feb 2', () {
      // 2026-02-01 is a Sunday, so the first Monday is Feb 2.
      expect(MxHolidays.isHoliday(DateTime(2026, 2, 2)), isTrue);
      expect(MxHolidays.isHoliday(DateTime(2026, 2, 9)), isFalse);
    });

    test('third Monday of March 2026 is Mar 16', () {
      expect(MxHolidays.isHoliday(DateTime(2026, 3, 16)), isTrue);
    });

    test('third Monday of November 2026 is Nov 16', () {
      expect(MxHolidays.isHoliday(DateTime(2026, 11, 16)), isTrue);
    });

    test('ordinary business day is not a holiday', () {
      expect(MxHolidays.isHoliday(DateTime(2026, 6, 10)), isFalse);
    });

    test('weekend detection', () {
      expect(MxHolidays.isWeekend(DateTime(2026, 7, 4)), isTrue); // Saturday
      expect(MxHolidays.isWeekend(DateTime(2026, 7, 6)), isFalse); // Monday
    });

    test('isBusinessDay combines weekend and holiday checks', () {
      expect(MxHolidays.isBusinessDay(DateTime(2026, 1, 1)), isFalse); // holiday
      expect(MxHolidays.isBusinessDay(DateTime(2026, 7, 4)), isFalse); // weekend
      expect(MxHolidays.isBusinessDay(DateTime(2026, 7, 6)), isTrue);
    });
  });
}
