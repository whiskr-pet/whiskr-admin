import 'package:flutter/material.dart';

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
    this.tooltipTextColor = const Color(0xFFFFFFFF),
    this.lineWidth = 2.0,
    this.dotSize = 4.0,
    this.highlightDotSize = 8.0,
  });
}
