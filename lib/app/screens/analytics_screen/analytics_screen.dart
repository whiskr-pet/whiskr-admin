import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:w_components/w_components.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:whiskr_admin_panel/app/screens/analytics_screen/sales_trend_line_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late RevenueTrendData revenueData;
  TimePeriod selectedPeriod = TimePeriod.lastYear;

  @override
  void initState() {
    super.initState();
    // Generate sample data
    revenueData = RevenueTrendDataGenerator.generateLastYearData();
  }

  void _changePeriod(TimePeriod period) {
    setState(() {
      selectedPeriod = period;
      // In a real app, you would fetch different data here
      if (period == TimePeriod.lastYear) {
        revenueData = RevenueTrendDataGenerator.generateLastYearData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _BuildBody(revenueData: revenueData, selectedPeriod: selectedPeriod, changePeriod: _changePeriod),
    );
  }
}

class _BuildBody extends StatelessWidget {
  const _BuildBody({super.key, required this.revenueData, required this.selectedPeriod, this.changePeriod});

  final RevenueTrendData revenueData;
  final TimePeriod selectedPeriod;
  final Function(TimePeriod timePeriod)? changePeriod;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.value(context: context, mobile: 24.0, tablet: 16.0, desktop: 24.0, widescreen: 32.0);

    final verticalPadding = Responsive.value(context: context, mobile: 16.0, tablet: 12.0, desktop: 16.0, widescreen: 20.0);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BuildHeader(),
          const SizedBox(height: 20),
          _RevenueSegment(),
          const SizedBox(height: 20),
          _ProductStatisticSegment(),
          const SizedBox(height: 20),
          _OrderStatisticSegment(),
          const SizedBox(height: 20),
          Card(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: ColorHelper.white.color),
              height: 400,
              child: _SalesTrendStatistic(revenueData: revenueData, selectedPeriod: selectedPeriod, changePeriod: changePeriod),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double titleSize = Responsive.value(context: context, mobile: 24.0, tablet: 22.0, desktop: 24.0, widescreen: 28.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analytics', style: theme.textTheme.headlineMedium!.copyWith(fontSize: titleSize)),
        SizedBox(height: Responsive.value(context: context, mobile: 25.0, tablet: 20.0, desktop: 25.0, widescreen: 30.0)),
      ],
    );
  }
}

class _RevenueSegment extends StatelessWidget {
  const _RevenueSegment({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        WhiskrAdminOverviewCards(
          title: "Today's Revenue",
          value: 'KM 123',
          icon: Icons.money,
          iconBackgroundColor: Color.fromRGBO(74, 217, 145, 1),
          cardWidthValue: MediaQuery.of(context).size.width / 2.5,
        ),
        WhiskrAdminOverviewCards(
          title: "Total's Revenue",
          value: 'KM 123,000',
          icon: Icons.attach_money,
          iconBackgroundColor: Color.fromRGBO(255, 144, 102, 1),
          cardWidthValue: MediaQuery.of(context).size.width / 2.5,
        ),
      ],
    );
  }
}

class _ProductStatisticSegment extends StatelessWidget {
  const _ProductStatisticSegment({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product Statistics', style: theme.textTheme.bodyMedium!.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WhiskrAdminOverviewCards(
              title: "Total Products",
              value: '253',
              icon: Icons.home,
              iconBackgroundColor: Color.fromRGBO(152, 188, 109, 1),
              cardWidthValue: MediaQuery.of(context).size.width / 2.5,
            ),
            WhiskrAdminOverviewCards(title: "Low Stock", value: '7', icon: Icons.warning, iconBackgroundColor: Color.fromRGBO(242, 163, 0, 1), cardWidthValue: MediaQuery.of(context).size.width / 2.5),
          ],
        ),
      ],
    );
  }
}

class _OrderStatisticSegment extends StatelessWidget {
  const _OrderStatisticSegment({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Statistics', style: theme.textTheme.bodyMedium!.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WhiskrAdminOverviewCards(title: "Pending", value: '12', icon: Icons.pending, iconBackgroundColor: Color.fromRGBO(242, 163, 0, 1)),
            WhiskrAdminOverviewCards(title: "Confirmed", value: '7', icon: Icons.check, iconBackgroundColor: Color.fromRGBO(152, 188, 109, 1)),
            WhiskrAdminOverviewCards(title: "Processing", value: '1', icon: Icons.model_training, iconBackgroundColor: Color.fromRGBO(236, 76, 14, 1)),
            WhiskrAdminOverviewCards(title: "Delivered", value: '27', icon: Icons.delivery_dining, iconBackgroundColor: Color.fromRGBO(17, 79, 60, 1)),
          ],
        ),
      ],
    );
  }
}

class _SalesTrendStatistic extends StatelessWidget {
  const _SalesTrendStatistic({super.key, required this.revenueData, required this.selectedPeriod, this.changePeriod});

  final RevenueTrendData revenueData;
  final TimePeriod selectedPeriod;
  final Function(TimePeriod timePeriod)? changePeriod;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              revenueData.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            Row(
              children: [
                _FilterButton(
                  label: 'Last Year',
                  isSelected: selectedPeriod == TimePeriod.lastYear,
                  onTap: () {
                    if (changePeriod != null) {
                      changePeriod!(TimePeriod.lastYear);
                    }
                  },
                ),
                const SizedBox(width: 12),
                _FilterButton(label: 'Revenue', isSelected: false, onTap: () {}),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
        Expanded(
          child: RevenueLineChart(data: revenueData, style: const RevenueChartStyle()),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF6B7280), fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_up, color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}

class RevenueLineChart extends StatelessWidget {
  final RevenueTrendData data;
  final RevenueChartStyle style;

  const RevenueLineChart({Key? key, required this.data, required this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20000,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: style.gridColor, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return bottomTitleWidgets(value, meta);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20000,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return leftTitleWidgets(value, meta);
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.dataPoints.length - 1).toDouble(),
        minY: 0,
        maxY: 100000,
        lineBarsData: [
          LineChartBarData(
            spots: data.dataPoints.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.amount);
            }).toList(),
            isCurved: true,
            color: style.lineColor,
            barWidth: style.lineWidth,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final point = data.dataPoints[index];
                if (point.isHighlighted) {
                  return FlDotCirclePainter(radius: style.highlightDotSize, color: style.highlightColor, strokeWidth: 0);
                }
                return FlDotCirclePainter(radius: style.dotSize, color: style.lineColor, strokeWidth: 0);
              },
            ),
            belowBarData: BarAreaData(show: true, color: style.fillColor),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => style.tooltipBackgroundColor,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final point = data.dataPoints[barSpot.x.toInt()];
                final formattedAmount = '\${point.amount.toStringAsFixed(2)}';
                return LineTooltipItem(formattedAmount, TextStyle(color: style.tooltipTextColor, fontWeight: FontWeight.bold, fontSize: 14));
              }).toList();
            },
          ),
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                FlLine(color: style.lineColor.withOpacity(0.3), strokeWidth: 2),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(radius: 6, color: style.highlightColor, strokeWidth: 2, strokeColor: Colors.white);
                  },
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500, fontSize: 12);

    // Show month labels
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

    // Calculate which month to show based on data points
    final index = value.toInt();
    if (index < 0 || index >= data.dataPoints.length) {
      return const SizedBox();
    }

    // Show labels at intervals
    final interval = (data.dataPoints.length / 12).ceil();
    if (index % interval != 0) {
      return const SizedBox();
    }

    final monthIndex = data.dataPoints[index].date.month - 1;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(months[monthIndex], style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500, fontSize: 12);

    String text;
    if (value == 0) {
      return const SizedBox();
    } else if (value >= 1000) {
      text = '${(value / 1000).toInt()}k';
    } else {
      text = value.toInt().toString();
    }

    return Text(text, style: style, textAlign: TextAlign.right);
  }
}
