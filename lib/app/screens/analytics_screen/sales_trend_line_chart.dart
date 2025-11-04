import 'package:flutter/material.dart';

/// MOVE TO module and provider

class RevenueDataPoint {
  final DateTime date;
  final double amount;
  final bool isHighlighted;

  RevenueDataPoint({required this.date, required this.amount, this.isHighlighted = false});

  RevenueDataPoint copyWith({DateTime? date, double? amount, bool? isHighlighted}) {
    return RevenueDataPoint(date: date ?? this.date, amount: amount ?? this.amount, isHighlighted: isHighlighted ?? this.isHighlighted);
  }

  @override
  String toString() => 'RevenueDataPoint(date: $date, amount: $amount, highlighted: $isHighlighted)';
}

/// Model for the entire revenue trend chart
class RevenueTrendData {
  final List<RevenueDataPoint> dataPoints;
  final String title;
  final TimePeriod period;

  RevenueTrendData({required this.dataPoints, this.title = 'Revenue trend', this.period = TimePeriod.lastYear});

  double get maxRevenue {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
  }

  double get minRevenue {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((e) => e.amount).reduce((a, b) => a < b ? a : b);
  }

  double get averageRevenue {
    if (dataPoints.isEmpty) return 0;
    final sum = dataPoints.map((e) => e.amount).reduce((a, b) => a + b);
    return sum / dataPoints.length;
  }

  RevenueDataPoint? get highlightedPoint {
    try {
      return dataPoints.firstWhere((point) => point.isHighlighted);
    } catch (e) {
      return null;
    }
  }

  List<RevenueDataPoint> getDataInRange(DateTime start, DateTime end) {
    return dataPoints.where((point) {
      return point.date.isAfter(start.subtract(const Duration(days: 1))) && point.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  RevenueTrendData copyWith({List<RevenueDataPoint>? dataPoints, String? title, TimePeriod? period}) {
    return RevenueTrendData(dataPoints: dataPoints ?? this.dataPoints, title: title ?? this.title, period: period ?? this.period);
  }
}

enum TimePeriod {
  lastYear,
  lastMonth,
  lastWeek,
  custom;

  String get displayName {
    switch (this) {
      case TimePeriod.lastYear:
        return 'Last Year';
      case TimePeriod.lastMonth:
        return 'Last Month';
      case TimePeriod.lastWeek:
        return 'Last Week';
      case TimePeriod.custom:
        return 'Custom';
    }
  }
}

class RevenueChartStyle {
  final Color lineColor;
  final Color fillColor;
  final Color highlightColor;
  final Color gridColor;
  final Color labelColor;
  final Color tooltipBackgroundColor;
  final Color tooltipTextColor;
  final double lineWidth;
  final double dotSize;
  final double highlightDotSize;

  const RevenueChartStyle({
    this.lineColor = const Color(0xFF0F766E), // Teal
    this.fillColor = const Color(0x1A0F766E), // Teal with opacity
    this.highlightColor = const Color(0xFF0F766E),
    this.gridColor = const Color(0xFFE5E7EB),
    this.labelColor = const Color(0xFF6B7280),
    this.tooltipBackgroundColor = const Color(0xFF0F766E),
    this.tooltipTextColor = Colors.white,
    this.lineWidth = 2.0,
    this.dotSize = 4.0,
    this.highlightDotSize = 8.0,
  });
}

class RevenueTrendDataGenerator {
  /// Generate sample data for the last year
  static RevenueTrendData generateLastYearData() {
    final now = DateTime.now();
    final startDate = DateTime(now.year - 1, now.month, 1);

    final List<RevenueDataPoint> points = [];

    // Generate monthly data points with some variation
    for (int i = 0; i < 365; i += 7) {
      final date = startDate.add(Duration(days: i));
      final baseAmount = 45000.0;
      final variation = (i % 30) * 500;
      final spike = i == 120 ? 40000 : 0; // Spike in April

      points.add(
        RevenueDataPoint(
          date: date,
          amount: baseAmount + variation + spike,
          isHighlighted: i == 120, // Highlight the spike
        ),
      );
    }

    return RevenueTrendData(dataPoints: points, title: 'Revenue trend', period: TimePeriod.lastYear);
  }

  static RevenueTrendData generateCustomData({required DateTime startDate, required DateTime endDate, int dataPoints = 50, double minAmount = 20000, double maxAmount = 90000}) {
    final List<RevenueDataPoint> points = [];
    final daysDiff = endDate.difference(startDate).inDays;
    final interval = daysDiff / dataPoints;

    for (int i = 0; i < dataPoints; i++) {
      final date = startDate.add(Duration(days: (i * interval).round()));
      final amount = minAmount + (maxAmount - minAmount) * (i / dataPoints);

      points.add(RevenueDataPoint(date: date, amount: amount));
    }

    return RevenueTrendData(dataPoints: points, title: 'Revenue trend', period: TimePeriod.custom);
  }
}
