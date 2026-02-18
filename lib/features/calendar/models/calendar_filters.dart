class CalendarFilters {
  const CalendarFilters({
    this.searchQuery = '',
    this.statusKeys = const <String>{},
    this.serviceTypes = const <String>{},
    this.staffResources = const <String>{},
    this.quickRange,
  });

  final String searchQuery;
  final Set<String> statusKeys;
  final Set<String> serviceTypes;
  final Set<String> staffResources;
  final CalendarQuickRange? quickRange;

  CalendarFilters copyWith({
    String? searchQuery,
    Set<String>? statusKeys,
    Set<String>? serviceTypes,
    Set<String>? staffResources,
    CalendarQuickRange? quickRange,
    bool clearQuickRange = false,
  }) {
    return CalendarFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      statusKeys: statusKeys ?? this.statusKeys,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      staffResources: staffResources ?? this.staffResources,
      quickRange: clearQuickRange ? null : (quickRange ?? this.quickRange),
    );
  }
}

enum CalendarQuickRange { today, thisWeek, thisMonth }
