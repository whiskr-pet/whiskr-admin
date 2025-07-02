import 'package:flutter/material.dart';

class DashboardStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const DashboardStatsCard({super.key, required this.title, required this.value, required this.icon, required this.color, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header with icon and trend indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, color: color, size: 18),
                ),
                Icon(Icons.trending_up, color: color.withOpacity(0.6), size: 16),
              ],
            ),
            const SizedBox(height: 12),

            // Value
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 2),

            // Title
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 2),

            // Subtitle
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
}
