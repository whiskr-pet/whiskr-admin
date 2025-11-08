import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/w_components.dart';
import 'package:w_components/wa_analytics_top_products/wa_analytics_top_products.dart';
import 'package:w_dashboard/helpers/stock_status_type.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/image_model.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_analytics_module/helpers/time_period_enum.dart';
import 'package:wa_analytics_module/models/revenue_trend_data_model.dart';
import 'package:wa_analytics_module/providers/wa_analytics_provider.dart';
import 'package:wa_inventory_services_module/models/wa_inventory_product_model.dart';

import '../../helpers/analytics_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _getInitialData();
    });
    super.initState();
  }

  Future<void> _getInitialData() async {
    context.read<WAAnalyticsProvider>().loadDataForPeriod(TimePeriod.lastYear);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WAAnalyticsProvider>();
    return Scaffold(
      body: provider.revenueData == null ? const Center(child: CircularProgressIndicator()) : _BuildBody(revenueData: provider.revenueData!),
    );
  }
}

class _BuildBody extends StatelessWidget {
  const _BuildBody({super.key, required this.revenueData});

  final RevenueTrendData revenueData;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.value(context: context, mobile: 24.0, tablet: 32.0, desktop: 40.0, widescreen: 48.0);
    final verticalPadding = Responsive.value(context: context, mobile: 16.0, tablet: 24.0, desktop: 32.0, widescreen: 40.0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BuildHeader(),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0)),
          const _RevenueSegment(),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0)),
          const _ProductStatisticSegment(),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0)),
          const _OrderStatisticSegment(),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0)),
          Card(
            child: Container(
              padding: EdgeInsets.all(Responsive.value(context: context, mobile: 16.0, tablet: 20.0, desktop: 24.0, widescreen: 28.0)),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: ColorHelper.white.color),
              height: Responsive.value(context: context, mobile: 400.0, tablet: 450.0, desktop: 500.0, widescreen: 550.0),
              child: _SalesTrendStatistic(revenueData: revenueData),
            ),
          ),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0)),
          _TopProductsSegment(),
          SizedBox(height: Responsive.value(context: context, mobile: 40.0, tablet: 48.0, desktop: 56.0, widescreen: 64.0)),
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
    final double titleSize = Responsive.value(context: context, mobile: 24.0, tablet: 28.0, desktop: 32.0, widescreen: 36.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: theme.textTheme.headlineMedium!.copyWith(fontSize: titleSize, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: Responsive.value(context: context, mobile: 8.0, tablet: 10.0, desktop: 12.0, widescreen: 14.0)),
        Text(
          'Monitor your business performance and insights',
          style: theme.textTheme.bodyMedium!.copyWith(
            color: Colors.grey[600],
            fontSize: Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0),
          ),
        ),
      ],
    );
  }
}

class _RevenueSegment extends StatelessWidget {
  const _RevenueSegment({super.key});

  @override
  Widget build(BuildContext context) {
    // For tablet: 2 columns, desktop: 2 columns with more space, widescreen: 2 columns with max width
    return ResponsiveBuilder(mobile: _buildMobileLayout(context), tablet: _buildTabletLayout(context), desktop: _buildDesktopLayout(context), widescreen: _buildWidescreenLayout(context));
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Today's Revenue", value: 'KM 123', icon: Icons.money, iconBackgroundColor: const Color.fromRGBO(74, 217, 145, 1)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Total's Revenue", value: 'KM 123,000', icon: Icons.attach_money, iconBackgroundColor: const Color.fromRGBO(255, 144, 102, 1)),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Today's Revenue", value: 'KM 123', icon: Icons.money, iconBackgroundColor: const Color.fromRGBO(74, 217, 145, 1)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Total's Revenue", value: 'KM 123,000', icon: Icons.attach_money, iconBackgroundColor: const Color.fromRGBO(255, 144, 102, 1)),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Today's Revenue", value: 'KM 123', icon: Icons.money, iconBackgroundColor: const Color.fromRGBO(74, 217, 145, 1)),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Total's Revenue", value: 'KM 123,000', icon: Icons.attach_money, iconBackgroundColor: const Color.fromRGBO(255, 144, 102, 1)),
        ),
      ],
    );
  }

  Widget _buildWidescreenLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Today's Revenue", value: 'KM 123', icon: Icons.money, iconBackgroundColor: const Color.fromRGBO(74, 217, 145, 1)),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Total's Revenue", value: 'KM 123,000', icon: Icons.attach_money, iconBackgroundColor: const Color.fromRGBO(255, 144, 102, 1)),
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
    final titleSize = Responsive.value(context: context, mobile: 20.0, tablet: 22.0, desktop: 24.0, widescreen: 26.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Statistics',
          style: theme.textTheme.bodyMedium!.copyWith(fontSize: titleSize, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: Responsive.value(context: context, mobile: 16.0, tablet: 18.0, desktop: 20.0, widescreen: 22.0)),
        ResponsiveBuilder(mobile: _buildMobileLayout(context), tablet: _buildTabletLayout(context), desktop: _buildDesktopLayout(context), widescreen: _buildWidescreenLayout(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Total Products", value: '253', icon: Icons.home, iconBackgroundColor: const Color.fromRGBO(152, 188, 109, 1)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Low Stock", value: '7', icon: Icons.warning, iconBackgroundColor: const Color.fromRGBO(242, 163, 0, 1)),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Total Products", value: '253', icon: Icons.home, iconBackgroundColor: const Color.fromRGBO(152, 188, 109, 1)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Low Stock", value: '7', icon: Icons.warning, iconBackgroundColor: const Color.fromRGBO(242, 163, 0, 1)),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Total Products", value: '253', icon: Icons.home, iconBackgroundColor: const Color.fromRGBO(152, 188, 109, 1)),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Low Stock", value: '7', icon: Icons.warning, iconBackgroundColor: const Color.fromRGBO(242, 163, 0, 1)),
        ),
      ],
    );
  }

  Widget _buildWidescreenLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Total Products", value: '253', icon: Icons.home, iconBackgroundColor: const Color.fromRGBO(152, 188, 109, 1)),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Low Stock", value: '7', icon: Icons.warning, iconBackgroundColor: const Color.fromRGBO(242, 163, 0, 1)),
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
    final titleSize = Responsive.value(context: context, mobile: 20.0, tablet: 22.0, desktop: 24.0, widescreen: 26.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Statistics',
          style: theme.textTheme.bodyMedium!.copyWith(fontSize: titleSize, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: Responsive.value(context: context, mobile: 16.0, tablet: 18.0, desktop: 20.0, widescreen: 22.0)),
        ResponsiveBuilder(mobile: _buildMobileLayout(context), tablet: _buildTabletLayout(context), desktop: _buildDesktopLayout(context), widescreen: _buildWidescreenLayout(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        WhiskrAdminOverviewCards(title: "Pending", value: '12', icon: Icons.pending, iconBackgroundColor: const Color.fromRGBO(242, 163, 0, 1)),
        WhiskrAdminOverviewCards(title: "Confirmed", value: '7', icon: Icons.check, iconBackgroundColor: const Color.fromRGBO(152, 188, 109, 1)),
        WhiskrAdminOverviewCards(title: "Processing", value: '1', icon: Icons.model_training, iconBackgroundColor: const Color.fromRGBO(236, 76, 14, 1)),
        WhiskrAdminOverviewCards(title: "Delivered", value: '27', icon: Icons.delivery_dining, iconBackgroundColor: const Color.fromRGBO(17, 79, 60, 1)),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: WhiskrAdminOverviewCards(title: "Pending", value: '12', icon: Icons.pending, iconBackgroundColor: const Color.fromRGBO(242, 163, 0, 1)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: WhiskrAdminOverviewCards(title: "Confirmed", value: '7', icon: Icons.check, iconBackgroundColor: const Color.fromRGBO(152, 188, 109, 1)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: WhiskrAdminOverviewCards(title: "Processing", value: '1', icon: Icons.model_training, iconBackgroundColor: const Color.fromRGBO(236, 76, 14, 1)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: WhiskrAdminOverviewCards(title: "Delivered", value: '27', icon: Icons.delivery_dining, iconBackgroundColor: const Color.fromRGBO(17, 79, 60, 1)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Pending", value: '12', icon: Icons.pending, iconBackgroundColor: const Color.fromRGBO(242, 163, 0, 1)),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Confirmed", value: '7', icon: Icons.check, iconBackgroundColor: const Color.fromRGBO(152, 188, 109, 1)),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Processing", value: '1', icon: Icons.model_training, iconBackgroundColor: const Color.fromRGBO(236, 76, 14, 1)),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Delivered", value: '27', icon: Icons.delivery_dining, iconBackgroundColor: const Color.fromRGBO(17, 79, 60, 1)),
        ),
      ],
    );
  }

  Widget _buildWidescreenLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Pending", value: '12', icon: Icons.pending, iconBackgroundColor: const Color.fromRGBO(242, 163, 0, 1)),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Confirmed", value: '7', icon: Icons.check, iconBackgroundColor: const Color.fromRGBO(152, 188, 109, 1)),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Processing", value: '1', icon: Icons.model_training, iconBackgroundColor: const Color.fromRGBO(236, 76, 14, 1)),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: WhiskrAdminOverviewCards(title: "Delivered", value: '27', icon: Icons.delivery_dining, iconBackgroundColor: const Color.fromRGBO(17, 79, 60, 1)),
        ),
      ],
    );
  }
}

class _SalesTrendStatistic extends StatelessWidget {
  const _SalesTrendStatistic({super.key, required this.revenueData});

  final RevenueTrendData revenueData;

  @override
  Widget build(BuildContext context) {
    final titleSize = Responsive.value(context: context, mobile: 20.0, tablet: 22.0, desktop: 24.0, widescreen: 26.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                revenueData.title,
                style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
              ),
            ),
            Row(children: [_TimePeriodDropdown(), const SizedBox(width: 12)]),
          ],
        ),
        SizedBox(height: Responsive.value(context: context, mobile: 24.0, tablet: 28.0, desktop: 32.0, widescreen: 40.0)),
        Expanded(
          child: RevenueLineChart(data: revenueData, style: const RevenueChartStyle()),
        ),
      ],
    );
  }
}

class _TimePeriodDropdown extends StatelessWidget {
  const _TimePeriodDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WAAnalyticsProvider>();

    return PopupMenuButton<TimePeriod>(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 8),
      onSelected: (TimePeriod period) {
        provider.setSelectedTimePeriod(period);
      },
      itemBuilder: (BuildContext context) {
        return TimePeriod.values.map((TimePeriod period) {
          final isSelected = provider.selectedPeriod == period;
          return PopupMenuItem<TimePeriod>(
            value: period,
            padding: EdgeInsets.zero,
            child: _HoverMenuItem(
              isSelected: isSelected,
              isFirst: period == TimePeriod.values.first,
              isLast: period == TimePeriod.values.last,
              child: Text(
                period.displayName,
                style: TextStyle(color: const Color(0xFF374151), fontSize: 16, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF0F766E), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.selectedPeriod.displayName,
              style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF0F766E), size: 24),
          ],
        ),
      ),
    );
  }
}

class _HoverMenuItem extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;

  const _HoverMenuItem({required this.child, required this.isSelected, required this.isFirst, required this.isLast});

  @override
  State<_HoverMenuItem> createState() => _HoverMenuItemState();
}

class _HoverMenuItemState extends State<_HoverMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color(0xFFD4E7D7)
              : _isHovered
              ? const Color(0xFFF3F4F6)
              : Colors.white,
          borderRadius: widget.isFirst
              ? const BorderRadius.vertical(top: Radius.circular(12))
              : widget.isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(12))
              : BorderRadius.zero,
        ),
        child: widget.child,
      ),
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
          border: Border.all(color: isSelected ? ColorHelper.greenWeb.color : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(color: isSelected ? ColorHelper.greenWeb.color : const Color(0xFF6B7280), fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_up, color: isSelected ? ColorHelper.greenWeb.color : const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}

class RevenueLineChart extends StatelessWidget {
  final RevenueTrendData data;
  final RevenueChartStyle style;

  const RevenueLineChart({super.key, required this.data, required this.style});

  @override
  Widget build(BuildContext context) {
    final maxY = context.watch<WAAnalyticsProvider>().calculateMaxY(data);
    final interval = context.watch<WAAnalyticsProvider>().calculateInterval(data);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
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
              interval: interval,
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
        maxY: maxY,
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
                final formattedAmount = '\$${point.amount.toStringAsFixed(2)}';
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

    final index = value.toInt();
    if (index < 0 || index >= data.dataPoints.length) {
      return const SizedBox();
    }

    final point = data.dataPoints[index];
    String label;

    switch (data.period) {
      case TimePeriod.lastYear:
        const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
        if (index >= data.dataPoints.length) return const SizedBox();
        label = months[point.date.month - 1];
        break;

      case TimePeriod.lastMonth:
        if (index % 5 != 0) return const SizedBox();
        label = '${point.date.day}';
        break;

      case TimePeriod.lastWeek:
        const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
        label = days[point.date.weekday - 1];
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(label, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500, fontSize: 12);

    if (value == 0) {
      return const SizedBox();
    }

    String text;
    if (value >= 1000) {
      text = '${(value / 1000).toInt()}k';
    } else {
      text = value.toInt().toString();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(text, style: style, textAlign: TextAlign.right),
    );
  }
}

class _TopProductsSegment extends StatelessWidget {
  const _TopProductsSegment({super.key});

  @override
  Widget build(BuildContext context) {
    return WhiskrAdminAnalyticsTopOrders(segmentTitle: 'Top Products', products: productsValueList);
  }
}

final List<WAProduct> productsValueList = [
  WAProduct(
    id: '123',
    name: "Dog Food Premium",
    description: "High-quality dry food for adult dogs.",
    brandName: "HappyPaws",
    category: "Food",
    tags: ["dog", "food", "dry"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 50,
    price: 29.99,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.lowStock.title,
  ),
  WAProduct(
    id: '123wew',
    name: "Cat Food Deluxe",
    description: "Nutritious wet food for cats with chicken flavor.",
    brandName: "MeowMix",
    category: "Food",
    tags: ["cat", "food", "wet"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 80,
    price: 19.49,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.inStock.title,
  ),
  WAProduct(
    id: '12e2w23',
    name: "Dog Collar Leather",
    description: "Adjustable leather collar for medium dogs.",
    brandName: "PetStyle",
    category: "Accessories",
    tags: ["dog", "collar", "leather"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 120,
    price: 14.99,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.inStock.title,
  ),
];
