import 'package:flutter_test/flutter_test.dart';
import 'package:whiskr_admin_panel/features/calendar/calendar_provider.dart';
import 'package:whiskr_admin_panel/features/calendar/calendar_repository.dart';
import 'package:whiskr_admin_panel/features/calendar/models/calendar_entry.dart';

void main() {
  group('CalendarProvider filters', () {
    test('filters by status and search query', () async {
      final CalendarProvider provider = CalendarProvider(
        repository: _FakeCalendarRepository(),
      );
      await provider.initialize();

      expect(provider.filteredEntries.length, 2);

      provider.toggleStatusFilter('pending');
      expect(provider.filteredEntries.length, 1);
      expect(provider.filteredEntries.first.id, '1');

      provider.clearFilters();
      provider.setSearchQuery('milo');
      expect(provider.filteredEntries.length, 1);
      expect(provider.filteredEntries.first.id, '2');
    });
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
      CalendarEntry(
        id: '2',
        title: 'Appointment #2',
        start: DateTime(2026, 2, 11, 11),
        end: DateTime(2026, 2, 11, 12),
        statusKey: 'confirmed',
        subtitle: 'Milo',
        sourceType: CalendarEntrySourceType.appointment,
        metadata: const <String, dynamic>{'customerName': 'Jane'},
      ),
    ];
  }
}
