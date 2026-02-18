import 'package:flutter/material.dart';

enum CalendarEntrySourceType { order, appointment }

class CalendarEntry {
  CalendarEntry({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.statusKey,
    required this.sourceType,
    this.subtitle,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String statusKey;
  final String? subtitle;
  final Map<String, dynamic> metadata;
  final CalendarEntrySourceType sourceType;

  CalendarEntry copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
    String? statusKey,
    String? subtitle,
    Map<String, dynamic>? metadata,
    CalendarEntrySourceType? sourceType,
  }) {
    return CalendarEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      statusKey: statusKey ?? this.statusKey,
      subtitle: subtitle ?? this.subtitle,
      metadata: metadata ?? this.metadata,
      sourceType: sourceType ?? this.sourceType,
    );
  }
}

class CalendarStatusPalette {
  const CalendarStatusPalette._();

  static Color colorForStatus(BuildContext context, String statusKey) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    switch (statusKey.toLowerCase()) {
      case 'pending':
      case 'scheduled':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
      case 'inprogress':
      case 'in_progress':
      case 'in progress':
        return Colors.purple;
      case 'shipped':
        return Colors.teal;
      case 'delivered':
      case 'completed':
      case 'finished':
        return Colors.green;
      case 'cancelled':
      case 'declined':
      case 'canceled':
      case 'noshow':
      case 'no_show':
      case 'no show':
        return colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }
}
