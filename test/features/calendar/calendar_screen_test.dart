import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:whiskr_admin_panel/features/calendar/calendar_provider.dart';
import 'package:whiskr_admin_panel/features/calendar/calendar_repository.dart';
import 'package:whiskr_admin_panel/features/calendar/calendar_screen.dart';
import 'package:whiskr_admin_panel/features/calendar/models/calendar_entry.dart';

void main() {
  testWidgets('CalendarScreen renders toolbar and calendar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<CalendarProvider>(
        create: (_) => CalendarProvider(repository: _FakeCalendarRepository()),
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.byKey(const Key('calendar_sf_widget')), findsOneWidget);
  });
}

class _FakeCalendarRepository extends CalendarRepository {
  @override
  Future<bool> resolveIsShopType() async => false;

  @override
  Future<List<CalendarEntry>> fetchEntries({
    required bool isShop,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    return <CalendarEntry>[
      CalendarEntry(
        id: '1',
        title: 'Appointment #1',
        start: DateTime(2026, 2, 10, 9),
        end: DateTime(2026, 2, 10, 10),
        statusKey: 'pending',
        subtitle: 'Luna',
        sourceType: CalendarEntrySourceType.appointment,
        metadata: const <String, dynamic>{'customerName': 'John'},
      ),
    ];
  }
}
