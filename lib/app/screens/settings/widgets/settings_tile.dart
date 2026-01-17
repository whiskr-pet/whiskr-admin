import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String? subtitle;
  final String? valueText;
  final bool isDestructive;
  final VoidCallback? onTap;
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.iconData,
    required this.title,
    this.subtitle,
    this.valueText,
    this.isDestructive = false,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final Color iconColor = isDestructive ? colorScheme.error : colorScheme.primary;
    final Color titleColor = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(iconData, color: iconColor),
          title: Text(
            title,
            style: themeData.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: titleColor),
          ),
          subtitle: subtitle == null ? null : Text(subtitle!, style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onSurfaceVariant)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (valueText != null) Text(valueText!, style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onSurfaceVariant)),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: themeData.colorScheme.onSurfaceVariant),
            ],
          ),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
