import 'package:flutter/material.dart';

import 'calendar_repository.dart';
import 'models/calendar_entry.dart';
import 'models/calendar_filters.dart';
import 'models/calendar_status_option.dart';
import 'models/calendar_view_type.dart';

class CalendarActionResult {
  const CalendarActionResult({required this.isSuccess, this.message});

  final bool isSuccess;
  final String? message;
}

class CalendarProvider extends ChangeNotifier {
  CalendarProvider({CalendarRepository? repository})
    : _repository = repository ?? CalendarRepository();

  final CalendarRepository _repository;

  bool _isShopType = false;
  bool get isShopType => _isShopType;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isMutating = false;
  bool get isMutating => _isMutating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime _focusedDate = DateTime.now();
  DateTime get focusedDate => _focusedDate;

  CalendarViewType _viewType = CalendarViewType.month;
  CalendarViewType get viewType => _viewType;

  DateTime _visibleRangeStart = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime _visibleRangeEnd = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    0,
    23,
    59,
    59,
  );
  DateTime get visibleRangeStart => _visibleRangeStart;
  DateTime get visibleRangeEnd => _visibleRangeEnd;

  CalendarFilters _filters = const CalendarFilters();
  CalendarFilters get filters => _filters;

  List<CalendarEntry> _entries = <CalendarEntry>[];
  List<CalendarEntry> get entries => List<CalendarEntry>.unmodifiable(_entries);

  CalendarEntry? _selectedEntry;
  CalendarEntry? get selectedEntry => _selectedEntry;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<CalendarEntry> get filteredEntries =>
      _entries.where(_matchesFilters).toList(growable: false);

  Set<String> get availableStatuses => _entries
      .map((CalendarEntry e) => e.statusKey)
      .where((String value) => value.isNotEmpty)
      .toSet();

  List<CalendarStatusOption> get statusOptions {
    final CalendarEntrySourceType sourceType = _isShopType
        ? CalendarEntrySourceType.order
        : CalendarEntrySourceType.appointment;
    return CalendarStatusResolver.optionsForSource(sourceType);
  }

  String statusLabelForKey(String key) {
    for (final CalendarStatusOption option in statusOptions) {
      if (option.key == key) {
        return option.label;
      }
    }
    return key;
  }

  Set<String> get availableServiceTypes => _entries
      .map((CalendarEntry e) => '${e.metadata['serviceType'] ?? ''}')
      .where((String value) => value.isNotEmpty)
      .toSet();

  Set<String> get availableResources => _entries
      .map((CalendarEntry e) => '${e.metadata['staffResource'] ?? ''}')
      .where((String value) => value.isNotEmpty)
      .toSet();

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _isShopType = await _repository.resolveIsShopType();
    await fetchEntries();
  }

  Future<void> fetchEntries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _repository.fetchEntries(
        isShop: _isShopType,
        rangeStart: _visibleRangeStart,
        rangeEnd: _visibleRangeEnd,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedEntry(CalendarEntry? entry) {
    _selectedEntry = entry;
    notifyListeners();
  }

  Future<void> setViewType(CalendarViewType viewType) async {
    if (_viewType == viewType) {
      return;
    }

    _viewType = viewType;
    _recalculateVisibleRangeFromFocus();
    notifyListeners();
    await fetchEntries();
  }

  void setFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  Future<void> goToToday() async {
    _focusedDate = DateTime.now();
    _recalculateVisibleRangeFromFocus();
    notifyListeners();
    await fetchEntries();
  }

  Future<void> goToNextPeriod() async {
    switch (_viewType) {
      case CalendarViewType.month:
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
        break;
      case CalendarViewType.week:
        _focusedDate = _focusedDate.add(const Duration(days: 7));
        break;
      case CalendarViewType.day:
        _focusedDate = _focusedDate.add(const Duration(days: 1));
        break;
    }
    _recalculateVisibleRangeFromFocus();
    notifyListeners();
    await fetchEntries();
  }

  Future<void> goToPreviousPeriod() async {
    switch (_viewType) {
      case CalendarViewType.month:
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
        break;
      case CalendarViewType.week:
        _focusedDate = _focusedDate.subtract(const Duration(days: 7));
        break;
      case CalendarViewType.day:
        _focusedDate = _focusedDate.subtract(const Duration(days: 1));
        break;
    }
    _recalculateVisibleRangeFromFocus();
    notifyListeners();
    await fetchEntries();
  }

  Future<void> updateVisibleRange(
    DateTime start,
    DateTime end, {
    DateTime? focusedDate,
  }) async {
    _visibleRangeStart = DateTime(start.year, start.month, start.day);
    _visibleRangeEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    if (focusedDate != null) {
      _focusedDate = focusedDate;
    }
    await fetchEntries();
  }

  void setSearchQuery(String query) {
    _filters = _filters.copyWith(searchQuery: query.trim());
    notifyListeners();
  }

  void toggleStatusFilter(String status) {
    final Set<String> next = Set<String>.from(_filters.statusKeys);
    if (next.contains(status)) {
      next.remove(status);
    } else {
      next.add(status);
    }
    _filters = _filters.copyWith(statusKeys: next);
    notifyListeners();
  }

  void toggleServiceTypeFilter(String type) {
    final Set<String> next = Set<String>.from(_filters.serviceTypes);
    if (next.contains(type)) {
      next.remove(type);
    } else {
      next.add(type);
    }
    _filters = _filters.copyWith(serviceTypes: next);
    notifyListeners();
  }

  void toggleStaffResourceFilter(String resource) {
    final Set<String> next = Set<String>.from(_filters.staffResources);
    if (next.contains(resource)) {
      next.remove(resource);
    } else {
      next.add(resource);
    }
    _filters = _filters.copyWith(staffResources: next);
    notifyListeners();
  }

  Future<void> applyQuickRange(CalendarQuickRange? quickRange) async {
    if (quickRange == null) {
      _filters = _filters.copyWith(clearQuickRange: true);
      notifyListeners();
      return;
    }

    final DateTime now = DateTime.now();
    switch (quickRange) {
      case CalendarQuickRange.today:
        _focusedDate = DateTime(now.year, now.month, now.day);
        break;
      case CalendarQuickRange.thisWeek:
        _focusedDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case CalendarQuickRange.thisMonth:
        _focusedDate = DateTime(now.year, now.month, 1);
        break;
    }

    _filters = _filters.copyWith(quickRange: quickRange);
    _recalculateVisibleRangeFromFocus();
    notifyListeners();
    await fetchEntries();
  }

  void clearFilters() {
    _filters = const CalendarFilters();
    notifyListeners();
  }

  Future<CalendarActionResult> createEntry({
    required String title,
    required DateTime start,
    required DateTime end,
    required String statusKey,
    String? subtitle,
  }) async {
    _isMutating = true;
    notifyListeners();

    try {
      final CalendarEntry created = await _repository.createEntry(
        isShop: _isShopType,
        title: title,
        start: start,
        end: end,
        statusKey: statusKey,
        subtitle: subtitle,
      );
      _entries = <CalendarEntry>[..._entries, created];
      notifyListeners();
      return const CalendarActionResult(
        isSuccess: true,
        message: 'Event created.',
      );
    } catch (e) {
      return CalendarActionResult(
        isSuccess: false,
        message: 'Create failed: $e',
      );
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<CalendarActionResult> editEntry({
    required CalendarEntry current,
    required String title,
    required DateTime start,
    required DateTime end,
    required String statusKey,
    String? subtitle,
  }) async {
    _isMutating = true;
    notifyListeners();

    try {
      final CalendarEntry updated = await _repository.updateEntry(
        isShop: _isShopType,
        current: current,
        title: title,
        start: start,
        end: end,
        statusKey: statusKey,
        subtitle: subtitle,
      );
      _replaceEntry(updated);
      return const CalendarActionResult(
        isSuccess: true,
        message: 'Event updated.',
      );
    } catch (e) {
      return CalendarActionResult(
        isSuccess: false,
        message: 'Update failed: $e',
      );
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<CalendarActionResult> deleteEntry(CalendarEntry entry) async {
    final List<CalendarEntry> previous = List<CalendarEntry>.from(_entries);
    _entries = _entries
        .where((CalendarEntry e) => e.id != entry.id)
        .toList(growable: false);
    _isMutating = true;
    notifyListeners();

    try {
      await _repository.deleteEntry(isShop: _isShopType, id: entry.id);
      if (_selectedEntry?.id == entry.id) {
        _selectedEntry = null;
      }
      return const CalendarActionResult(
        isSuccess: true,
        message: 'Event deleted.',
      );
    } catch (e) {
      _entries = previous;
      return CalendarActionResult(
        isSuccess: false,
        message: 'Delete failed: $e',
      );
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<CalendarActionResult> markStatus(
    CalendarEntry entry,
    String statusKey,
  ) async {
    final CalendarEntry optimistic = entry.copyWith(statusKey: statusKey);
    _replaceEntry(optimistic, notify: false);
    _isMutating = true;
    notifyListeners();

    try {
      final CalendarEntry persisted = await _repository.updateStatus(
        isShop: _isShopType,
        entry: entry,
        statusKey: statusKey,
      );
      _replaceEntry(persisted);
      return const CalendarActionResult(
        isSuccess: true,
        message: 'Status updated.',
      );
    } catch (e) {
      _replaceEntry(entry);
      return CalendarActionResult(
        isSuccess: false,
        message: 'Status update failed: $e',
      );
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<CalendarActionResult> rescheduleEntry({
    required CalendarEntry entry,
    required DateTime newStart,
    required DateTime newEnd,
  }) async {
    final CalendarEntry optimistic = entry.copyWith(
      start: newStart,
      end: newEnd,
    );
    _replaceEntry(optimistic, notify: false);
    _isMutating = true;
    notifyListeners();

    try {
      await _repository.rescheduleEntry(
        isShop: _isShopType,
        entry: entry,
        newStart: newStart,
        newEnd: newEnd,
      );
      return const CalendarActionResult(
        isSuccess: true,
        message: 'Event rescheduled.',
      );
    } catch (e) {
      _replaceEntry(entry);
      return CalendarActionResult(
        isSuccess: false,
        message: 'Reschedule failed: $e',
      );
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  bool _matchesFilters(CalendarEntry entry) {
    if (_filters.statusKeys.isNotEmpty &&
        !_filters.statusKeys.contains(entry.statusKey)) {
      return false;
    }

    final String serviceType = '${entry.metadata['serviceType'] ?? ''}';
    if (_filters.serviceTypes.isNotEmpty &&
        !_filters.serviceTypes.contains(serviceType)) {
      return false;
    }

    final String staffResource = '${entry.metadata['staffResource'] ?? ''}';
    if (_filters.staffResources.isNotEmpty &&
        !_filters.staffResources.contains(staffResource)) {
      return false;
    }

    final String query = _filters.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      final String searchable =
          '${entry.title} ${entry.subtitle ?? ''} ${entry.metadata['customerName'] ?? ''} ${entry.metadata['petName'] ?? ''}'
              .toLowerCase();
      if (!searchable.contains(query)) {
        return false;
      }
    }

    return true;
  }

  void _recalculateVisibleRangeFromFocus() {
    switch (_viewType) {
      case CalendarViewType.month:
        _visibleRangeStart = DateTime(_focusedDate.year, _focusedDate.month, 1);
        _visibleRangeEnd = DateTime(
          _focusedDate.year,
          _focusedDate.month + 1,
          0,
          23,
          59,
          59,
        );
        break;
      case CalendarViewType.week:
        final DateTime monday = _focusedDate.subtract(
          Duration(days: _focusedDate.weekday - 1),
        );
        _visibleRangeStart = DateTime(monday.year, monday.month, monday.day);
        _visibleRangeEnd = _visibleRangeStart.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        break;
      case CalendarViewType.day:
        _visibleRangeStart = DateTime(
          _focusedDate.year,
          _focusedDate.month,
          _focusedDate.day,
        );
        _visibleRangeEnd = DateTime(
          _focusedDate.year,
          _focusedDate.month,
          _focusedDate.day,
          23,
          59,
          59,
        );
        break;
    }
  }

  void _replaceEntry(CalendarEntry updated, {bool notify = true}) {
    _entries = _entries
        .map((CalendarEntry e) => e.id == updated.id ? updated : e)
        .toList(growable: false);
    if (_selectedEntry?.id == updated.id) {
      _selectedEntry = updated;
    }
    if (notify) {
      notifyListeners();
    }
  }
}
